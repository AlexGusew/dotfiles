require("monitors")

hl.monitor({ output = "", mode = "highrr", position = "auto", scale = "auto" })

--------------------
---- MY PROGRAMS ----
--------------------

local terminal = "kitty"
local fileManager = "kitty -e yazi"
local menu = "wofi --show drun"
local browser = "firefox"
local appLauncher = "kitty --single-instance --class cliphist-fzf --hold=no -e ~/.config/hypr/app-launcher.fish"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("kitty --class kitty-bg --start-as=hidden")
	hl.exec_cmd(terminal)
	hl.exec_cmd(browser)
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("systemctl --user start graphical-session.target")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("blueman-applet")
	hl.exec_cmd("hyprsunset")
	hl.exec_cmd("quickshell")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("~/.config/hypr/build-app-cache.fish")
	hl.exec_cmd("snappy-switcher --daemon")
end)

-----------------------------
---- ENVIRONMENT VARIABLES ----
-----------------------------

hl.env("LIBVA_DRIVER_NAME", "iHD")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "mesa")
hl.env("XFT_FONT", "NotoSans Nerd Font")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "x11")
hl.env("ELECTRON_OZONE_PLATFORM", "wayland")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "0")
hl.env("QT_SCALE_FACTOR", "1.5")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("WLR_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card0")
hl.env("AQ_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card0")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 20,
		border_size = 2,
		col = {
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},
		resize_on_border = false,
		layout = "master",
		allow_tearing = true,
	},
})

hl.config({
	decoration = {
		rounding = 10,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = false,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		blur = {
			enabled = false,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},
})

hl.config({
	animations = { enabled = true },
})

-- Curves and animations (effective when animations.enabled = true)
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

-- Smart gaps
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })

hl.config({
	dwindle = { preserve_split = true },
})

hl.config({
	master = {
		new_status = "slave",
		mfact = 0.65,
	},
})

hl.config({
	misc = {
		force_default_wallpaper = 1,
		disable_hyprland_logo = true,
		middle_click_paste = true,
	},
})

hl.config({
	xwayland = { force_zero_scaling = true },
})

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us,ru",
		kb_options = "grp:alt_shift_toggle",
		follow_mouse = 1,
		repeat_rate = 45,
		repeat_delay = 200,
		natural_scroll = true,
		accel_profile = "adaptive",
		sensitivity = -0.0,
		touchpad = {
			natural_scroll = true,
			-- accel_speed = 1,
			tap_to_click = true,
			tap_and_drag = true,
			drag_lock = false,
			disable_while_typing = true,
			clickfinger_behavior = true,
			middle_button_emulation = false,
			scroll_factor = 0.2,
		},
	},
})

hl.device({
	name = "logitech-g-pro--3",
	sensitivity = -0.7,
})

------------------
---- GESTURES ----
------------------

-- 3-finger swipe left/right: switch workspace (macOS: swipe between spaces)
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- 3-finger swipe up: fullscreen active window (closest to macOS Mission Control; Hyprland has no overview)
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })

-- 3-finger swipe down: toggle scratchpad (macOS: show desktop / App Exposé)
hl.gesture({ fingers = 3, direction = "down", action = "special", workspace_name = "magic" })

-- 2-finger pinch: continuous zoom into cursor (macOS: Accessibility trackpad zoom)
hl.gesture({ fingers = 2, direction = "pinch", action = "cursor_zoom", zoom_level = 1, mode = "live" })

-- 4-finger pinch in: open app launcher (macOS: Launchpad)
hl.gesture({
	fingers = 4,
	direction = "pinchin",
	action = function()
		hl.exec_cmd(appLauncher)
	end,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(appLauncher))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + backslash", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Move focus (vim-style)
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Workspace navigation (SUPER+ALT+h/l)
hl.bind(mainMod .. " + ALT + H", hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. " + ALT + L", hl.dsp.focus({ workspace = "+1" }))

-- Switch workspaces (6 intentionally skipped, matching original)
for i = 1, 5 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
end
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- Move windows to workspaces
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Clipboard picker
hl.bind(
	mainMod .. " + CTRL + V",
	hl.dsp.exec_cmd("kitty --class cliphist-fzf --hold=no -e ~/Projects/clipfzf/clipfzf.fish")
)

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Middle click: clear clipboard
hl.bind("mouse:274", hl.dsp.exec_cmd("wl-copy -pc"))

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd("grimblast --freeze copy area"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("grimblast --freeze copysave area"))

-- Volume / brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Media
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Snappy Switcher
hl.bind("ALT + Tab", hl.dsp.exec_cmd("snappy-switcher next --mod alt"))
hl.bind("SUPER + Tab", hl.dsp.exec_cmd("snappy-switcher next --workspace --mod super"))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
	name = "fix-xwayland-drags",
	match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
	no_focus = true,
})

hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },
	move = "20 monitor_h-120",
	float = true,
})

hl.window_rule({
	name = "floating-nautilus",
	match = { class = "^(org.gnome.Nautilus)$" },
	float = true,
})

hl.window_rule({
	name = "floating-google",
	match = { title = "Sign in - Google Accounts" },
	float = true,
})

hl.window_rule({
	name = "termshell-panel-style",
	match = { class = "^(termshell-panel)$" },
	border_size = 0,
	rounding = 0,
})

hl.window_rule({
	name = "clipboard",
	match = { class = "^(cliphist-fzf)|(kitty-bg)$" },
	float = true,
	center = true,
	size = "800 700",
})

hl.window_rule({
	name = "pip-pin",
	match = { title = "^Picture-in-Picture$" },
	float = true,
	pin = true,
	move = "monitor_w-370 monitor_h-220",
	size = "350 200",
})
