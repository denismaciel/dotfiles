-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, 'luarocks.loader')

local utils = require 'main.utils'

-- Standard awesome library
local gears = require 'gears'
local awful = require 'awful'
require 'awful.autofocus'
-- Widget and layout library
-- local wibox = require("wibox")
-- Theme handling library
local beautiful = require 'beautiful'
-- Notification library
local naughty = require 'naughty'
local menubar = require 'menubar'
local hotkeys_popup = require 'awful.hotkeys_popup'
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require 'awful.hotkeys_popup.keys'

-- Load Debian menu entries
local debian = require 'debian.menu'
local has_fdo, freedesktop = pcall(require, 'freedesktop')

beautiful.wallpaper = '/user/denis/Downloads/wallpaper.jpg'

function debug_log(obj)
    local f = io.open('/tmp/awesome-debug.log', 'w')
    f:write(obj .. '\n')
    f:close()
end

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify {
        preset = naughty.config.presets.critical,
        title = 'Oops, there were errors during startup!',
        text = awesome.startup_errors,
    }
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

        naughty.notify {
            preset = naughty.config.presets.critical,
            title = 'Oops, an error happened!',
            text = tostring(err),
        }
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. 'default/theme.lua')

-- This is used later as the default terminal and editor to run.
terminal = 'nixGL alacritty'
editor = os.getenv 'EDITOR' or 'editor'
editor_cmd = terminal .. ' -e ' .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = 'Mod4'

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    -- awful.layout.suit.floating,
    awful.layout.suit.max,
    awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    {
        'hotkeys',
        function()
            hotkeys_popup.show_help(nil, awful.screen.focused())
        end,
    },
    { 'manual', terminal .. ' -e man awesome' },
    { 'restart', awesome.restart },
    {
        'quit',
        function()
            awesome.quit()
        end,
    },
}

