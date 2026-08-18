# shadcn Design System

Shared design language across three surfaces: **login screen** (SDDM), **top bar** (QuickShell), **app launcher** (QuickShell). Inspired by shadcn/ui dark theme + Next.js site aesthetic.

---

## Tokens

Source of truth: `~/.config/quickshell/Theme.qml`  
SDDM cannot import QML singletons — token values are duplicated in `Main.qml` header comment.

### Colors

| Token | Value | Usage |
|---|---|---|
| `bg` | `#000000` | Root / screen background |
| `surface` | `#0d0d0d` | Card, panel, overlay card |
| `input` | `#111111` | Text field, button background |
| `inputHover` | `#141414` | Selected list item bg |
| `border` | `#1a1a1a` | Default border |
| `borderFocus` | `#333333` | Focused border (bar-level, subtle) |
| `borderActive` | `#ffffff` | Focused border (overlay-level, prominent) |
| `borderError` | `#cc3333` | Auth failure, validation error |
| `textPrimary` | `#ffffff` | Main text, selected items |
| `textSecondary` | `#999999` | Bar title, subtitles |
| `textMuted` | `#666666` | Unselected list items |
| `textDim` | `#333333` | Placeholders, field labels |
| `textLabel` | `#2a2a2a` | Uppercase section labels |
| `textError` | `#cc3333` | Error messages |

### Typography

| Token | Value | Usage |
|---|---|---|
| `font` | `JetBrainsMono Nerd Font` | All surfaces |
| `fontXs` | `10px` | Uppercase spaced labels (`USERNAME`) |
| `fontSm` | `11px` | Bar text |
| `fontBase` | `12px` | Launcher list items |
| `fontMd` | `13px` | Launcher search input |
| `fontLg` | `14px` | SDDM inputs, overlay text |
| `fontXl` | `20px` | Section headings |

### Geometry

| Token | Value | Usage |
|---|---|---|
| `radiusSm` | `3px` | Launcher card |
| `radiusMd` | `6px` | Input fields, buttons |
| `radiusLg` | `8px` | SDDM card |
| `fieldHeight` | `52px` | Overlay inputs (SDDM) |
| `barHeight` | `30px` | Top bar |

---

## Components

### Top Bar — `Bar.qml`

```
[window title ···············] [1 2 3 4] [··· HH:mm ddd d MMM]
```

- `PanelWindow`, anchored top/left/right, 30px tall, pure black bg
- Title: left-anchored, capped at `width/3`, `textSecondary`
- Workspaces: `anchors.centerIn` (never jumps when title changes), dot indicator on focused
- Clock: right-anchored, time in `textPrimary`, date in `textMuted`
- Configs button: single gear glyph () between workspaces and clock, toggles the Configs Terminal (see below)

### Configs Terminal — `master.kdl` (zellij layout)

- Not a QML surface — a real Wayland client: `kitty --class quickshell-configs` running `zellij attach quickshell-configs --create --default-layout ~/.config/quickshell/master.kdl`
- Fixed 6-pane zellij layout: playerctl TUI + wiremix + power menu (top row; power menu is itself split top/bottom into power actions and a Dark/Light/Auto theme picker), bluetui + impala (bottom row)
- Theme picker (`scripts/theme-picker.fish`) is an fzf menu that calls `qs ipc call theme set <dark|light|auto>`, handled by the `theme` `IpcHandler` in `shell.qml`, which sets `Theme.mode` live
- Hyprland window rule: floating, centered, `1200×800` — one persistent instance, created at Hyprland startup
- Lives on `special:configs` (hidden) until toggled; gear button and `SUPER+C` both run `scripts/configs.fish toggle`, which moves it to the active workspace (and focuses it) or back to `special:configs` (rebuilding the session from scratch in the background so every pane resets). Hyprland startup runs `scripts/configs.fish start` to spawn the first instance.

### App Launcher — `Launcher.qml`

- `PanelWindow`, fullscreen overlay, `WlrLayer.Overlay`, `WlrKeyboardFocus.Exclusive`
- Backdrop: `#e5000000` (90% black), click-outside to dismiss
- Card: `580×480px` max, `surface` bg, `radiusSm` corner, `border` outline
- Search: `46px` tall, separator line at bottom, placeholder in `textDim`
- List: apps sorted A–Z, filtered live; `36px` rows; selected = `inputHover` bg + `2px textPrimary` left accent
- Scroll: `WheelHandler` with `angleDelta.y * 3` multiplier; `highlightMoveDuration: 0` for instant arrow-key scroll
- Keys: `↑↓` navigate, `Enter` launch, `Esc` close

### Login Screen — `sddm/shadcn/Main.qml`

- SDDM QML theme; `Rectangle` root fills screen
- Clock: `120px Font.Thin`, top-right; date `22px Font.Light` below
- Card: `520px` wide, `radiusLg`, `surface` bg
- Fields: `52px` height, `radiusMd`, `borderActive` on focus, `borderError` on failure
- Password: `font.letterSpacing: 6`, `••••••••` placeholder
- Submit: Enter on password field or "Sign in →" button
- Auth: `sddm.login(username, password, sessionIndex)` → `onLoginFailed` shows error + retries

---

## File Map

| File | Surface | Runtime |
|---|---|---|
| `~/.config/quickshell/Theme.qml` | Token source | QuickShell |
| `~/.config/quickshell/Bar.qml` | Top bar | QuickShell |
| `~/.config/quickshell/Launcher.qml` | App launcher | QuickShell |
| `~/.config/quickshell/shell.qml` | Root wiring (bar+launcher+lock+IPC) | QuickShell |
| `~/.config/quickshell/master.kdl` | Configs terminal | zellij (inside a kitty window managed by Hyprland) |
| `/usr/share/sddm/themes/shadcn/Main.qml` | Login screen | SDDM |

---

## Updating Tokens

1. Edit `Theme.qml` — QuickShell picks up changes on restart (`pkill quickshell && quickshell &`)
2. Mirror the changed value in the `// shadcn design tokens` comment header of `Main.qml`
3. Update the hardcoded literal in `Main.qml` itself (SDDM cannot import the singleton)
