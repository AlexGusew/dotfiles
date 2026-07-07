import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

PanelWindow {
    anchors { right: true; bottom: true }
    margins.right: 20
    margins.bottom: 20
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    color: "transparent"

    width: 300
    height: Math.max(1, notifCol.implicitHeight)

    NotificationServer {
        id: server
        actionsSupported: true
        onNotification: notif => {
            notif.tracked = true
        }
    }

    Column {
        id: notifCol
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        spacing: 8

        Repeater {
            model: server.trackedNotifications.values

            Rectangle {
                required property var modelData

                width: notifCol.width
                height: toastLayout.implicitHeight + 24
                color: Theme.surface
                radius: Theme.radiusMd
                border.width: 1
                border.color: Theme.border

                // Left accent bar
                Rectangle {
                    width: 2
                    height: parent.height - 2
                    anchors { left: parent.left; leftMargin: 1; verticalCenter: parent.verticalCenter }
                    radius: Theme.radiusMd
                    color: Theme.textPrimary
                    opacity: 0.15
                }

                Timer {
                    interval: modelData.expireTimeout > 0 ? modelData.expireTimeout * 1000 : 5000
                    running: true
                    onTriggered: modelData.tracked = false
                }

                ColumnLayout {
                    id: toastLayout
                    anchors { fill: parent; leftMargin: 14; rightMargin: 12; topMargin: 12; bottomMargin: 12 }
                    spacing: 4

                    // App name — uppercase label style
                    Text {
                        text: modelData.appName.toUpperCase()
                        color: "#555555"
                        font.pixelSize: Theme.fontXs
                        font.letterSpacing: 1.5
                        font.family: Theme.font
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    // Summary
                    Text {
                        text: modelData.summary
                        color: Theme.textPrimary
                        font.pixelSize: Theme.fontMd
                        font.weight: Font.Medium
                        font.family: Theme.font
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    // Body
                    Text {
                        visible: modelData.body !== ""
                        text: modelData.body
                        color: "#888888"
                        font.pixelSize: Theme.fontBase
                        font.family: Theme.font
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        Layout.fillWidth: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: modelData.tracked = false
                }
            }
        }
    }
}
