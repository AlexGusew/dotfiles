import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import QtQuick

PanelWindow {
    id: bar
    required property var modelData
    screen: modelData

    signal btClicked()
    signal audioClicked()
    signal powerClicked()

    anchors { top: true; left: true; right: true }
    height: Theme.barHeight
    color: Theme.bg

    Item {
        anchors { fill: parent; leftMargin: 14; rightMargin: 14 }

        // Center — workspaces + status
        Row {
            anchors.centerIn: parent
            spacing: 24

            // Workspaces
            Row {
                spacing: 14
                anchors.verticalCenter: parent.verticalCenter

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

MouseArea {
                            anchors.fill: parent
                            onClicked: parent.modelData.activate()
                        }
                    }
                }
            }

            Rectangle {
                width: 1
                height: Theme.barHeight * 0.4
                color: Theme.borderFocus
                anchors.verticalCenter: parent.verticalCenter
            }

            // Battery + Volume + Bluetooth
            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter

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

                // Theme mode (light / dark / auto)
                Text {
                    text: Theme.mode === "light" ? "" : Theme.mode === "dark" ? "" : ""
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontBase
                    font.family: Theme.font
                    MouseArea { anchors.fill: parent; onClicked: Theme.cycleMode() }
                }

                // Power menu
                Text {
                    text: ""
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontBase
                    font.family: Theme.font
                    MouseArea { anchors.fill: parent; onClicked: bar.powerClicked() }
                }

                // Language indicator
                Text {
                    id: langText
                    property string lang: "en"
                    text: lang
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontBase
                    font.family: Theme.font

                    Process {
                        id: langProc
                        command: ["sh", "-c", "hyprctl devices -j 2>/dev/null | python3 -c \"import sys,json; kbs=json.load(sys.stdin).get('keyboards',[]); kb=next((k for k in kbs if k.get('main')),kbs[0] if kbs else {}); print('ru' if 'Russian' in kb.get('active_keymap','') else 'en')\""]
                        stdout: SplitParser {
                            onRead: data => langText.lang = data.trim()
                        }
                    }

                    Process {
                        id: langSwitch
                        command: ["hyprctl", "switchxkblayout", "all", "next"]
                        onRunningChanged: {
                            if (!running) {
                                langProc.running = false
                                langProc.running = true
                            }
                        }
                    }

                    Timer {
                        interval: 2000
                        running: true
                        repeat: true
                        onTriggered: { langProc.running = false; langProc.running = true }
                    }

                    Component.onCompleted: langProc.running = true

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            langSwitch.running = false
                            langSwitch.running = true
                        }
                    }
                }
            }

            Rectangle {
                width: 1
                height: Theme.barHeight * 0.4
                color: Theme.borderFocus
                anchors.verticalCenter: parent.verticalCenter
            }

            // Battery + Clock
            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter

                // Battery
                Row {
                    visible: UPower.displayDevice !== null && (UPower.displayDevice?.isPresent ?? false)
                    spacing: 3
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        property var dev: UPower.displayDevice
                        property bool charging: dev?.state === UPowerDeviceState.Charging
                                             || dev?.state === UPowerDeviceState.PendingCharge
                        property int pct: Math.round((dev?.percentage ?? 0) * 100)
                        text: {
                            if (charging) {
                                if (pct >= 90) return "󰂅"
                                if (pct >= 80) return "󰂋"
                                if (pct >= 60) return "󰂊"
                                if (pct >= 40) return "󰂈"
                                if (pct >= 20) return "󰂇"
                                return "󰂆"
                            }
                            if (pct >= 90) return "󰁹"
                            if (pct >= 80) return "󰂂"
                            if (pct >= 70) return "󰂁"
                            if (pct >= 60) return "󰂀"
                            if (pct >= 50) return "󰁿"
                            if (pct >= 40) return "󰁾"
                            if (pct >= 30) return "󰁽"
                            if (pct >= 20) return "󰁼"
                            if (pct >= 10) return "󰁻"
                            return "󰂃"
                        }
                        color: {
                            if (charging) return Theme.textPrimary
                            if (pct <= 15) return "#ff5555"
                            if (pct <= 30) return "#ffaa55"
                            return Theme.textSecondary
                        }
                        font.pixelSize: Theme.fontBase
                        font.family: Theme.font
                    }

                    Text {
                        property var dev: UPower.displayDevice
                        property bool charging: dev?.state === UPowerDeviceState.Charging
                                             || dev?.state === UPowerDeviceState.PendingCharge
                        property int pct: Math.round((dev?.percentage ?? 0) * 100)
                        text: pct + "%"
                        color: {
                            if (charging) return Theme.textPrimary
                            if (pct <= 15) return "#ff5555"
                            if (pct <= 30) return "#ffaa55"
                            return Theme.textSecondary
                        }
                        font.pixelSize: Theme.fontBase
                        font.family: Theme.font
                    }
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
}
