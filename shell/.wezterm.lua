local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action
local config = wezterm.config_builder()

-- ============================================================================
-- GUI STARTUP
-- ============================================================================
wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

-- ============================================================================
-- APPEARANCE
-- ============================================================================
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("JetBrains Mono")
config.font_size = 13.0

-- Window decorations: NONE = completely hidden title bar
config.window_decorations = "RESIZE"

-- Window padding for cleaner look
config.window_padding = {
	left = 16,
	right = 16,
	top = 16,
	bottom = 16,
}

-- Dim inactive panes slightly for visual clarity
config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.7,
}

-- Tab bar
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

-- ============================================================================
-- BEHAVIOR
-- ============================================================================
config.scrollback_lines = 10000
config.enable_scroll_bar = false
config.audible_bell = "Disabled"
config.use_dead_keys = false
config.disable_default_key_bindings = true
config.switch_to_last_active_tab_when_closing_tab = true

-- ============================================================================
-- LEADER KEY
-- ============================================================================
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 2000 }

-- ============================================================================
-- KEYBINDINGS
-- ============================================================================
config.keys = {
	-- ========================================================================
	-- TABS
	-- ========================================================================
	{ key = "t", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = false }) },
	{ key = "h", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = "l", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },

	-- Rename tab (changed from Ctrl+r to avoid shell conflict)
	{
		key = "r",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = "Enter name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- Jump to specific tab by number
	{ key = "1", mods = "CTRL|SHIFT", action = act.ActivateTab(0) },
	{ key = "2", mods = "CTRL|SHIFT", action = act.ActivateTab(1) },
	{ key = "3", mods = "CTRL|SHIFT", action = act.ActivateTab(2) },
	{ key = "4", mods = "CTRL|SHIFT", action = act.ActivateTab(3) },
	{ key = "5", mods = "CTRL|SHIFT", action = act.ActivateTab(4) },
	{ key = "6", mods = "CTRL|SHIFT", action = act.ActivateTab(5) },
	{ key = "7", mods = "CTRL|SHIFT", action = act.ActivateTab(6) },
	{ key = "8", mods = "CTRL|SHIFT", action = act.ActivateTab(7) },
	{ key = "9", mods = "CTRL|SHIFT", action = act.ActivateTab(8) },

	-- ========================================================================
	-- PANES / SPLITS
	-- ========================================================================
	-- Split right (vertical split) - creates new pane on the right
	{ key = "r", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	-- Split down (horizontal split) - creates new pane below
	{ key = "d", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Navigate between panes (vim-style hjkl)
	{ key = "h", mods = "CTRL", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CTRL", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CTRL", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CTRL", action = act.ActivatePaneDirection("Right") },

	-- Close current pane (changed from Ctrl+x to avoid shell conflict)
	{ key = "x", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },

	-- Toggle pane zoom (maximize/restore current pane)
	{ key = "z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },

	-- ========================================================================
	-- COPY / PASTE
	-- ========================================================================
	-- macOS standard shortcuts (changed from Ctrl to avoid shell conflicts)
	{ key = "c", mods = "CMD", action = act.CopyTo("ClipboardAndPrimarySelection") },
	{ key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },

	-- Copy mode with leader key
	{ key = "v", mods = "LEADER", action = act.ActivateCopyMode },

	-- Quick select mode (keyboard-driven text selection, great for URLs)
	{ key = "Space", mods = "CTRL|SHIFT", action = act.QuickSelect },

	-- ========================================================================
	-- FONT SIZE
	-- ========================================================================
	{ key = "=", mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = act.ResetFontSize },

	-- ========================================================================
	-- SEARCH & NAVIGATION
	-- ========================================================================
	-- Search terminal output
	{ key = "f", mods = "CTRL|SHIFT", action = act.Search({ CaseSensitiveString = "" }) },

	-- Command palette
	{ key = "p", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },

	-- Scroll up/down
	{ key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-1) },
	{ key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },
}

-- ============================================================================
-- MOUSE BINDINGS
-- ============================================================================
config.mouse_bindings = {
	-- Open URLs/hyperlinks with Cmd+Click (macOS standard)
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CMD",
		action = act.OpenLinkAtMouseCursor,
	},

	-- Alternative: Ctrl+Click for cross-platform consistency
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},

	-- Right-click paste
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = act.PasteFrom("Clipboard"),
	},

	-- Select word on double-click
	{
		event = { Up = { streak = 2, button = "Left" } },
		mods = "NONE",
		action = act.SelectTextAtMouseCursor("Word"),
	},

	-- Select line on triple-click
	{
		event = { Up = { streak = 3, button = "Left" } },
		mods = "NONE",
		action = act.SelectTextAtMouseCursor("Line"),
	},
}

-- ============================================================================
-- HYPERLINK DETECTION
-- ============================================================================
-- Start with WezTerm's default rules (http://, https://, file://, etc.)
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Add JIRA ticket detection
-- TODO: Update the format URL with your JIRA instance
-- Example: "https://company.atlassian.net/browse/$0"
-- Example: "https://jira.company.com/browse/$0"
table.insert(config.hyperlink_rules, {
	-- Matches patterns like: PROJ-123, DEV-456, BUG-789
	-- TODO: Optionally restrict to specific project keys by changing the regex
	-- Example: regex = "\\b(PROJ|DEV|BUG)-[0-9]+\\b" for specific projects
	regex = "\\b[A-Z]+-[0-9]+\\b",
	format = "https://YOUR-JIRA-INSTANCE.atlassian.net/browse/$0",
})

-- Add detection for absolute file paths (useful for error messages)
table.insert(config.hyperlink_rules, {
	regex = "\\b/[\\w\\-\\./]+\\b",
	format = "file://$0",
})

-- ============================================================================
-- TAB BAR CUSTOMIZATION
-- ============================================================================
-- Format tab titles to show index numbers (useful for Ctrl+Shift+{N} shortcuts)
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab.active_pane.title
	local index = tab.tab_index + 1

	-- Show tab number and title
	return {
		{ Text = " " .. index .. ": " .. title .. " " },
	}
end)

-- ============================================================================
-- RETURN CONFIG
-- ============================================================================
return config
