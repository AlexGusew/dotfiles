import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick

PanelWindow {
    id: bar
    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true }
    height: Theme.barHeight
    color: Theme.bg

    Item {
        anchors { fill: parent; leftMargin: 14; rightMargin: 14 }

        // Center — workspaces + status
        Row {
            anchors.centerIn: parent
            spacing: 12

            // Workspaces
            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter

                Repeater {
                    model: Hyprland.workspaces.values.filter(w => w.id > 0)

                    Item {
                        required property HyprlandWorkspace modelData

                        implicitWidth: wsLabel.implicitWidth
                        implicitHeight: Theme.barHeight

                        Text {
                            id: wsLabel
                            anchors.centerIn: parent
                            text: parent.modelData.focused ? "[" + parent.modelData.id + "]" : parent.modelData.id + ""
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontBase
                            font.family: Theme.font
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: parent.modelData.activate()
                        }
                    }
                }
            }


            // Configs + Language + Battery + Clock
            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter

                // Configs popup (gear) — opens/hides the configs terminal
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: ""
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontLg
                    font.family: Theme.font
                    width: 10

                    Process {
                        id: configsToggle
                        command: ["fish", "/home/alex/.config/quickshell/scripts/configs.fish", "toggle"]
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: { configsToggle.running = false; configsToggle.running = true }
                    }
                }

                // Language indicator
                Text {
                    width: 16
                    id: langText
                    anchors.verticalCenter: parent.verticalCenter
                    property string lang: "en"
                    text: lang
                    color: Theme.textPrimary
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

                // Battery
                Row {
                    visible: UPower.displayDevice !== null && (UPower.displayDevice?.isPresent ?? false)
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
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
                            return Theme.textPrimary
                        }
                        font.pixelSize: Theme.fontLg
                        font.family: Theme.font
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        property var dev: UPower.displayDevice
                        property bool charging: dev?.state === UPowerDeviceState.Charging
                                             || dev?.state === UPowerDeviceState.PendingCharge
                        property int pct: Math.round((dev?.percentage ?? 0) * 100)
                        text: pct + ""
                        color: {
                            if (charging) return Theme.textPrimary
                            if (pct <= 15) return "#ff5555"
                            if (pct <= 30) return "#ffaa55"
                            return Theme.textPrimary
                        }
                        font.pixelSize: Theme.fontBase
                        font.family: Theme.font
                        horizontalAlignment: Text.AlignLeft
                        width: batteryPctMetrics.width
                    }

                    TextMetrics {
                        id: batteryPctMetrics
                        font.family: Theme.font
                        font.pixelSize: Theme.fontBase
                        text: "100"
                    }
                }

                // Volume — single block-height char (1 of 8 levels) + percentage, queried via wpctl
                Row {
                    id: volumeRow
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter

                    property real vol: 0
                    property bool muted: false

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -3
                        property var levels: ["▁", "▂", "▃", "▄", "▅"]
                        text: levels[Math.max(0, Math.min(4, Math.floor(volumeRow.vol * 5)))]
                        color: volumeRow.muted ? Theme.textMuted : Theme.textPrimary
                        font.pixelSize: Theme.fontBase
                        font.family: Theme.font
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Math.round(volumeRow.vol * 100) + ""
                        color: volumeRow.muted ? Theme.textMuted : Theme.textPrimary
                        font.pixelSize: Theme.fontBase
                        font.family: Theme.font
                        horizontalAlignment: Text.AlignLeft
                        width: volPctMetrics.width
                    }

                    TextMetrics {
                        id: volPctMetrics
                        font.family: Theme.font
                        font.pixelSize: Theme.fontBase
                        text: "100"
                    }

                    // Query actual volume on each change — bypasses unbound node issue (same as VolumeOSD.qml)
                    Process {
                        id: volQuery
                        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
                        stdout: SplitParser {
                            onRead: line => {
                                var m = line.match(/Volume:\s+([\d.]+)/)
                                if (m) volumeRow.vol = parseFloat(m[1])
                                volumeRow.muted = line.includes("[MUTED]")
                            }
                        }
                    }

                    Process {
                        command: ["pactl", "subscribe"]
                        running: true
                        stdout: SplitParser {
                            onRead: line => {
                                if (line.includes("'change'") && line.includes(" sink #")) {
                                    volQuery.running = false
                                    volQuery.running = true
                                }
                            }
                        }
                    }

                    Component.onCompleted: volQuery.running = true
                }

                Text {
                    id: clockTime
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontBase
                    font.family: Theme.font
                    function update() { text = Qt.formatDateTime(new Date(), "HH:mm") }
                    Component.onCompleted: update()
                    Timer { interval: 1000; running: true; repeat: true; onTriggered: clockTime.update() }
                }

                Text {
                    id: clockDate
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.textPrimary
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
