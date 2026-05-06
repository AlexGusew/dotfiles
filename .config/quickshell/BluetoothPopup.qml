import Quickshell
import Quickshell.Wayland
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: btPopup
    visible: false

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    color: "transparent"

    function toggle() { visible = !visible }

    MouseArea {
        anchors.fill: parent
        onClicked: btPopup.visible = false
    }

    Rectangle {
        id: card
        width: 280
        anchors { top: parent.top; right: parent.right; topMargin: Theme.barHeight + 4; rightMargin: 8 }
        height: contentCol.implicitHeight
        color: Theme.surface
        radius: Theme.radiusMd
        border.width: 1
        border.color: Theme.border

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: contentCol
            anchors { top: parent.top; left: parent.left; right: parent.right }
            spacing: 0

            // Header: label + scanning indicator + toggle
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 14
                Layout.rightMargin: 14
                Layout.topMargin: 12
                Layout.bottomMargin: 10
                spacing: 8

                Text {
                    text: "BLUETOOTH"
                    color: "#555555"
                    font.pixelSize: Theme.fontXs
                    font.letterSpacing: 1.5
                    font.family: Theme.font
                    Layout.fillWidth: true
                }

                Text {
                    visible: Bluetooth.defaultAdapter?.discovering ?? false
                    text: "\uDB81\uDC53"
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontSm
                    font.family: Theme.font
                    SequentialAnimation on opacity {
                        running: Bluetooth.defaultAdapter?.discovering ?? false
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.25; duration: 700; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0;  duration: 700; easing.type: Easing.InOutSine }
                    }
                }

                Rectangle {
                    width: 32; height: 16; radius: 8
                    color: Bluetooth.defaultAdapter?.enabled ? Theme.textPrimary : Theme.border
                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
                    }
                    Rectangle {
                        width: 12; height: 12; radius: 6
                        color: Bluetooth.defaultAdapter?.enabled ? Theme.bg : Theme.textMuted
                        anchors.verticalCenter: parent.verticalCenter
                        x: Bluetooth.defaultAdapter?.enabled ? parent.width - 14 : 2
                        Behavior on x { NumberAnimation { duration: 100 } }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

            // Paired devices
            Repeater {
                model: {
                    var devs = Bluetooth.defaultAdapter?.devices?.values ?? []
                    return devs
                        .filter(d => d.paired)
                        .sort((a, b) => {
                            if (b.connected !== a.connected) return b.connected - a.connected
                            return (a.name || a.deviceName).localeCompare(b.name || b.deviceName)
                        })
                }

                Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: 40
                    color: "transparent"

                    Rectangle {
                        visible: modelData.connected
                        width: 2; height: parent.height
                        color: Theme.textPrimary
                        anchors.left: parent.left
                    }

                    RowLayout {
                        anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                        spacing: 8

                        Text {
                            text: modelData.name || modelData.deviceName
                            color: modelData.connected ? Theme.textPrimary : Theme.textMuted
                            font.pixelSize: Theme.fontBase
                            font.family: Theme.font
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            visible: modelData.batteryAvailable
                            text: Math.round(modelData.battery) + "%"
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontXs
                            font.family: Theme.font
                        }

                        Text {
                            text: {
                                if (modelData.state === BluetoothDeviceState.Connected)     return "\uDB80\uDCB1"
                                if (modelData.state === BluetoothDeviceState.Connecting)    return "\uDB81\uDC53"
                                if (modelData.state === BluetoothDeviceState.Disconnecting) return "\uDB80\uDCB2"
                                return ""
                            }
                            visible: text !== ""
                            color: modelData.state === BluetoothDeviceState.Connected ? Theme.textPrimary : Theme.textMuted
                            font.pixelSize: Theme.fontSm
                            font.family: Theme.font
                            SequentialAnimation on opacity {
                                running: modelData.state === BluetoothDeviceState.Connecting
                                      || modelData.state === BluetoothDeviceState.Disconnecting
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.25; duration: 700; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 1.0;  duration: 700; easing.type: Easing.InOutSine }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = Theme.inputHover
                        onExited:  parent.color = "transparent"
                        onClicked: modelData.connected ? modelData.disconnect() : modelData.connect()
                    }
                }
            }

            // No paired devices message
            Text {
                visible: (Bluetooth.defaultAdapter?.devices?.values?.filter(d => d.paired) ?? []).length === 0
                         && (Bluetooth.defaultAdapter?.enabled ?? false)
                text: "No paired devices"
                color: Theme.textMuted
                font.pixelSize: Theme.fontBase
                font.family: Theme.font
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 10
                Layout.bottomMargin: 6
            }

            // Nearby devices (unpaired, visible during scan)
            Repeater {
                model: {
                    if (!(Bluetooth.defaultAdapter?.discovering ?? false)) return []
                    var devs = Bluetooth.defaultAdapter?.devices?.values ?? []
                    return devs
                        .filter(d => !d.paired)
                        .sort((a, b) => (a.name || a.deviceName).localeCompare(b.name || b.deviceName))
                }

                Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: 40
                    color: "transparent"

                    RowLayout {
                        anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                        spacing: 8

                        Text {
                            text: modelData.name || modelData.deviceName || modelData.address
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontBase
                            font.family: Theme.font
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: modelData.pairing ? "\uDB81\uDC53" : "\uDB81\uDC15"
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontSm
                            font.family: Theme.font
                            SequentialAnimation on opacity {
                                running: modelData.pairing
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.25; duration: 700; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 1.0;  duration: 700; easing.type: Easing.InOutSine }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.color = Theme.inputHover
                        onExited:  parent.color = "transparent"
                        onClicked: if (!modelData.pairing) modelData.pair()
                    }
                }
            }

            // Divider before scan button
            Rectangle {
                visible: Bluetooth.defaultAdapter?.enabled ?? false
                Layout.fillWidth: true; height: 1; color: Theme.border
            }

            // Scan button
            Rectangle {
                visible: Bluetooth.defaultAdapter?.enabled ?? false
                Layout.fillWidth: true
                implicitHeight: 36
                color: "transparent"

                Text {
                    anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                    text: Bluetooth.defaultAdapter?.discovering ? "Stop scanning" : "Scan for devices"
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontBase
                    font.family: Theme.font
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = Theme.inputHover
                    onExited:  parent.color = "transparent"
                    onClicked: if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.discovering = !Bluetooth.defaultAdapter.discovering
                }
            }

            Item { implicitHeight: 8 }
        }
    }
}
