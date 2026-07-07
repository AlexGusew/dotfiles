import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: powerPopup
    visible: false

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    color: "transparent"

    function toggle() { visible = !visible }

    MouseArea {
        anchors.fill: parent
        onClicked: powerPopup.visible = false
    }

    Process { id: lockProc;     command: ["hyprlock"] }
    Process { id: suspendProc;  command: ["systemctl", "suspend"] }
    Process { id: restartProc;  command: ["systemctl", "reboot"] }
    Process { id: shutdownProc; command: ["systemctl", "poweroff"] }
    Process { id: logoutProc;   command: ["hyprctl", "dispatch", "exit"] }

    PopupCard {
        id: card
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: Theme.barHeight + 4 }

        Text {
            text: "POWER"
            color: "#555555"
            font.pixelSize: Theme.fontXs
            font.letterSpacing: 1.5
            font.family: Theme.font
            Layout.leftMargin: 8
            Layout.topMargin: 8
            Layout.bottomMargin: 6
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

        Repeater {
            model: [
                { icon: "",  label: "Lock",       proc: lockProc },
                { icon: "󰤄",  label: "Sleep",      proc: suspendProc },
                { icon: "󰜉",  label: "Restart",    proc: restartProc },
                { icon: "",  label: "Shut Down",  proc: shutdownProc },
                { icon: "󰍃",  label: "Log Out",    proc: logoutProc }
            ]

            Rectangle {
                required property var modelData

                Layout.fillWidth: true
                implicitHeight: Theme.listRowHeight
                color: "transparent"

                RowLayout {
                    anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                    spacing: 8

                    Text {
                        text: modelData.icon
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fontBase
                        font.family: Theme.font
                        Layout.preferredWidth: 16
                    }

                    Text {
                        text: modelData.label
                        color: Theme.textSecondary
                        font.pixelSize: Theme.fontBase
                        font.family: Theme.font
                        Layout.fillWidth: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = Theme.inputHover
                    onExited:  parent.color = "transparent"
                    onClicked: {
                        powerPopup.visible = false
                        modelData.proc.running = true
                    }
                }
            }
        }

        Item { implicitHeight: 6 }
    }
}
