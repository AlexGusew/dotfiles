require("monitors")

hl.monitor({ output = "", mode = "highrr", position = "auto", scale = "auto" })

--------------------
---- MY PROGRAMS ----
--------------------

local terminal = "kitty"
local fileManager = "kitty -e yazi"
local menu = "wofi --show drun"
local browser = "firefox"
local appLauncher = "fish ~/.config/hypr/app-launcher-toggle.fish"

-----------------------------------
---- SAKURA LIVE WALLPAPER ----
-----------------------------------

-- nsakura live wallpaper: true wlr-layer-shell background panel (kitten
-- panel), one per monitor -- not a managed window, so no window rule needed.
-- Colors are synced live to the light/dark toggle by Theme.qml. Lifecycle is
-- driven by monitor.added/monitor.removed below so it follows hotplug.
local WALLPAPER_BIN = "/home/alex/.local/bin/nsakura --sway=0.35"

-- Idempotent: kill any existing wallpaper instance for this monitor name,
-- clean up its socket, and (if spawn) launch a fresh one. Safe to call
-- repeatedly for the same name -- used from boot, monitor.added, and
-- monitor.removed alike, so there's one code path instead of three.
local function sakura_wallpaper_cmd(name, spawn)
	local sock = "/tmp/kitty-bg-" .. name .. ".sock"
	-- Find the kitty process by who has the socket file open (`fuser`), not
	-- by matching its command line (`pgrep -f`) -- the latter self-matches,
	-- because hl.exec_cmd runs this whole string through a shell whose own
	-- command line then also contains the search pattern, causing the loop
	-- to kill its own invoking shell before ever reaching `kitten panel`
	-- (confirmed empirically). nsakura is its own session leader (confirmed
	-- via `ps`), so it won't die from kitty's pty closing -- reap it via
	-- `pgrep -P` (by pid, not text, so it can't self-match either) before
	-- killing the kitty parent.
	local cmd = "for cpid in $(fuser "
		.. sock
		.. " 2>/dev/null); do "
		.. "for gpid in $(pgrep -P $cpid); do kill $gpid 2>/dev/null; done; "
		.. "kill $cpid 2>/dev/null; done; rm -f "
		.. sock

	if spawn then
		-- Resolve current theme colors at spawn time instead of hardcoding a
		-- dark default -- mirrors Theme.qml's own mode resolution exactly
		-- (mode file, falling back to gsettings color-scheme for "auto") so a
		-- hotplugged or first-boot monitor never flashes the wrong colors
		-- while waiting for the next theme toggle to correct it.
		local colorPick = "mode=$(cat ~/.config/quickshell/theme-mode.txt 2>/dev/null | tr -d '[:space:]'); "
			.. 'if [ "$mode" = light ]; then dark=0; '
			.. 'elif [ "$mode" = dark ]; then dark=1; '
			.. "else scheme=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null); "
			.. 'case "$scheme" in *dark*) dark=1 ;; *) dark=0 ;; esac; fi; '
			.. 'if [ "$dark" = 1 ]; then bg=#000000; fg=#ffffff; else bg=#ffffff; fg=#000000; fi; '

		-- Small delay: monitor.added can fire before the output is fully
		-- ready for a layer-shell client to bind to (confirmed empirically --
		-- the exact same command run a moment later by hand works fine).
		cmd = cmd
			.. "; sleep 0.5; "
			.. colorPick
			.. "kitten panel --edge=background --output-name="
			.. name
			.. " --app-id=kitty-bg-"
			.. name
			.. " -o allow_remote_control=yes --listen-on=unix:"
			.. sock
			.. ' -o background="$bg" -o foreground="$fg"'
			.. " -- "
			.. WALLPAPER_BIN
	end

	hl.exec_cmd(cmd)
end

local function sakura_wallpaper_start(name)
	sakura_wallpaper_cmd(name, true)
end
local function sakura_wallpaper_stop(name)
	sakura_wallpaper_cmd(name, false)
end

hl.on("monitor.added", function(mon)
	if mon and mon.name and mon.name ~= "" then
		sakura_wallpaper_start(mon.name)
	end
end)

hl.on("monitor.removed", function(mon)
	if mon and mon.name and mon.name ~= "" then
		sakura_wallpaper_stop(mon.name)
	end
end)

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	for _, mon in ipairs(hl.get_monitors()) do
		sakura_wallpaper_start(mon.name)
	end
	hl.exec_cmd(terminal)
	hl.exec_cmd(browser)
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("systemctl --user start graphical-session.target")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("blueman-applet")
	hl.exec_cmd("hyprsunset")
	hl.exec_cmd("quickshell")
	hl.exec_cmd("fish /home/alex/.config/quickshell/scripts/configs.fish start")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("~/.config/hypr/build-app-cache.fish")
	-- hl.exec_cmd("snappy-switcher --daemon")
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
		gaps_in = 2,
		gaps_out = 8,
		border_size = 2,
		col = {
			active_border = "rgba(888888ff)",
			inactive_border = "rgba(00000000)",
		},
		resize_on_border = true,
		layout = "master",
		allow_tearing = false,
	},
})

