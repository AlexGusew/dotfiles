import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: osd
    visible: false

    anchors { top: true }
    width: 200
    height: Theme.barHeight + 48
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    color: "transparent"

    property real volume: 0
    property bool muted: false

    // Query actual volume on each change — bypasses unbound node issue
    Process {
        id: volQuery
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: line => {
                var m = line.match(/Volume:\s+([\d.]+)/)
                if (m) osd.volume = parseFloat(m[1])
                osd.muted = line.includes("[MUTED]")
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
                    osd.show()
                }
            }
        }
    }

    function show() {
        visible = true
        card.opacity = 1
        hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: card.opacity = 0
    }

    Rectangle {
        id: card
        width: 200
        height: 40
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        anchors.topMargin: Theme.barHeight + 8

        color: Theme.surface
        radius: Theme.radiusMd
        border.width: 1
        border.color: Theme.border
        opacity: 0

        onOpacityChanged: if (opacity < 0.01) osd.visible = false

        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        RowLayout {
            anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
            spacing: 10

            Text {
                text: {
                    if (osd.muted || osd.volume === 0) return "\uDB81\uDF5F"
                    if (osd.volume < 0.34)             return "\uDB81\uDD7F"
                    if (osd.volume < 0.67)             return "\uDB81\uDD80"
                    return "\uDB81\uDD7E"
                }
                color: Theme.textSecondary
                font.pixelSize: Theme.fontLg
                font.family: Theme.font
            }

            Rectangle {
                Layout.fillWidth: true
                height: 3
                radius: 2
                color: Theme.border

                Rectangle {
                    width: parent.width * Math.min(1, osd.volume)
                    height: parent.height
                    radius: 2
                    color: osd.muted ? Theme.textMuted : Theme.textPrimary
                }
            }

            Text {
                text: Math.round(osd.volume * 100) + "%"
                color: Theme.textMuted
                font.pixelSize: Theme.fontXs
                font.family: Theme.font
                Layout.preferredWidth: 28
            }
        }
    }
}