local menu_awesome = { 'awesome', myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { 'open terminal', terminal }

if has_fdo then
    mymainmenu = freedesktop.menu.build {
        before = { menu_awesome },
        after = { menu_terminal },
    }
else
    mymainmenu = awful.menu {
        items = {
            menu_awesome,
            { 'Debian', debian.menu.Debian_menu.Debian },
            menu_terminal,
        },
    }
end

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

awful.screen.connect_for_each_screen(function(s)
    awful.tag({ '1' }, s, awful.layout.layouts[1])
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(
    gears.table.join(
        awful.button({}, 3, function()
            mymainmenu:toggle()
        end),
        awful.button({}, 4, awful.tag.viewnext),
        awful.button({}, 5, awful.tag.viewprev)
    )
)
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    -- awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
    awful.key(
        { modkey },
        'Left',
        awful.tag.viewprev,
        { description = 'view previous', group = 'tag' }
    ),
    awful.key(
        { modkey },
        'Right',
        awful.tag.viewnext,
        { description = 'view next', group = 'tag' }
    ),
    awful.key(
        { modkey },
        'Escape',
        awful.tag.history.restore,
        { description = 'go back', group = 'tag' }
    ),

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
    awful.key(
        { modkey },
        'u',
        awful.client.urgent.jumpto,
        { description = 'jump to urgent client', group = 'client' }
    ),
    awful.key({ modkey }, 'Tab', function()
        awful.client.focus.history.previous()
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
        awful.spawn.with_shell 'systemctl suspend && i3lock -c 000000'
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

    awful.key({ modkey, 'Control' }, 'n', function()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
            c:emit_signal(
                'request::activate',
                'key.unminimize',
                { raise = true }
            )
        end
    end, { description = 'restore minimized', group = 'client' }),

    awful.key({ modkey }, 'd', function()
        utils.focus_or_spawn(
            'Notebook',
            [[ nixGL alacritty --class Notebook -e /home/denis/scripts/weekly_note 2>&1 /tmp/notbook.log ]]
        )
    end, { description = 'Notebook', group = 'launcher' }),

    awful.key({ modkey }, 'x', function()
        utils.focus_or_spawn(
            'Scratchpad',
            [[ nixGL alacritty --class Scratchpad ]]
        )
    end),

    awful.key({ modkey }, 'f', function()
        utils.focus_or_spawn('Code', 'nixGL alacritty --class Code')
    end),

    awful.key({ modkey }, 'g', function()
        utils.focus_or_spawn('Google-chrome', 'google-chrome-stable')
    end),

    awful.key({ modkey }, 's', function()
        utils.focus_or_spawn('Slack', 'slack')
    end),

    awful.key({ modkey }, 'b', function()
        utils.focus_or_spawn('firefox', 'firefox')
    end),

    awful.key({ modkey }, 'y', function()
        awful.spawn.with_shell 'rofi -combi-modi window,run -show combi'
    end),

    -- awful.key({ modkey }, 't', function()
    --     utils.focus_or_spawn(
    --         'Scratchpad',
    --         [[ nixGL alacritty --class Scratchpad -e '/home/denis/.local/bin/dennich-todo' 'add-todo' ]]
    --     )
    -- end, { description = 'Add TODO', group = 'launcher' }),

    awful.key({ modkey }, 'c', function()
        awful.util.spawn [[rofi -modi "clipboard:greenclip print" -show clipboard -run-command '{cmd}']]
    end),

    awful.key({ modkey }, 'e', function()
        awful.util.spawn [[ rofi -show emoji -modi emoji ]]
    end),

    awful.key({ modkey }, 'r', function()
        awful.util.spawn [[ nixGL alacritty --class FloatThatThing -e sh -c '/home/denis/.local/bin/dennich-todo start-pomodoro' ]]
    end),

    -- Volume
    awful.key({}, 'XF86AudioRaiseVolume', function()
        awful.util.spawn('amixer -D pulse sset Master 5%+', false)
    end),
    awful.key({}, 'XF86AudioLowerVolume', function()
        awful.util.spawn('amixer -D pulse sset Master 5%-', false)
    end),
    awful.key({}, 'XF86AudioMute', function()
        awful.util.spawn('amixer -D pulse sset Master toggle', false)
    end),

    -- Brightness
    awful.key({}, 'XF86MonBrightnessDown', function()
        awful.util.spawn 'xbacklight -dec 15'
    end),
    awful.key({}, 'XF86MonBrightnessUp', function()
        awful.util.spawn 'xbacklight -inc 15'
    end)
)

clientkeys = gears.table.join(
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
    awful.key({ modkey }, 't', function(c)
        c.ontop = not c.ontop
    end, { description = 'toggle keep on top', group = 'client' }),
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
        c.maximized_vertical = not c.maximized_vertical
        c:raise()
    end, { description = '(un)maximize vertically', group = 'client' }),
    awful.key({ modkey, 'Shift' }, 'm', function(c)
        c.maximized_horizontal = not c.maximized_horizontal
        c:raise()
    end, { description = '(un)maximize horizontally', group = 'client' })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(
        globalkeys,
        -- View tag only.
        awful.key({ modkey }, '#' .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags
            if tag then
                tag:view_only()
            end
        end, { description = 'view tag #' .. i, group = 'tag' }),
        -- Toggle tag display.
        awful.key({ modkey, 'Control' }, '#' .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end, { description = 'toggle tag #' .. i, group = 'tag' }),
        -- Move client to tag.
        awful.key(
            { modkey, 'Shift' },
            '#' .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = 'move focused client to tag #' .. i, group = 'tag' }
        ),
        -- Toggle tag on focused client.
        awful.key({ modkey, 'Control', 'Shift' }, '#' .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end, {
            description = 'toggle focused client on tag #' .. i,
            group = 'tag',
        })
    )
end

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

    -- Add titlebars to normal clients and dialogs
    {
        rule_any = { type = { 'normal', 'dialog' } },
        properties = { titlebars_enabled = true },
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
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
    if c.class == 'Zenity' then
        c.ontop = true
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

awful.spawn.with_shell 'syncthing'
awful.spawn.with_shell '/home/denis/.screenlayout/laptop-dell-vertical.sh'
awful.spawn.with_shell '/home/denis/.config/polybar/launch.sh'
awful.spawn.with_shell '/home/denis/.config/awesome/autorun.sh'
