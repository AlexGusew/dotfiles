import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PanelWindow {
    id: audioPopup
    visible: false

    anchors { top: true; left: true; right: true }
    margins.top: Theme.barHeight + 4
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay

    height: card.height
    color: "transparent"

    function toggle() { visible = !visible }

    property string selectedSinkKey:   ""
    property string selectedSourceKey: ""
    property real sinkVolume: 0

    function syncDefaults() {
        var s = Pipewire.defaultAudioSink
        if (s) selectedSinkKey = s.description || s.name
        var src = Pipewire.defaultAudioSource
        if (src) selectedSourceKey = src.description || src.name
    }

    onVisibleChanged: {
        if (visible) {
            syncDefaults()
            sinkVolume = Pipewire.defaultAudioSink?.audio?.volume ?? 0
        }
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource].filter(x => x != null)
    }

    Connections {
        target: Pipewire
        function onDefaultAudioSinkChanged() {
            audioPopup.syncDefaults()
            audioPopup.sinkVolume = Pipewire.defaultAudioSink?.audio?.volume ?? 0
        }
        function onDefaultAudioSourceChanged() { audioPopup.syncDefaults() }
    }

    property var sinkAudio: Pipewire.ready ? (Pipewire.defaultAudioSink?.audio ?? null) : null
    property var sourceAudio: Pipewire.ready ? (Pipewire.defaultAudioSource?.audio ?? null) : null

    PopupCard {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            text: "AUDIO"
            color: "#555555"
            font.pixelSize: Theme.fontXs
            font.letterSpacing: 1.5
            font.family: Theme.font
            Layout.leftMargin: 8
            Layout.topMargin: 8
            Layout.bottomMargin: 6
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.topMargin: 4
            Layout.bottomMargin: 4
            spacing: 8

            Slider {
                id: volSlider
                Layout.fillWidth: true
                implicitHeight: 18
                from: 0; to: 1

                Binding on value {
                    value: audioPopup.sinkVolume
                    when: !volSlider.pressed
                }

                onMoved: {
                    audioPopup.sinkVolume = volSlider.value
                    if (audioPopup.sinkAudio)
                        audioPopup.sinkAudio.volume = volSlider.value
                }

                background: Rectangle {
                    x: volSlider.leftPadding
                    y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                    width: volSlider.availableWidth
                    height: 2; radius: 1
                    color: Theme.border
                    Rectangle {
                        width: volSlider.visualPosition * parent.width
                        height: parent.height; radius: 2
                        color: audioPopup.sinkAudio?.muted ? Theme.textMuted : Theme.textPrimary
                    }
                }

                handle: Rectangle {
                    x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                    y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                    width: 10; height: 10; radius: 5
                    color: Theme.textPrimary
                }
            }

            Text {
                text: Math.round(audioPopup.sinkVolume * 100) + "%"
                color: Theme.textMuted
                font.pixelSize: Theme.fontXs
                font.family: Theme.font
                Layout.preferredWidth: 28
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

        Text {
            text: "OUTPUT"
            color: "#555555"
            font.pixelSize: Theme.fontXs
            font.letterSpacing: 1.5
            font.family: Theme.font
            Layout.leftMargin: 8
            Layout.topMargin: 6
            Layout.bottomMargin: 4
        }

        Repeater {
            model: {
                if (!Pipewire.ready) return []
                return Pipewire.nodes.values
                    .filter(n => n.isSink && !n.isStream && n.description)
                    .filter((n, i, a) => a.findIndex(x => x.description === n.description) === i)
                    .sort((a, b) => a.description.localeCompare(b.description))
            }

            Rectangle {
                required property var modelData
                property bool isDefault:
                    (modelData.description || modelData.name) === audioPopup.selectedSinkKey

                Layout.fillWidth: true
                implicitHeight: Theme.listRowHeight
                color: "transparent"

                RowLayout {
                    anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                    spacing: 8

                    Text {
                        text: modelData.description || modelData.nickname || modelData.name
                        color: isDefault ? Theme.textPrimary : Theme.textMuted
                        font.pixelSize: Theme.fontBase
                        font.family: Theme.font
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 6; height: 6; radius: 3
                        color: isDefault ? Theme.textPrimary : Theme.textMuted
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = Theme.inputHover
                    onExited:  parent.color = "transparent"
                    onClicked: {
                        if (modelData.isSink) {
                            audioPopup.selectedSinkKey = modelData.description || modelData.name
                            Pipewire.preferredDefaultAudioSink = modelData
                        }
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

        Text {
            text: "INPUT"
            color: "#555555"
            font.pixelSize: Theme.fontXs
            font.letterSpacing: 1.5
            font.family: Theme.font
            Layout.leftMargin: 8
            Layout.topMargin: 6
            Layout.bottomMargin: 4
        }

        Repeater {
            model: {
                if (!Pipewire.ready) return []
                return Pipewire.nodes.values
                    .filter(n => !n.isSink && !n.isStream && n.description && n.audio
                              && !n.description.toLowerCase().includes("monitor"))
                    .filter((n, i, a) => a.findIndex(x => x.description === n.description) === i)
                    .sort((a, b) => a.description.localeCompare(b.description))
            }

            Rectangle {
                required property var modelData
                property bool isDefault:
                    (modelData.description || modelData.name) === audioPopup.selectedSourceKey

                Layout.fillWidth: true
                implicitHeight: Theme.listRowHeight
                color: "transparent"

                RowLayout {
                    anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                    spacing: 8

                    Text {
                        text: modelData.description || modelData.nickname || modelData.name
                        color: isDefault ? Theme.textPrimary : Theme.textMuted
                        font.pixelSize: Theme.fontBase
                        font.family: Theme.font
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 6; height: 6; radius: 3
                        color: isDefault ? Theme.textPrimary : Theme.textMuted
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = Theme.inputHover
                    onExited:  parent.color = "transparent"
                    onClicked: {
                        if (!modelData.isSink) {
                            audioPopup.selectedSourceKey = modelData.description || modelData.name
                            Pipewire.preferredDefaultAudioSource = modelData
                        }
                    }
                }
            }
        }

        Item { implicitHeight: 6 }
    }
}
