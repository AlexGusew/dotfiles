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

    PopupCard {
        id: card
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: Theme.barHeight + 4 }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.topMargin: 8
            Layout.bottomMargin: 6
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
                text: "󰑓"
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
                width: 26; height: 13; radius: 6.5
                color: Bluetooth.defaultAdapter?.enabled ? Theme.textPrimary : Theme.border
                MouseArea {
                    anchors.fill: parent
                    onClicked: if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
                }
                Rectangle {
                    width: 10; height: 10; radius: 5
                    color: Bluetooth.defaultAdapter?.enabled ? Theme.bg : Theme.textMuted
                    anchors.verticalCenter: parent.verticalCenter
                    x: Bluetooth.defaultAdapter?.enabled ? parent.width - 12 : 2
                    Behavior on x { NumberAnimation { duration: 100 } }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

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
                implicitHeight: Theme.listRowHeight
                color: "transparent"

                RowLayout {
                    anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
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
                            if (modelData.state === BluetoothDeviceState.Connected)     return "󰂱"
                            if (modelData.state === BluetoothDeviceState.Connecting)    return "󰑓"
                            if (modelData.state === BluetoothDeviceState.Disconnecting) return "󰂲"
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

        Text {
            visible: (Bluetooth.defaultAdapter?.devices?.values?.filter(d => d.paired) ?? []).length === 0
                     && (Bluetooth.defaultAdapter?.enabled ?? false)
            text: "No paired devices"
            color: Theme.textMuted
            font.pixelSize: Theme.fontBase
            font.family: Theme.font
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 8
            Layout.bottomMargin: 4
        }

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
                implicitHeight: Theme.listRowHeight
                color: "transparent"

                RowLayout {
                    anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
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
                        text: modelData.pairing ? "󰑓" : "󰐕"
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

        Rectangle {
            visible: Bluetooth.defaultAdapter?.enabled ?? false
            Layout.fillWidth: true; height: 1; color: Theme.border
        }

        Rectangle {
            visible: Bluetooth.defaultAdapter?.enabled ?? false
            Layout.fillWidth: true
            implicitHeight: 30
            color: "transparent"

            Text {
                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
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

        Item { implicitHeight: 6 }
    }
}
