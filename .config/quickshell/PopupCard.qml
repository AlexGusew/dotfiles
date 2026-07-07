import QtQuick
import QtQuick.Layouts

// Flat popup card: no rounding, no mask/layer effect (avoids blur at
// fractional display scale). Children are laid out in a ColumnLayout.
Rectangle {
    id: popupCard
    default property alias content: contentCol.data
    property alias contentCol: contentCol

    width: 240
    height: contentCol.implicitHeight
    color: Theme.surface
    border.width: 1
    border.color: Theme.border

    // Swallow clicks so they don't fall through to a click-outside closer.
    MouseArea { anchors.fill: parent }

    ColumnLayout {
        id: contentCol
        anchors { top: parent.top; left: parent.left; right: parent.right }
        spacing: 0
    }
}
