import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick

ShellRoot {
    id: root

    // One bar per screen
    Variants {
        model: Quickshell.screens
        Bar {
            onBtClicked:    btPopup.toggle()
            onAudioClicked: audioPopup.toggle()
        }
    }

    // App launcher — single overlay, primary screen
    Launcher { id: launcher }

    // Notification toasts — bottom-right
    Notifications {}

    // Bluetooth popup — top-right, below bar
    BluetoothPopup { id: btPopup }
    AudioPopup { id: audioPopup }

    PanelWindow {
        visible: audioPopup.visible
        anchors { top: true; bottom: true; left: true; right: true }
        WlrLayershell.layer: WlrLayer.Top
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        MouseArea {
            anchors.fill: parent
            onClicked: audioPopup.visible = false
        }
    }

    VolumeOSD {}

    // PAM context at root scope so lock surface children can reference it
    PamContext {
        id: pam
        config: "hyprlock"

        onCompleted: result => {
            if (result === PamResult.Success) {
                sessionLock.locked = false
            } else {
                pam.start()
            }
        }
    }

    // Lock screen
    WlSessionLock {
        id: sessionLock
        locked: false

        onLockedChanged: {
            if (locked) pam.start()
            else if (pam.active) pam.abort()
        }

        WlSessionLockSurface {
            color: "#11111b"

            Item {
                parent: contentItem
                anchors.fill: parent

                // Gradient background
                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#1e1e2e" }
                        GradientStop { position: 1.0; color: "#11111b" }
                    }
                }

                // Time — top right
                Text {
                    id: lockTime
                    anchors { top: parent.top; right: parent.right; topMargin: 40; rightMargin: 30 }
                    color: "#cdd6f4"
                    font.pixelSize: 100
                    font.weight: Font.Light
                    font.family: "SourceCodePro Nerd Font"
                    function update() { text = Qt.formatDateTime(new Date(), "HH:mm") }
                    Component.onCompleted: update()
                    Timer { interval: 1000; running: true; repeat: true; onTriggered: lockTime.update() }
                }

                // Date — below time
                Text {
                    id: lockDate
                    anchors { top: lockTime.bottom; right: parent.right; topMargin: 10; rightMargin: 30 }
                    color: "#a6adc8"
                    font.pixelSize: 24
                    font.weight: Font.Light
                    font.family: "SourceCodePro Nerd Font"
                    function update() { text = Qt.formatDateTime(new Date(), "dddd, d MMMM yyyy") }
                    Component.onCompleted: update()
                    Timer { interval: 60000; running: true; repeat: true; onTriggered: lockDate.update() }
                }

                // Password input — centered pill
                Item {
                    id: inputWrapper
                    anchors.centerIn: parent
                    width: parent.width * 0.2
                    height: 48

                    Rectangle {
                        anchors.fill: parent
                        radius: 24
                        color: "transparent"
                        border.width: 2
                        border.color: pam.messageIsError ? "#f38ba8" : "#89dceb"

                        Text {
                            anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                            text: "Password\u2026"
                            color: "#45475a"
                            font.pixelSize: 13
                            font.family: "SourceCodePro Nerd Font"
                            visible: lockInput.text === ""
                        }

                        TextInput {
                            id: lockInput
                            anchors { fill: parent; leftMargin: 20; rightMargin: 20 }
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            color: "#cdd6f4"
                            font.pixelSize: 13
                            font.family: "SourceCodePro Nerd Font"
                            focus: sessionLock.locked

                            Keys.onReturnPressed: {
                                if (pam.responseRequired) {
                                    pam.respond(text)
                                    text = ""
                                }
                            }
                            Keys.onEscapePressed: text = ""
                        }
                    }
                }

                // PAM status message — only when non-empty
                Text {
                    visible: pam.message !== ""
                    anchors {
                        top: inputWrapper.bottom
                        horizontalCenter: parent.horizontalCenter
                        topMargin: 10
                    }
                    text: pam.message
                    color: pam.messageIsError ? "#f38ba8" : "#6c7086"
                    font.pixelSize: 12
                    font.family: "SourceCodePro Nerd Font"
                }
            }
        }
    }

    // IPC: trigger lock from hypridle / loginctl
    IpcHandler {
        target: "lock"
        function lock(): void {
            sessionLock.locked = true
        }
    }

    // IPC: toggle launcher from SUPER+SPACE keybind
    IpcHandler {
        target: "launcher"
        function toggle(): void {
            launcher.toggle()
        }
    }
}
