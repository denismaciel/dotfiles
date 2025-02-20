-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, 'luarocks.loader')

local utils = require('main.utils')

-- Standard awesome library
local gears = require('gears')
local awful = require('awful')
require('awful.autofocus')
-- Widget and layout library
-- local wibox = require("wibox")
-- Theme handling library
local beautiful = require('beautiful')
-- Notification library
local naughty = require('naughty')

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = 'Oops, there were errors during startup!',
        text = awesome.startup_errors,
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal('debug::error', function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then
            return
        end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = 'Oops, an error happened!',
            text = tostring(err),
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. 'default/theme.lua')

-- This is used later as the default terminal and editor to run.
terminal = 'alacritty'
editor = os.getenv('EDITOR') or 'editor'

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = 'Mod4'

awful.layout.layouts = {
    awful.layout.suit.max,
    awful.layout.suit.tile,
}

awful.screen.connect_for_each_screen(function(s)
    awful.tag({ '1' }, s, awful.layout.layouts[1])
end)
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey }, 'j', function()
        awful.client.focus.byidx(1)
    end, { description = 'focus next by index', group = 'client' }),

    awful.key({ modkey }, 'k', function()
        awful.client.focus.byidx(-1)
    end, { description = 'focus previous by index', group = 'client' }),

    awful.key({ modkey, 'Shift' }, 'j', function()
        awful.client.swap.byidx(1)
    end, { description = 'swap with next client by index', group = 'client' }),

    awful.key(
        { modkey, 'Shift' },
        'k',
        function()
            awful.client.swap.byidx(-1)
        end,
        { description = 'swap with previous client by index', group = 'client' }
    ),

    awful.key({ modkey }, 'w', function()
        awful.screen.focus_relative(1)
    end, { description = 'focus the next screen', group = 'screen' }),

    awful.key({ modkey }, 'Tab', function()
        awful.client.focus.history.previous()
        client.minimized = false
        if client.focus then
            client.focus:raise()
        end
    end, { description = 'go back', group = 'client' }),

    -- Standard program
    awful.key(
        { modkey, 'Control' },
        'r',
        awesome.restart,
        { description = 'reload awesome', group = 'awesome' }
    ),

    awful.key(
        { modkey, 'Shift' },
        'q',
        awesome.quit,
        { description = 'quit awesome', group = 'awesome' }
    ),

    awful.key({ modkey, 'Shift' }, 's', function()
        awful.spawn.with_shell('systemctl suspend && i3lock-fancy-rapid 10 15')
    end, { description = 'sleep & lock', group = 'awesome' }),

    awful.key({ modkey }, 'l', function()
        awful.tag.incmwfact(0.05)
    end, { description = 'increase master width factor', group = 'layout' }),

    awful.key({ modkey }, 'h', function()
        awful.tag.incmwfact(-0.05)
    end, { description = 'decrease master width factor', group = 'layout' }),
    awful.key({ modkey, 'Shift' }, 'h', function()
        awful.tag.incnmaster(1, nil, true)
    end, {
        description = 'increase the number of master clients',
        group = 'layout',
    }),
    awful.key({ modkey, 'Shift' }, 'l', function()
        awful.tag.incnmaster(-1, nil, true)
    end, {
        description = 'decrease the number of master clients',
        group = 'layout',
    }),
    awful.key({ modkey, 'Control' }, 'h', function()
        awful.tag.incncol(1, nil, true)
    end, { description = 'increase the number of columns', group = 'layout' }),
    awful.key({ modkey, 'Control' }, 'l', function()
        awful.tag.incncol(-1, nil, true)
    end, { description = 'decrease the number of columns', group = 'layout' }),
    awful.key({ modkey }, 'v', function()
        awful.layout.inc(1)
    end, { description = 'select next', group = 'layout' }),
    awful.key({ modkey, 'Shift' }, 'space', function()
        awful.layout.inc(-1)
    end, { description = 'select previous', group = 'layout' }),

    awful.key({ modkey }, 'd', function()
        utils.getenv('work_mode')
        utils.toggle_or_spawn(
            'Notebook',
            [[ alacritty --class Notebook -e "env" "MODE=notebook" "nvim" "-c" "lua require(\"dennich\").create_weekly_note()" ]]
        )
    end),

    awful.key({ modkey }, 'x', function()
        utils.toggle_or_spawn('Scratchpad', [[ alacritty --class Scratchpad ]])
    end),

    awful.key({ modkey }, 'f', function()
        utils.toggle_or_spawn('CodeTerminal', 'alacritty --class CodeTerminal')
    end),

    awful.key({ modkey }, 'p', function()
        utils.toggle_or_spawn('Cursor', 'cursor')
    end),

    awful.key({ modkey }, 'g', function()
        utils.focus_or_spawn('Google-chrome', 'google-chrome-stable')
    end),

    -- awful.key({ modkey }, 's', function()
    --     utils.focus_or_spawn('Slack', 'slack')
    -- end),

    awful.key({ modkey }, 'b', function()
        utils.toggle_or_spawn('firefox', 'firefox')
    end),

    awful.key({ modkey }, 'y', function()
        awful.spawn.with_shell('rofi -combi-modi window,run -show combi')
    end),

    awful.key({ modkey }, 'a', function()
        awful.spawn.with_shell('polybar-msg cmd toggle')
    end),

    awful.key({ modkey }, 'c', function()
        awful.util.spawn(
            [[rofi -modi "clipboard:greenclip print" -show clipboard -run-command '{cmd}']]
        )
    end),

    awful.key({ modkey }, 'e', function()
        awful.util.spawn([[ rofi -show emoji -modi emoji ]])
    end),

    awful.key({ modkey }, ';', function()
        for _, c in ipairs(client.get()) do
            naughty.notify({ text = c.class or 'unnamed' })
        end
    end),

    awful.key({ modkey }, 'u', function()
        local current_client = client.focus
        for _, c in ipairs(client.get()) do
            if
                c ~= current_client
                and not string.match(c.name or '', 'polybar')
            then
                c.minimized = true
            end
        end
    end, { description = 'minimize all except current', group = 'client' }),

    awful.key({ modkey }, 'r', function()
        awful.util.spawn(
            [[ alacritty --class FloatThatThing -e sh -c '/home/denis/.local/bin/dennich-todo start-pomodoro' ]]
        )
    end)
)

