import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: launcher
    visible: false

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    focusable: true
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: "transparent"

    function toggle() {
        visible = !visible
        if (visible) {
            searchInput.text = ""
            searchInput.forceActiveFocus()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#e5000000"

        MouseArea {
            anchors.fill: parent
            onClicked: launcher.visible = false
        }

        Rectangle {
            width: 580
            height: Math.min(480, parent.height * 0.75)
            anchors.centerIn: parent
            color: Theme.surface
            radius: Theme.radiusSm
            border.width: 1
            border.color: Theme.border

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors { fill: parent; margins: 0 }
                spacing: 0

                // Search field
                Item {
                    Layout.fillWidth: true
                    height: 46

                    Text {
                        anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                        text: "Search\u2026"
                        color: Theme.textDim
                        font.pixelSize: Theme.fontMd
                        font.family: Theme.font
                        visible: searchInput.text === ""
                    }

                    TextInput {
                        id: searchInput
                        anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.textPrimary
                        font.pixelSize: Theme.fontMd
                        font.family: Theme.font

                        onTextChanged: appList.currentIndex = 0

                        Keys.onEscapePressed: launcher.visible = false
                        Keys.onReturnPressed: {
                            if (appList.currentItem) appList.currentItem.launch()
                        }
                        Keys.onDownPressed: appList.incrementCurrentIndex()
                        Keys.onUpPressed: appList.decrementCurrentIndex()
                    }

                    Rectangle {
                        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                        height: 1
                        color: Theme.border
                    }
                }

                // App list
                ListView {
                    id: appList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    currentIndex: 0
                    flickDeceleration: 8000
                    maximumFlickVelocity: 12000
                    highlightMoveDuration: 0

                    model: {
                        var apps = DesktopEntries.applications.values
                        if (!apps) return []
                        var sorted = apps.slice().sort((a, b) => a.name.localeCompare(b.name))
                        var q = searchInput.text.toLowerCase()
                        return q ? sorted.filter(a => a.name.toLowerCase().includes(q)) : sorted
                    }

                    delegate: Item {
                        id: appDelegate
                        required property var modelData
                        required property int index

                        width: appList.width
                        height: 36

                        function launch() {
                            modelData.execute()
                            launcher.visible = false
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: appList.currentIndex === index ? Theme.inputHover : "transparent"
                        }

                        Rectangle {
                            visible: appList.currentIndex === index
                            width: 2
                            height: parent.height
                            color: Theme.textPrimary
                            anchors.left: parent.left
                        }

                        Text {
                            anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                            text: modelData.name
                            color: appList.currentIndex === index ? Theme.textPrimary : Theme.textMuted
                            font.pixelSize: Theme.fontBase
                            font.family: Theme.font
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: appDelegate.launch()
                        }
                    }

                    WheelHandler {
                        onWheel: appList.contentY -= event.angleDelta.y * 3
                    }
                }
            }
        }
    }
}
