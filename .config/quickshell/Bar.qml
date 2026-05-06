import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import QtQuick

PanelWindow {
    id: bar
    required property var modelData
    screen: modelData

    signal btClicked()
    signal audioClicked()

    anchors { top: true; left: true; right: true }
    height: Theme.barHeight
    color: Theme.bg

    Item {
        anchors { fill: parent; leftMargin: 14; rightMargin: 14 }

        // Active window title — left
        Text {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            text: ToplevelManager.activeToplevel?.title ?? ""
            color: Theme.textSecondary
            font.pixelSize: Theme.fontBase
            font.family: Theme.font
            elide: Text.ElideRight
            width: Math.min(implicitWidth, parent.width / 3)
        }

        // Workspaces — always centered
        Row {
            anchors.centerIn: parent
            spacing: 14

            Repeater {
                model: Hyprland.workspaces.values

                Item {
                    required property HyprlandWorkspace modelData

                    implicitWidth: wsLabel.implicitWidth
                    implicitHeight: Theme.barHeight

                    Text {
                        id: wsLabel
                        anchors.centerIn: parent
                        text: parent.modelData.id
                        color: parent.modelData.focused ? Theme.textPrimary : Theme.textMuted
                        font.pixelSize: Theme.fontBase
                        font.family: Theme.font
                        font.weight: parent.modelData.focused ? Font.Medium : Font.Normal
                    }

                    Rectangle {
                        visible: parent.modelData.focused
                        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                        width: 3
                        height: 1
                        color: Theme.textPrimary
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: parent.modelData.activate()
                    }
                }
            }
        }

        // Clock — right
        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            spacing: 8

            // Volume icon
            Text {
                property var sink: Pipewire.defaultAudioSink
                visible: Pipewire.ready
                text: {
                    if (!sink || !sink.audio || sink.audio.muted || sink.audio.volume === 0) return "\uDB81\uDF5F"
                    if (sink.audio.volume < 0.34)                                             return "\uDB81\uDD7F"
                    if (sink.audio.volume < 0.67)                                             return "\uDB81\uDD80"
                    return "\uDB81\uDD7E"
                }
                color: (!sink || !sink.audio || sink.audio.muted) ? Theme.textMuted : Theme.textSecondary
                font.pixelSize: Theme.fontBase
                font.family: Theme.font
                MouseArea { anchors.fill: parent; onClicked: bar.audioClicked() }
            }

            // Bluetooth icon
            Text {
                visible: Bluetooth.defaultAdapter !== null
                text: {
                    if (!Bluetooth.defaultAdapter?.enabled) return "\uDB80\uDCB2"
                    var n = Bluetooth.defaultAdapter?.devices?.values?.filter(d => d.connected).length ?? 0
                    return n > 0 ? "\uDB80\uDCB1" : "\uDB80\uDCAF"
                }
                color: {
                    if (!Bluetooth.defaultAdapter?.enabled) return Theme.textMuted
                    var n = Bluetooth.defaultAdapter?.devices?.values?.filter(d => d.connected).length ?? 0
                    return n > 0 ? Theme.textPrimary : Theme.textSecondary
                }
                font.pixelSize: Theme.fontBase
                font.family: Theme.font
                MouseArea { anchors.fill: parent; onClicked: bar.btClicked() }
            }

            Text {
                id: clockTime
                color: Theme.textPrimary
                font.pixelSize: Theme.fontBase
                font.family: Theme.font
                function update() { text = Qt.formatDateTime(new Date(), "HH:mm") }
                Component.onCompleted: update()
                Timer { interval: 1000; running: true; repeat: true; onTriggered: clockTime.update() }
            }

            Text {
                id: clockDate
                color: Theme.textMuted
                font.pixelSize: Theme.fontBase
                font.family: Theme.font
                function update() { text = Qt.formatDateTime(new Date(), "ddd d MMM") }
                Component.onCompleted: update()
                Timer { interval: 60000; running: true; repeat: true; onTriggered: clockDate.update() }
            }
        }
    }
}
