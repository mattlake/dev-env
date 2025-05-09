local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action
local config = wezterm.config_builder()

wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

-- All config changes go here

config.color_scheme = "Tokyo Night Moon"
config.font = wezterm.font("JetBrains Mono")
config.window_decorations = "RESIZE"
config.use_dead_keys = false
config.disable_default_key_bindings = true
config.use_fancy_tab_bar = true
config.switch_to_last_active_tab_when_closing_tab = true

-- Keymaps
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 2000 }

config.keys = {
	{ key = "l", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
	{ key = "h", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = "l", mods = "CTRL", action = act.ActivatePaneDirection("Right") },
	{ key = "h", mods = "CTRL", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CTRL", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CTRL", action = act.ActivatePaneDirection("Up") },
	{ key = "f", mods = "CTRL", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "CTRL", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "t", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "CTRL", action = act.CloseCurrentTab({ confirm = false }) },
	{ key = "x", mods = "CTRL", action = act.CloseCurrentPane({ confirm = false }) },

	{ key = "v", mods = "LEADER", action = act.ActivateCopyMode },

	-- method to rename tabs with CTRL r
	{
		key = "r",
		mods = "CTRL",
		action = act.PromptInputLine({
			description = "Enter name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
}

-- return the config
return config
