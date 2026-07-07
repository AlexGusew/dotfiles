import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    id: root

    // One bar per screen
    Variants {
        model: Quickshell.screens
        Bar {
            onBtClicked:    btPopup.toggle()
            onAudioClicked: audioPopup.toggle()
            onPowerClicked: powerPopup.toggle()
        }
    }

    // App launcher — single overlay, primary screen
    Launcher { id: launcher }

    // Notification toasts — bottom-right
    Notifications {}

    // Bluetooth popup — top-right, below bar
    BluetoothPopup { id: btPopup }
    AudioPopup { id: audioPopup }
    PowerPopup { id: powerPopup }

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

    // IPC: toggle launcher from SUPER+SPACE keybind
    IpcHandler {
        target: "launcher"
        function toggle(): void {
            launcher.toggle()
        }
    }
}
