local wezterm = require 'wezterm'
local mux = wezterm.mux

-- wezterm.on("gui-startup", function()
--   local tab, pane, window = mux.spawn_window(cmd or {})
--   window:gui_window():toggle_fullscreen()
-- end)

return {
  font = wezterm.font("JetBrainsMono Nerd Font"),
  font_size = 20.0,
  -- native_macos_fullscreen_mode = true,
  window_background_opacity = 0.7,
  --
  --
  -- Use GUI startup event to set fullscreen

  -- Optional: hide title bar but allow resizing
  -- window_decorations = "RESIZE",

  -- Set up fullscreen on launch using an event handler
  window_padding = {
    left = 0, right = 0, top = 0, bottom = 0,
  },
}
