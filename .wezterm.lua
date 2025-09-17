local wezterm = require 'wezterm'

return {
  -- Font
  font = wezterm.font_with_fallback {
    "Hack Nerd Font Mono",
    "SF Mono", -- native macOS system monospace
  },
  font_size = 14.0,

  -- Colorscheme
  color_scheme = "Afterglow",

  -- Cursor
  default_cursor_style = "SteadyBlock",

  -- Tabs
  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = false, -- minimal tab bar, no fluff

  -- Keybindings
  keys = {
    -- Cycle tabs with Cmd+Opt+Left/Right
    { key = "LeftArrow", mods = "CMD|OPT", action = wezterm.action{ActivateTabRelative=-1} },
    { key = "RightArrow", mods = "CMD|OPT", action = wezterm.action{ActivateTabRelative=1} },

    -- Direct tab jumps with Cmd+Opt+[number]
    { key = "1", mods = "CMD|OPT", action = wezterm.action{ActivateTab=0} },
    { key = "2", mods = "CMD|OPT", action = wezterm.action{ActivateTab=1} },
    { key = "3", mods = "CMD|OPT", action = wezterm.action{ActivateTab=2} },
    { key = "4", mods = "CMD|OPT", action = wezterm.action{ActivateTab=3} },
    { key = "5", mods = "CMD|OPT", action = wezterm.action{ActivateTab=4} },
    { key = "6", mods = "CMD|OPT", action = wezterm.action{ActivateTab=5} },
    { key = "7", mods = "CMD|OPT", action = wezterm.action{ActivateTab=6} },
    { key = "8", mods = "CMD|OPT", action = wezterm.action{ActivateTab=7} },
    { key = "9", mods = "CMD|OPT", action = wezterm.action{ActivateTab=8} },

    -- Claude wants this
    { key = "Enter", mods = "SHIFT", action = wezterm.action{SendString="\x1b\r"} },
  },

  -- Performance tweaks
  animation_fps = 1,          -- disables cursor blink animations etc.
  front_end = "WebGpu",       -- ensures GPU acceleration
  warn_about_missing_glyphs = false, -- avoid annoying logs
  audible_bell = "Disabled",  -- silence
}
