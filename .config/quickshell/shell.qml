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
        Bar {}
    }

    // App launcher — single overlay, primary screen
    Launcher { id: launcher }

    // Notification toasts — bottom-right
    Notifications {}

    // IPC: toggle launcher from SUPER+SPACE keybind
    IpcHandler {
        target: "launcher"
        function toggle(): void {
            launcher.toggle()
        }
    }

    // IPC: set theme mode from the configs terminal's theme picker (Dark/Light/Auto)
    IpcHandler {
        target: "theme"
        function set(mode: string): void {
            Theme.mode = mode
        }
    }
}
