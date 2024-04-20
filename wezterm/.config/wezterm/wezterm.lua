local wezterm = require('wezterm')
local act = wezterm.action

-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
local function get_appearance()
    if wezterm.gui then
        return wezterm.gui.get_appearance()
    end
    return 'Light'
end

local function scheme_for_appearance(appearance)
    if appearance:find('Dark') then
        -- return 'Tokyo Night Storm (Gogh)'
        -- return 'One Dark (Gogh)'
        return 'OneDark (base16)'
    else
        return 'One Light (base16)'
    end
end

return {
    audible_bell = 'Disabled',
    font = wezterm.font('JetBrains Mono'),
    font_size = 12.0,
    color_scheme = scheme_for_appearance(get_appearance()),
    tab_bar_at_bottom = true,
    enable_tab_bar = false,
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
    visual_bell = {
        fade_in_function = 'EaseIn',
        fade_in_duration_ms = 75,
        fade_out_function = 'EaseOut',
        fade_out_duration_ms = 75,
    },
    background = {
        -- This is the deepest/back-most layer. It will be rendered first
        {
            source = {
                File = '/home/denis/dotfiles/assets/wallpaper.jpg',
            },
            -- The texture tiles vertically but not horizontally.
            -- When we repeat it, mirror it so that it appears "more seamless".
            -- An alternative to this is to set `width = "100%"` and have
            -- it stretch across the display
            repeat_x = 'Mirror',
            -- hsb = { brightness = 0.1 },
            -- When the viewport scrolls, move this layer 10% of the number of
            -- pixels moved by the main viewport. This makes it appear to be
            -- further behind the text.
            attachment = { Parallax = 0.1 },
        },
    },
    colors = {
        visual_bell = '#202020',
    },
    keys = {
        {
            key = 'k',
            mods = 'CMD',
            action = act.Multiple({
                -- act.SendKey { key = 'l', mods = 'CTRL' },
                act.ClearScrollback('ScrollbackAndViewport'),
            }),
        },
        {
            key = 'k',
            mods = 'CTRL|SHIFT',
            action = act.Multiple({
                -- act.SendKey { key = 'l', mods = 'CTRL' },
                act.ClearScrollback('ScrollbackAndViewport'),
            }),
        },
    },
}