-- hl.config({
-- 	decoration = {
-- 		-- rounding = 10,
-- 		-- rounding_power = 2,
-- 		active_opacity = 1.0,
-- 		inactive_opacity = 1.0,
-- 		blur = {
-- 			enabled = false,
-- 			size = 3,
-- 			passes = 1,
-- 			vibrancy = 0.1696,
-- 		},
-- 	},
-- })

hl.config({
	decoration = {
		shadow = { enabled = false },
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
-- One 360deg sweep of the active border's gradient when a window takes focus:
-- the bright end travels around the window once and settles back at 45deg.
hl.animation({ leaf = "borderangle", enabled = true, speed = 9, bezier = "easeOutQuint", style = "once" })
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

-- Smart gaps -- and, for the same reason, no border: a lone tiled window or a
-- fullscreen one has nothing to be distinguished from, so it goes edge to edge.
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0, border_size = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0, border_size = 0 })

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
			drag_lock = 2,
			disable_while_typing = true,
			clickfinger_behavior = true,
			middle_button_emulation = false,
			scroll_factor = 0.3,
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
hl.gesture({
	scale = 0.3,
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- 3-finger swipe up: fullscreen active window (closest to macOS Mission Control; Hyprland has no overview)
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })

-- 3-finger swipe down: toggle scratchpad (macOS: show desktop / App Exposé)
hl.gesture({ fingers = 3, direction = "down", action = "special", workspace_name = "magic" })

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
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("fish /home/alex/.config/quickshell/scripts/configs.fish toggle"))
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
	hl.dsp.exec_cmd("kitty --single-instance --class cliphist-fzf --hold=no -e ~/Projects/clipfzf/clipfzf.fish")
)

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

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
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("~/.config/hypr/brightness.fish +5"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("~/.config/hypr/brightness.fish -5"),
	{ locked = true, repeating = true }
)

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
	name = "floating-bitwarden",
	match = { title = "^Extension: \\(Bitwarden Password Manager\\).*$" },
	float = true,
})

-- windowrulev1-style title match doesn't re-eval after Firefox extension
-- popups rename themselves post-map, so float them on the title change event
hl.on("window.title", function(win)
	if win and win.title and win.title:match("^Extension: %(Bitwarden Password Manager%)") and not win.floating then
		hl.dispatch(hl.dsp.window.float({ action = "on", window = "address:" .. win.address }))
		hl.dispatch(hl.dsp.window.resize({ x = 600, y = 600, window = "address:" .. win.address }))
		hl.dispatch(hl.dsp.window.center({ window = "address:" .. win.address }))
	end
end)

hl.window_rule({
	name = "termshell-panel-style",
	match = { class = "^(termshell-panel)$" },
	border_size = 0,
	rounding = 0,
})

hl.window_rule({
	name = "clipboard",
	match = { class = "^(cliphist-fzf)$" },
	float = true,
	center = true,
	size = "800 700",
})

hl.window_rule({
	name = "quickshell-configs",
	match = { class = "^(quickshell-configs)$" },
	float = true,
	center = true,
	dim_around = true,
	size = "1200 1000",
	workspace = "special:configs silent",
})

hl.window_rule({
	name = "pip-pin",
	match = { title = "^Picture-in-Picture$" },
	float = true,
	pin = true,
	move = "monitor_w-370 monitor_h-220",
	size = "350 200",
})