local clientkeys = gears.table.join(
    awful.key({ modkey }, 'q', function(c)
        c:kill()
    end),
    awful.key(
        { modkey, 'Control' },
        'space',
        awful.client.floating.toggle,
        { description = 'toggle floating', group = 'client' }
    ),
    awful.key({ modkey, 'Control' }, 'Return', function(c)
        c:swap(awful.client.getmaster())
    end, { description = 'move to master', group = 'client' }),
    awful.key({ modkey }, 'o', function(c)
        c:move_to_screen()
    end, { description = 'move to screen', group = 'client' }),
    -- awful.key({ modkey }, 't', function(c)
    --     c.ontop = not c.ontop
    -- end, { description = 'toggle keep on top', group = 'client' }),
    awful.key({ modkey }, 'n', function(c)
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
        c.minimized = true
    end, { description = 'minimize', group = 'client' }),
    awful.key({ modkey }, 'm', function(c)
        c.maximized = not c.maximized
        c:raise()
    end, { description = '(un)maximize', group = 'client' }),
    awful.key({ modkey, 'Control' }, 'm', function(c)
        -- c.maximized_vertical = not c.maximized_vertical
        c.placement = awful.placement.centered
        c:raise()
    end, { description = '(un)maximize vertically', group = 'client' }),
    awful.key({ modkey, 'Shift' }, 'm', function(c)
        c.maximized_horizontal = not c.maximized_horizontal
        c:raise()
    end, { description = '(un)maximize horizontally', group = 'client' })
)

clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal('request::activate', 'mouse_click', { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal('request::activate', 'mouse_click', { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal('request::activate', 'mouse_click', { raise = true })
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

function awful.rules.delayed_properties.delayed_placement(c, value, props) --luacheck: no unused
    if props.delayed_placement then
        awful.rules.extra_properties.placement(
            c,
            props.delayed_placement,
            props
        )
    end
end

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap
                + awful.placement.no_offscreen,
        },
    },

    -- Floating clients.
    {
        rule_any = {
            instance = {
                'DTA', -- Firefox addon DownThemAll.
                'copyq', -- Includes session name in class.
                'pinentry',
            },
            class = {
                'Arandr',
                'Blueman-manager',
                'Gpick',
                'Kruler',
                'MessageWin', -- kalarm.
                'Sxiv',
                'Tor Browser', -- Needs a fixed window size to avoid fingerprinting by screen size.
                'Wpa_gui',
                'veromix',
                'xtightvncviewer',
                'Scratchpad',
                'FloatThatThing',
                'Dragon',
            },

            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                'Event Tester', -- xev.
            },
            role = {
                'AlarmWindow', -- Thunderbird's calendar.
                'ConfigManager', -- Thunderbird's about:config.
                'pop-up', -- e.g. Google Chrome's (detached) Developer Tools.
            },
        },
        properties = { floating = true, placement = awful.placement.centered },
    },
    {

        rule_any = {
            class = {
                'Zenity',
                'Scratchpad',
                'zenity',
                'Dragon',
            },
        },
        properties = {
            ontop = true,
        },
    },
    {
        rule_any = { class = { 'Anki', 'Chat', 'Todos' } },
        properties = {
            floating = true,
            width = 1200,
            height = 1000,
            -- placement = awful.placement.centered,
            delayed_placement = awful.placement.centered,
        },
    },
    {
        rule_any = { class = { 'Notebook' } },
        properties = {
            floating = true,
            width = 1500,
            height = 1000,
            -- placement = awful.placement.centered,
            delayed_placement = awful.placement.centered,
        },
    },
    {
        rule_any = { class = { 'KeePassXC', '1Password' } },
        properties = {
            floating = true,
            width = 1200,
            height = 1000,
            ontop = false,
            -- placement = awful.placement.centered,
            delayed_placement = awful.placement.centered,
        },
    },

    -- Add titlebars to normal clients and dialogs
    {
        rule_any = { type = { 'normal', 'dialog' } },
        properties = { titlebars_enabled = true },
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal('manage', function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if
        awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position
    then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    -- Rounded corners
    c.shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 10)
    end
end)

client.connect_signal('focus', function(c)
    c.border_color = beautiful.border_focus
end)
client.connect_signal('unfocus', function(c)
    c.border_color = beautiful.border_normal
end)
-- }}}

-- Gaps
beautiful.useless_gap = 3
