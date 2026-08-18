pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: theme

    // ── Mode ──────────────────────────────────────────────────────
    // "light" | "dark" | "auto" (auto follows GNOME color-scheme via gsettings)
    property string mode: "auto"
    property bool systemDark: true
    readonly property bool dark: mode === "light" ? false : (mode === "dark" ? true : systemDark)

    function cycleMode() {
        mode = mode === "dark" ? "light" : mode === "light" ? "auto" : "dark"
    }

    property bool __loaded: false
    FileView {
        id: modeFile
        path: "/home/alex/.config/quickshell/theme-mode.txt"
        preload: true
        printErrors: false
        onLoaded: {
            var t = text().trim()
            if (t === "light" || t === "dark" || t === "auto") theme.mode = t
            theme.__loaded = true
        }
        onLoadFailed: theme.__loaded = true
    }
    onModeChanged: {
        if (__loaded) modeFile.setText(mode)
        if (mode === "dark" || mode === "light") applySystemTheme(mode === "dark")
    }

    // kitty-bg (the nsakura wallpaper terminal) is a separate long-running
    // process — push its colors any time the resolved dark/light state
    // changes, including via "auto" following the system.
    onDarkChanged: {
        Qt.callLater(syncWallpaperTerminal)
        Qt.callLater(syncKittyTerminal)
    }
    Component.onCompleted: {
        Qt.callLater(syncWallpaperTerminal)
        Qt.callLater(syncKittyTerminal)
    }

    function syncWallpaperTerminal() {
        var colors = "background=" + bg + " foreground=" + textPrimary
        var script =
            "for sock in /tmp/kitty-bg-*.sock; do " +
            "[ -S \"$sock\" ] && kitten @ --to unix:\"$sock\" set-colors " + colors + "; " +
            "done"
        kittyBgSync.command = ["sh", "-c", script]
        kittyBgSync.running = false
        kittyBgSync.running = true
    }

    Process { id: kittyBgSync }

    // Main interactive kitty terminal: unlike kitty-bg, this uses a full
    // theme (all 16 ANSI colors + tab-bar colors), not just bg/fg, so it's
    // driven from the two static theme-dark.conf/theme-light.conf files
    // (kept in ~/.config/kitty/, decoupled from the vendored kitty-themes
    // repo) rather than from Theme.qml's own palette. Rewriting
    // current-theme.conf covers windows launched from now on; the
    // `set-colors` push covers windows already open, exactly like
    // syncWallpaperTerminal above.
    function syncKittyTerminal() {
        var src = dark
            ? "/home/alex/.config/kitty/theme-dark.conf"
            : "/home/alex/.config/kitty/theme-light.conf"
        var script =
            "cp '" + src + "' /home/alex/.config/kitty/current-theme.conf; " +
            "for sock in /tmp/kitty.sock-*; do " +
            "[ -S \"$sock\" ] && kitten @ --to unix:\"$sock\" set-colors --all --configured '" + src + "'; " +
            "done"
        kittySync.command = ["sh", "-c", script]
        kittySync.running = false
        kittySync.running = true
    }

    Process { id: kittySync }

    // Push Materia/Materia-light to GTK3 (gsettings) and GTK4/libadwaita apps
    // (Files, Firefox) so they follow the bar instead of only Theme.qml.
    // GTK4 has no live theme-name switch — apps read ~/.config/gtk-4.0/{gtk.css,assets}
    // as a static override, so that symlink pair has to be re-pointed per mode.
    function applySystemTheme(dark) {
        var scheme    = dark ? "prefer-dark" : "prefer-light"
        var gtk3Theme = dark ? "Materia" : "Materia-light"
        var gtk4Dir   = dark ? "/usr/share/themes/Materia/gtk-4.0" : "/usr/share/themes/Materia-light/gtk-4.0"
        var gtk4Css   = dark ? gtk4Dir + "/gtk-dark.css" : gtk4Dir + "/gtk.css"
        var preferDark = dark ? "1" : "0"

        var script =
            "gsettings set org.gnome.desktop.interface color-scheme '" + scheme + "'; " +
            "gsettings set org.gnome.desktop.interface gtk-theme '" + gtk3Theme + "'; " +
            "mkdir -p ~/.config/gtk-4.0; " +
            "ln -sfn '" + gtk4Css + "' ~/.config/gtk-4.0/gtk.css; " +
            "ln -sfn '" + gtk4Dir + "/assets' ~/.config/gtk-4.0/assets; " +
            "touch ~/.config/gtk-4.0/settings.ini; " +
            "grep -q '^gtk-theme-name=' ~/.config/gtk-4.0/settings.ini && " +
            "sed -i \"s/^gtk-theme-name=.*/gtk-theme-name=" + gtk3Theme + "/; " +
            "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=" + preferDark + "/\" ~/.config/gtk-4.0/settings.ini"

        gsetWriter.command = ["sh", "-c", script]
        gsetWriter.running = false
        gsetWriter.running = true
    }

    Process { id: gsetWriter }

    Process {
        running: true
        command: ["sh", "-c", "gsettings get org.gnome.desktop.interface color-scheme; gsettings monitor org.gnome.desktop.interface color-scheme"]
        stdout: SplitParser {
            onRead: data => { theme.systemDark = data.includes("dark") }
        }
    }

    // ── Background ────────────────────────────────────────────────
    readonly property color bg:           dark ? "#000000" : "#ffffff"  // root / screen
    readonly property color surface:      dark ? "#0d0d0d" : "#f2f2f2"  // card, panel, overlay
    readonly property color input:        dark ? "#111111" : "#eeeeee"  // text field bg
    readonly property color inputHover:   dark ? "#141414" : "#e9e9e9"  // selected list item

    // ── Border ────────────────────────────────────────────────────
    readonly property color border:       dark ? "#1a1a1a" : "#e5e5e5"  // default
    readonly property color borderFocus:  dark ? "#333333" : "#cccccc"  // focused (bar context)
    readonly property color borderActive: dark ? "#ffffff" : "#000000"  // focused (overlay context)
    readonly property color borderError:  "#cc3333"                     // error / auth failure

    // ── Text ──────────────────────────────────────────────────────
    readonly property color textPrimary:   dark ? "#ffffff" : "#000000"
    readonly property color textSecondary: dark ? "#999999" : "#666666"  // bar title, subtitles
    readonly property color textMuted:     dark ? "#666666" : "#999999"  // unselected items
    readonly property color textDim:       dark ? "#333333" : "#cccccc"  // placeholders, field labels
    readonly property color textLabel:     dark ? "#2a2a2a" : "#d5d5d5"  // uppercase section labels
    readonly property color textError:     "#cc3333"

    // ── Typography ────────────────────────────────────────────────
    readonly property string font:  "SauceCodePro Nerd Font Mono"
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
