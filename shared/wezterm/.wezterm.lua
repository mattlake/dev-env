local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action
local config = wezterm.config_builder()

-- ============================================================================
-- GUI STARTUP
-- ============================================================================
wezterm.on("gui-startup", function()
    local tab, pane, window = mux.spawn_window({})
    -- window:gui_window():maximize()
end)

-- ============================================================================
-- APPEARANCE
-- ============================================================================
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
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
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.tab_max_width = 32
config.show_new_tab_button_in_tab_bar = false

-- ============================================================================
-- BEHAVIOR
-- ============================================================================
config.scrollback_lines = 10000
config.enable_scroll_bar = false
config.audible_bell = "Disabled"
config.default_prog = { "wsl", "-d", "Ubuntu-24.04", "--cd", "~" }
-- config.default_prog = { "pwsh", "-NoLogo" }
-- config.default_domain = 'WSL:Ubuntu_24.04'
config.use_dead_keys = false
config.disable_default_key_bindings = true
config.switch_to_last_active_tab_when_closing_tab = true

-- ============================================================================
-- LEADER KEY
-- ============================================================================
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 2000 }

-- ============================================================================
-- KEYBINDINGS
-- ============================================================================
config.keys = {
    -- ========================================================================
    -- TABS (tmux-style: prefix + key)
    -- ========================================================================
    { key = "c", mods = "LEADER",       action = act.SpawnTab("CurrentPaneDomain") },
    { key = "q", mods = "LEADER",       action = act.CloseCurrentTab({ confirm = true }) },
    { key = "p", mods = "LEADER",       action = act.ActivateTabRelative(-1) },
    { key = "n", mods = "LEADER",       action = act.ActivateTabRelative(1) },

    -- Rename tab (tmux: prefix + ,)
    {
        key = ",",
        mods = "LEADER",
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
    -- phys: matches the physical key position, so Shift turning "2" into a
    -- punctuation character on the active layout doesn't break the binding
    { key = "phys:1",   mods = "LEADER", action = act.ActivateTab(0) },
    { key = "phys:2",   mods = "LEADER", action = act.ActivateTab(1) },
    { key = "phys:3",   mods = "LEADER", action = act.ActivateTab(2) },
    { key = "phys:4",   mods = "LEADER", action = act.ActivateTab(3) },
    { key = "phys:5",   mods = "LEADER", action = act.ActivateTab(4) },
    { key = "phys:6",   mods = "LEADER", action = act.ActivateTab(5) },
    { key = "phys:7",   mods = "LEADER", action = act.ActivateTab(6) },
    { key = "phys:8",   mods = "LEADER", action = act.ActivateTab(7) },
    { key = "phys:9",   mods = "LEADER", action = act.ActivateTab(8) },

    -- ========================================================================
    -- PANES / SPLITS
    -- ========================================================================
    -- Window ops mirror nvim's <leader>w group: prefix + w, then v/h/x
    {
        key = "w",
        mods = "LEADER",
        action = act.ActivateKeyTable({
            name = "window_ops",
            one_shot = true,
            timeout_milliseconds = 1500,
        }),
    },

    -- Navigate between panes (prefix + hjkl; plain Ctrl+hjkl now passes
    -- through to nvim for its window navigation)
    { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

    -- Toggle pane zoom (tmux: prefix + z)
    { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

    -- ========================================================================
    -- COPY / PASTE
    -- ========================================================================
    { key = "c",        mods = "CMD",        action = act.CopyTo("ClipboardAndPrimarySelection") },
    { key = "v",        mods = "CMD",        action = act.PasteFrom("Clipboard") },

    -- Copy mode with leader key (v ≈ vim visual mode)
    { key = "v",        mods = "LEADER",     action = act.ActivateCopyMode },

    -- Quick select mode (keyboard-driven text selection, great for URLs)
    { key = "Space",    mods = "LEADER",     action = act.QuickSelect },

    -- ========================================================================
    -- FONT SIZE
    -- ========================================================================
    { key = "=",        mods = "CTRL",       action = act.IncreaseFontSize },
    { key = "-",        mods = "CTRL",       action = act.DecreaseFontSize },
    { key = "0",        mods = "CTRL",       action = act.ResetFontSize },

    -- ========================================================================
    -- SEARCH & NAVIGATION
    -- ========================================================================
    -- Search terminal output (/ ≈ vim search)
    { key = "/",        mods = "LEADER",       action = act.Search({ CaseSensitiveString = "" }) },

    -- Command palette (tmux: prefix + : for the command prompt)
    { key = ":",        mods = "LEADER|SHIFT", action = act.ActivateCommandPalette },

    -- Scroll up/down
    { key = "PageUp",   mods = "SHIFT",        action = act.ScrollByPage(-1) },
    { key = "PageDown", mods = "SHIFT",        action = act.ScrollByPage(1) },
}

-- Window ops key table: keys match nvim's <leader>w mappings
config.key_tables = {
    window_ops = {
        { key = "v",      action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
        { key = "h",      action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
        { key = "x",      action = act.CloseCurrentPane({ confirm = false }) },
        { key = "Escape", action = "PopKeyTable" },
    },
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

-- Add detection for absolute file paths (useful for error messages)
table.insert(config.hyperlink_rules, {
    regex = "\\b/[\\w\\-\\./]+\\b",
    format = "file://$0",
})

-- ============================================================================
-- TAB BAR CUSTOMIZATION
-- ============================================================================
-- Catppuccin Mocha palette for the tmux-style status bar
local bar_colors = {
    bg = "#1e1e2e",       -- base, matches the Catppuccin Mocha terminal background
    active_bg = "#89b4fa", -- blue
    active_fg = "#11111b", -- crust
    inactive_fg = "#a6adc8", -- subtext0
    mode_idle_bg = "#313244", -- surface0
    mode_idle_fg = "#6c7086", -- overlay0
    leader_bg = "#f9e2af", -- yellow
    copy_bg = "#a6e3a1",  -- green
    search_bg = "#f38ba8", -- red
    window_bg = "#cba6f7", -- mauve
    mode_active_fg = "#11111b", -- crust
}

config.colors = {
    tab_bar = {
        background = bar_colors.bg,
    },
}

-- tmux-style tabs: `1:title*` for the active tab, `1:title` for the rest
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    -- Prefer an explicit rename (set via Ctrl+Shift+R), fall back to the pane title
    local title = tab.tab_title
    if title == nil or #title == 0 then
        title = tab.active_pane.title
    end
    local index = tab.tab_index + 1

    if tab.is_active then
        return {
            { Background = { Color = bar_colors.active_bg } },
            { Foreground = { Color = bar_colors.active_fg } },
            { Text = " " .. index .. ":" .. title .. "* " },
        }
    end
    return {
        { Background = { Color = bar_colors.bg } },
        { Foreground = { Color = bar_colors.inactive_fg } },
        { Text = " " .. index .. ":" .. title .. "  " },
    }
end)

-- Mode indicator bottom-left (like tmux's prefix highlight):
-- dim when idle, yellow while the leader is armed, green/red in copy/search mode
wezterm.on("update-status", function(window, pane)
    local text = "      "
    local bg = bar_colors.mode_idle_bg
    local fg = bar_colors.mode_idle_fg

    if window:leader_is_active() then
        text = "  ^B  "
        bg = bar_colors.leader_bg
        fg = bar_colors.mode_active_fg
    else
        local key_table = window:active_key_table()
        if key_table == "copy_mode" then
            text = " COPY "
            bg = bar_colors.copy_bg
            fg = bar_colors.mode_active_fg
        elseif key_table == "search_mode" then
            text = " SRCH "
            bg = bar_colors.search_bg
            fg = bar_colors.mode_active_fg
        elseif key_table == "window_ops" then
            text = " WIN  "
            bg = bar_colors.window_bg
            fg = bar_colors.mode_active_fg
        end
    end

    window:set_left_status(wezterm.format({
        { Background = { Color = bg } },
        { Foreground = { Color = fg } },
        { Text = text },
    }))
    window:set_right_status("")
end)

-- ============================================================================
-- LOCAL OVERRIDES
-- ============================================================================
-- Machine-specific setup -- project launchers, work paths, per-host tweaks --
-- belongs outside version control. Drop a ~/.wezterm.local.lua that returns
-- nothing and mutates what it is handed:
--
--   return function(config, wezterm, act)
--     wezterm.on("my-event", function(window, pane) ... end)
--     table.insert(config.keys, { key = "o", mods = "LEADER",
--                                 action = act.EmitEvent("my-event") })
--   end
--
-- Absent file is not an error; this config is expected to work without one.
local home = os.getenv("HOME") or os.getenv("USERPROFILE")
if home then
    local local_path = home .. "/.wezterm.local.lua"
    local chunk, load_err = loadfile(local_path)
    if chunk then
        local ok, result = pcall(chunk)
        if ok and type(result) == "function" then
            local applied, apply_err = pcall(result, config, wezterm, act)
            if not applied then
                wezterm.log_error("wezterm.local.lua raised: " .. tostring(apply_err))
            end
        elseif not ok then
            wezterm.log_error("wezterm.local.lua raised: " .. tostring(result))
        end
    elseif load_err and not load_err:match("No such file") then
        wezterm.log_error("wezterm.local.lua is unreadable: " .. tostring(load_err))
    end
end

-- ============================================================================
-- RETURN CONFIG
-- ============================================================================
return config
