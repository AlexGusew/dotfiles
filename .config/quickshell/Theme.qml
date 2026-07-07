pragma Singleton
import QtQuick

QtObject {
    // ── Background ────────────────────────────────────────────────
    readonly property color bg:           "#000000"  // root / screen
    readonly property color surface:      "#0d0d0d"  // card, panel, overlay
    readonly property color input:        "#111111"  // text field bg
    readonly property color inputHover:   "#141414"  // selected list item

    // ── Border ────────────────────────────────────────────────────
    readonly property color border:       "#1a1a1a"  // default
    readonly property color borderFocus:  "#333333"  // focused (bar context)
    readonly property color borderActive: "#ffffff"  // focused (overlay context)
    readonly property color borderError:  "#cc3333"  // error / auth failure

    // ── Text ──────────────────────────────────────────────────────
    readonly property color textPrimary:   "#ffffff"
    readonly property color textSecondary: "#999999"  // bar title, subtitles
    readonly property color textMuted:     "#666666"  // unselected items
    readonly property color textDim:       "#333333"  // placeholders, field labels
    readonly property color textLabel:     "#2a2a2a"  // uppercase section labels
    readonly property color textError:     "#cc3333"

    // ── Typography ────────────────────────────────────────────────
    readonly property string font:  "SourceCodePro Nerd Font"
    readonly property int fontXs:   8  // uppercase labels
    readonly property int fontSm:   9  // bar
    readonly property int fontBase: 10  // list items
    readonly property int fontMd:   11  // search, small inputs
    readonly property int fontLg:   12  // overlay inputs
    readonly property int fontXl:   18  // headings

    // ── Geometry ──────────────────────────────────────────────────
    readonly property int radiusSm: 2
    readonly property int radiusMd: 4
    readonly property int radiusLg: 6

    readonly property int fieldHeight:   52
    readonly property int barHeight:     26
    readonly property int listRowHeight: 28
}
