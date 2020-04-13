-- Awesome WM configuration
-- forked from awesome-copycatz

-- Required libraries
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local gears         = require("gears")
local awful         = require("awful")
require("awful.autofocus")
require("awful.remote")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
local radical       = require("radical")
--local tyrannical    = require("tyrannical")
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local dpi           = require("beautiful.xresources").apply_dpi

-- Error handling
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
  title = "Oops, there were errors during startup!",
  text = awesome.startup_errors })
end

do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
    if in_error then return end
    in_error = true

    naughty.notify({ preset = naughty.config.presets.critical,
    title = "Oops, an error happened!",
    text = tostring(err) })
    in_error = false
  end)
end

-- Autostart windowless processes
local function run_once(cmd_arr)
  for _, cmd in ipairs(cmd_arr) do
    awful.spawn.with_shell(string.format(
    "pgrep -fx -u %q %q > /dev/null || exec %s",
    os.getenv("USER"), cmd, cmd
    ))
  end
end

-- Autostart programs
run_once({
  "compton",
  --"nm-applet -sm-disable",
  "unclutter -root",
  --"wmname LG3D"
})

-- Implement the XDG autostart specification
awful.spawn.with_shell([[
if ! xrdb -query | grep -q '^awesome\.started:\s*true$'
then
  xrdb -merge <<< 'awesome.started: true'
  dex --environment Awesome -a -s "${XDG_CONFIG_HOME:-${HOME}/.config}/autostart"
fi]])

-- Variable definitions
local themes = {
  "blackburn",       -- 1
  "copland",         -- 2
  "dremora",         -- 3
  "holo",            -- 4
  "multicolor",      -- 5
  "powerarrow",      -- 6
  "powerarrow-dark", -- 7
  "rainbow",         -- 8
  "steamburn",       -- 9
  "vertex",          -- 10
  "yellow",          -- 11
  "darkblue",        -- 12
  "custom",          -- 13
}
-- Choose the theme
local chosen_theme = themes[12]
local window_titlebar = true  
local dmenu_settings = "dmenu_run -fn 'FantasqueSansMono Nerd Font-14' -i -l 10 -p 'Run:' -nb '#32302f' -nf '#a89984' -sb '#458588' -sf '#2d2d2d' -h 10 -w 800 -y 350 -x 400"
local rofi_settings = "rofi -show run"
local i3lock_settings = "i3lock-fancy -f 'FantasqueSansMono Nerd Font-14' -t 'Locked' -n -- scrot"
local modkey        = "Mod4"
local altkey        = "Mod1"
local terminal      = "urxvt"
local shell         = "zsh"
local file_manager  = "ranger"
local www_browser   = "google-chrome"
local music_player  = "ncmpcpp"
local editor        = os.getenv("EDITOR") or "nvim"
local gui_editor    = "code"
local guieditor     = "code"

-- Naughty presets
--naughty.config.defaults.timeout = 5
--naughty.config.defaults.screen = 1
naughty.config.defaults.position = "top_right"
--naughty.config.defaults.margin = 8
naughty.config.defaults.gap = 1
--naughty.config.defaults.ontop = true
naughty.config.defaults.font = "FantasqueSansMono Nerd Font-12"
--naughty.config.defaults.icon = nil
--naughty.config.defaults.icon_size = 32
naughty.config.defaults.fg = beautiful.fg_tooltip
naughty.config.defaults.bg = beautiful.bg_tooltip
naughty.config.defaults.border_color = beautiful.border_tooltip
naughty.config.defaults.border_width = dpi(2)
naughty.config.defaults.hover_timeout = nil

awful.util.terminal = terminal
awful.util.tagnames = { " α ", " β ", " γ ", " δ ", " ε ", " ζ ", " η ", " θ ", " ι " }
awful.layout.layouts = {
  --awful.layout.suit.floating,
  awful.layout.suit.tile,
  --awful.layout.suit.tile.left,
  --awful.layout.suit.spiral,
  awful.layout.suit.spiral.dwindle,
  --awful.layout.suit.max,
  --awful.layout.suit.magnifier,
  --lain.layout.centerwork,
  --awful.layout.suit.fair,
  --awful.layout.suit.tile.bottom,
  --awful.layout.suit.tile.top,
  --awful.layout.suit.fair.horizontal,
  --awful.layout.suit.max.fullscreen,
  --awful.layout.suit.corner.nw,
  --awful.layout.suit.corner.ne,
  --awful.layout.suit.corner.sw,
  --awful.layout.suit.corner.se,
  --lain.layout.cascade,
  --lain.layout.cascade.tile,
  --lain.layout.centerwork.horizontal,
  --lain.layout.termfair.center,
}

awful.util.taglist_buttons = awful.util.table.join(
awful.button({ }, 1, function(t) t:view_only() end),
awful.button({ modkey }, 1, function(t)
  if client.focus then
    client.focus:move_to_tag(t)
  end
end),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, function(t)
  if client.focus then
    client.focus:toggle_tag(t)
  end
end),
awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

awful.util.tasklist_buttons = awful.util.table.join(
awful.button({ }, 1, function (c)
  if c == client.focus then
    c.minimized = true
  else
    -- Without this, the following
    -- :isvisible() makes no sense
    c.minimized = false
    if not c:isvisible() and c.first_tag then
      c.first_tag:view_only()
    end
    -- This will also un-minimize
    -- the client, if needed
    client.focus = c
    c:raise()
  end
end),
awful.button({ }, 3, function()
  local instance = nil

  return function ()
    if instance and instance.wibox.visible then
      instance:hide()
      instance = nil
    else
      instance = awful.menu.clients({ theme = { width = 256 } })
    end
  end
end),
awful.button({ }, 4, function ()
  awful.client.focus.byidx(1)
end),
awful.button({ }, 5, function ()
  awful.client.focus.byidx(-1)
end))

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = dpi(1)
lain.layout.cascade.tile.offset_y      = dpi(24)
lain.layout.cascade.tile.extra_padding = dpi(4)
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2

local theme_path = string.format(
"%s/awesome/themes/%s/theme.lua",
os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config"),
chosen_theme
)
beautiful.init(theme_path)
print(beautiful)

-- Menu
local myawesomemenu = {
  { "六 hotkeys", function() return false, hotkeys_popup.show_help end },
  --{ "manual", terminal .. " -e man awesome" },
  --{ "edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
  { "淚 restart", awesome.restart },
  { "窱 quit", function() awesome.quit() end }
}
local my_system_menu = {
  { "襤 poweroff", "systemctl poweroff" },
  { "累 reboot", "systemctl reboot" },
  { "鈴 suspend", "systemctl suspend"},
}
awful.util.mymainmenu = freedesktop.menu.build({
  icon_size = beautiful.menu_height or dpi(24),
  before = {
    --{ "awesome", myawesomemenu, beautiful.awesome_icon },
    { "Awesome", myawesomemenu },
  },
  after = {
    { "System", my_system_menu },
    { "Terminal", terminal },
  }
})

-- Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end)

-- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function (s)
  local only_one = #s.tiled_clients == 1
  for _, c in pairs(s.clients) do
    if only_one and not c.floating or c.maximized then
      c.border_width = 0
    else
      c.border_width = beautiful.border_width
    end
  end
end)

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)
  beautiful.connect(s)
end)

--  Mouse bindings
root.buttons(awful.util.table.join(
awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
awful.button({ }, 4, awful.tag.viewnext),
awful.button({ }, 5, awful.tag.viewprev)
))

-- Key bindings
globalkeys = awful.util.table.join(
  -- Take a screenshot
  -- https://github.com/lcpz/dots/blob/master/bin/screenshot
  --awful.key({ altkey }, "p", function() os.execute("screenshot") end,
  --          {description = "take a screenshot", group = "hotkeys"}),
  
  -- -- X screen locker
  -- awful.key({ altkey, "Control" }, "l", function () os.execute(scrlocker) end,
  --           {description = "lock screen", group = "hotkeys"}),
  
  -- Hotkeys
  awful.key({ modkey, "Shift"   }, "/",
  hotkeys_popup.show_help,
  {description = "show help", group="awesome"}),
  
  -- Show applications menu
  awful.key({ modkey            }, "Escape",
  function () awful.util.mymainmenu:show() end,
  {description = "show main menu", group = "awesome"}),
  
  -- Tag browsing
  awful.key({ modkey            }, "Left",
  awful.tag.viewprev,
  {description = "view previous", group = "tag"}),
  awful.key({ modkey            }, "Right",
  awful.tag.viewnext,
  {description = "view next", group = "tag"}),
  
  -- Focus most recent tag
  awful.key({ modkey            }, "\\",
  awful.tag.history.restore,
  {description = "go back", group = "tag"}),
  --]]

  -- Non-empty tag browsing
  awful.key({ modkey            }, "Prior",
  function () lain.util.tag_view_nonempty(-1) end,
  {description = "view previous nonempty", group = "tag"}),
  awful.key({ modkey            }, "Next",
  function () lain.util.tag_view_nonempty(1) end,
  {description = "view next nonempty", group = "tag"}),

  -- Dynamic tagging
  -- awful.key({ modkey, "Shift"   }, "t",
  -- function () lain.util.add_tag() end,
  -- {description = "add new tag", group = "tag"}),
  -- awful.key({ modkey, "Shift" }, "r", function () lain.util.rename_tag() end,
  -- {description = "rename tag", group = "tag"}),
  -- awful.key({ modkey, "Shift" }, "d", function () lain.util.delete_tag() end,
  -- {description = "delete tag", group = "tag"}),

  -- Swap adjacent tags
  awful.key({ modkey, "Shift" }, "Left",
  function () lain.util.move_tag(-1) end,
  {description = "move tag to the left", group = "tag"}),
  awful.key({ modkey, "Shift" }, "Right",
  function () lain.util.move_tag(1) end,
  {description = "move tag to the right", group = "tag"}),

  -- Default client focus
  awful.key({ modkey, "Shift"   }, "Tab",
  function () awful.client.focus.byidx(-1) end,
  {description = "focus previous by index", group = "client"}),
  awful.key({ modkey            }, "Tab",
  function () awful.client.focus.byidx( 1) end,
  {description = "focus next by index", group = "client"}),

  -- By direction client focus
  awful.key({ modkey }, "j",
  function()
    awful.client.focus.bydirection("down")
    if client.focus then client.focus:raise() end
  end,
  {description = "focus down", group = "client"}),
  awful.key({ modkey }, "k",
  function()
    awful.client.focus.bydirection("up")
    if client.focus then client.focus:raise() end
  end,
  {description = "focus up", group = "client"}),
  awful.key({ modkey }, "h",
  function()
    awful.client.focus.bydirection("left")
    if client.focus then client.focus:raise() end
  end,
  {description = "focus left", group = "client"}),
  awful.key({ modkey }, "l",
  function()
    awful.client.focus.bydirection("right")
    if client.focus then client.focus:raise() end
  end,
  {description = "focus right", group = "client"}),

  -- Layout manipulation
  awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
  {description = "swap with next client by index", group = "client"}),
  awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
  {description = "swap with previous client by index", group = "client"}),
  --awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
  --{description = "focus the next screen", group = "screen"}),
  --awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
  --{description = "focus the previous screen", group = "screen"}),
  awful.key({ modkey            }, "0",
  awful.client.urgent.jumpto,
  {description = "jump to urgent client", group = "client"}),

  awful.key({ modkey            }, "`",
  function ()
    awful.client.focus.history.previous()
    if client.focus then
      client.focus:raise()
    end
  end,
  {description = "previous client", group = "client"}),

  -- Show/Hide Wibox
  awful.key({ modkey, "Control" }, "=", function ()
  for s in screen do
  s.mywibox.visible = not s.mywibox.visible
  if s.mybottomwibox then
  s.mybottomwibox.visible = not s.mybottomwibox.visible
  end
  end
  end,
  {description = "toggle wibox", group = "awesome"}),
  --]]

  -- On the fly useless gaps change
  awful.key({ modkey, "Shift"   }, "Down", function () lain.util.useless_gaps_resize(7) end,
  {description = "increment useless gaps", group = "tag"}),
  awful.key({ modkey, "Shift"   }, "Up", function () lain.util.useless_gaps_resize(-7) end,
  {description = "decrement useless gaps", group = "tag"}),

  -- Programms
  --awful.key({                   }, "XF86Launch1", function()  awful.util.spawn("subl3") end),
  --awful.key({ modkey            }, "v", function() awful.util.spawn_with_shell("vivaldi-snapshot") end ),
  --awful.key({ modkey            }, "t", function() awful.util.spawn_with_shell("caja") end ),
  --awful.key({ modkey            }, "r", function() awful.util.spawn('urxvt -e ranger') end ),
  --awful.key({                   }, "F11", function() awful.util.spawn('qpaeq') end ),
  --awful.key({ modkey            }, "l", function() awful.util.spawn_with_shell("~/.config/scripts/lock.sh") end),
  --awful.key({ modkey            }, "l", function() awful.util.spawn(i3lock_settings) end),
  --awful.key({                   }, "Print", function() awful.util.spawn("scrot -e 'mv %f ~/screenshots/'") end),
  --awful.key({ }, "F4", function () scratch.drop("weechat", "bottom", "left", 0.60, 0.60, true, mouse.screen) end),
  --awful.key({ }, "F6", function () scratch.drop("smuxi-frontend-gnome", "bottom", "left", 0.60, 0.60, true, mouse.screen) end),
  --awful.key({ }, "F2", function () scratch.drop("telegram-desktop", "bottom", "right", 0.50, 0.60, true, mouse.screen) end),
  --awful.key({ }, "F3", function () scratch.drop("urxvt -e ranger", "center", "center", 0.75, 0.7, true, mouse.screen) end),
  --awful.key({ }, "F12", function () awful.util.spawn_with_shell("~/.config/scripts/translate_new.sh \"".. translate_service.. "\"",false) end),

  -- Standard program
  --awful.key({ modkey            }, "Return",
  awful.key({ modkey            }, "XF86Launch1",
  function () awful.spawn(terminal) end,
  {description = "open a terminal", group = "launcher"}),

  -- Manage Awesome WM
  awful.key({ modkey, "Control" }, "r", awesome.restart,
  {description = "reload awesome", group = "awesome"}),
  awful.key({ modkey, "Control" }, "BackSpace", awesome.quit,
  {description = "quit awesome", group = "awesome"}),

  awful.key({ modkey, "Control" }, "l",     function () awful.tag.incmwfact( 0.05)          end,
  {description = "increase master width factor", group = "layout"}),
  awful.key({ modkey, "Control" }, "h",     function () awful.tag.incmwfact(-0.05)          end,
  {description = "decrease master width factor", group = "layout"}),
  awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
  {description = "increase the number of master clients", group = "layout"}),
  awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
  {description = "decrease the number of master clients", group = "layout"}),
  awful.key({ modkey, "Control" }, "k",     function () awful.tag.incncol( 1, nil, true)    end,
  {description = "increase the number of columns", group = "layout"}),
  awful.key({ modkey, "Control" }, "j",     function () awful.tag.incncol(-1, nil, true)    end,
  {description = "decrease the number of columns", group = "layout"}),
  awful.key({ modkey            }, "space",  function () awful.layout.inc( 1)                end,
  {description = "select next", group = "layout"}),
  awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
  {description = "select previous", group = "layout"}),

  awful.key({ modkey, "Shift"   }, "z",
  function ()
    local c = awful.client.restore()
    -- Focus restored client
    if c then
      client.focus = c
      c:raise()
    end
  end,
  {description = "restore minimized", group = "client"}),

  -- Dropdown application
  awful.key({ modkey            }, "XF86Launch6",
  function () awful.screen.focused().quake:toggle() end,
  {description = "dropdown application", group = "launcher"}),

  --[[ Widgets popups
  awful.key({ altkey, }, "c", function () lain.widget.calendar.show(7) end,
  {description = "show calendar", group = "widgets"}),
  awful.key({ altkey, }, "h", function () if beautiful.fs then beautiful.fs.show(7) end end,
  {description = "show filesystem", group = "widgets"}),
  awful.key({ altkey, }, "w", function () if beautiful.weather then beautiful.weather.show(7) end end,
  {description = "show weather", group = "widgets"}),
  --]]

  -- Brightness
  awful.key({ }, "XF86MonBrightnessUp",
  function () awful.util.spawn("xbacklight -inc 10") end,
  {description = "+10%", group = "hotkeys"}),
  awful.key({ }, "XF86MonBrightnessDown",
  function () awful.util.spawn("xbacklight -dec 10") end,
  {description = "-10%", group = "hotkeys"}),

  -- ALSA volume control
  awful.key({  }, "XF86AudioRaiseVolume",
  function ()
    os.execute(string.format("amixer -q set %s 2%%+", beautiful.volume.channel))
    beautiful.volume.update()
  end,
  {description = "volume up", group = "hotkeys"}),
  awful.key({  }, "XF86AudioLowerVolume",
  function ()
    os.execute(string.format("amixer -q set %s 2%%-", beautiful.volume.channel))
    beautiful.volume.update()
  end,
  {description = "volume down", group = "hotkeys"}),
  awful.key({  }, "XF86AudioMute",
  function ()
    os.execute(string.format("amixer -q set %s toggle",
    beautiful.volume.togglechannel or beautiful.volume.channel))
    os.execute(string.format("amixer -q set %s on",
    "Speaker"))
    beautiful.volume.update()
  end,
  {description = "toggle mute", group = "hotkeys"}),
  -- awful.key({ altkey, "Control" }, "m",
  --     function ()
  --         os.execute(string.format("amixer -q set %s 100%%", beautiful.volume.channel))
  --         beautiful.volume.update()
  --     end,
  --     {description = "volume 100%", group = "hotkeys"}),
  -- awful.key({ altkey, "Control" }, "0",
  --     function ()
  --         os.execute(string.format("amixer -q set %s 0%%", beautiful.volume.channel))
  --         beautiful.volume.update()
  --     end,
  --     {description = "volume 0%", group = "hotkeys"}),

  -- MPD control
  awful.key({ altkey, "Control" }, "Up",
  function ()
    awful.spawn.with_shell("mpc toggle")
    --beautiful.mpd.update()
  end,
  {description = "mpc toggle", group = "widgets"}),
  awful.key({ altkey, "Control" }, "Down",
  function ()
    awful.spawn.with_shell("mpc stop")
    --beautiful.mpd.update()
  end,
  {description = "mpc stop", group = "widgets"}),
  awful.key({ altkey, "Control" }, "Left",
  function ()
    awful.spawn.with_shell("mpc prev")
    --beautiful.mpd.update()
  end,
  {description = "mpc prev", group = "widgets"}),
  awful.key({ altkey, "Control" }, "Right",
  function ()
    awful.spawn.with_shell("mpc next")
    --beautiful.mpd.update()
  end,
  {description = "mpc next", group = "widgets"}),
  --[[
  awful.key({ altkey }, "0",
  function ()
  local common = { text = "MPD widget ", position = "top_middle", timeout = 2 }
  if beautiful.mpd.timer.started then
  beautiful.mpd.timer:stop()
  common.text = common.text .. lain.util.markup.bold("OFF")
  else
  beautiful.mpd.timer:start()
  common.text = common.text .. lain.util.markup.bold("ON")
  end
  naughty.notify(common)
  end,
  {description = "mpc on/off", group = "widgets"}),
  ]]

  -- Copy primary selection to clipboard
  awful.key({ "Control", "Shift" }, "c", function ()
    awful.spawn.with_shell([[
    xclip -o -sel p | xclip -i -sel c > /dev/null
    ]])
  end, 
  {description = "copy primary selection buffer to clipboard", group = "hotkeys"}),
  -- Copy clipboard to primary selection
  awful.key({ "Control", "Shift" }, "y", function ()
    awful.spawn.with_shell([[
    xclip -o -sel c | xclip -i -sel p > /dev/null
    ]])
  end, 
  {description = "copy clipboard to primary selection buffer", group = "hotkeys"}),
  -- Swap clipboard and primary selection
  awful.key({ "Control", "Shift" }, "x", function ()
    awful.spawn.with_shell([[
    xclip -o -sel p | {
      xclip -o -sel c &&
      xclip -i -sel c > /dev/null
    } | xclip -i -sel p > /dev/null
    ]])
  end, 
  {description = "swap clipboard and primary selection buffer", group = "hotkeys"}),
  --]]

  -- User programs
  awful.key({ modkey            }, "XF86Launch2",
  function () awful.spawn(www_browser) end,
  {description = "launch web browser", group = "launcher"}),
  awful.key({ modkey            }, "XF86Launch3",
  function () awful.spawn(string.format("%s -e %q", terminal, music_player)) end,
  {description = "launch music player", group = "launcher"}),
  awful.key({ modkey            }, "XF86Launch4",
  function () awful.spawn(string.format("%s -e %q", terminal, file_manager)) end,
  {description = "launch file manager", group = "launcher"}),
  awful.key({ modkey            }, "XF86Launch5",
  function () awful.spawn("slack") end,
  {description = "launch Slack", group = "launcher"}),

  -- Default
  --[[ Menubar
  awful.key({ modkey }, "p", function() menubar.show() end,
  {description = "show the menubar", group = "launcher"})
  --]]
  --[[ dmenu
  awful.key({ modkey }, "x", function ()
  awful.spawn(string.format("dmenu_run -i -fn 'Monospace' -nb '%s' -nf '%s' -sb '%s' -sf '%s'",
  beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus))
  end,
  {description = "show dmenu", group = "launcher"}),
  --]]
  awful.key({ modkey            }, "XF86MenuKB",
  function ()
    awful.spawn(rofi_settings)
  end,
  {description = "show dmenu", group = "launcher"}),

  -- Prompt
  --awful.key({ altkey }, "F1", function () awful.util.spawn(dmenu_settings) end),
  --awful.key({ altkey }, "F2", function () awful.util.spawn(rofi_settings) end),
  awful.key({ modkey             }, "XF86Tools",
  function ()
    awful.screen.focused().mypromptbox:run()
  end,
  {description = "run prompt", group = "launcher"})

  --[[ Run Lua code
  awful.key({ altkey, "Shift" }, "l",
  function ()
  awful.prompt.run {
  prompt       = "Run Lua code: ",
  textbox      = awful.screen.focused().mypromptbox.widget,
  exe_callback = awful.util.eval,
  history_path = awful.util.get_cache_dir() .. "/history_eval"
  }
  end,
  {description = "lua execute prompt", group = "awesome"})
  --]]
  )

  clientkeys = awful.util.table.join(
  awful.key({ modkey, "Control" }, "Left",
  function (c)
    if c.floating and c.snapped == "left" then
      c.floating = false
      c.snapped = nil
    else
      local axis = "vertically"
      if c.floating then
        if c.snapped == "top" then
          c.snapped = "top_left"
          axis = nil
        elseif c.snapped == "bottom" then
          c.snapped = "bottom_left"
          axis = nil
        elseif c.snapped == "top_right" then
          c.snapped = "top"
          axis = "horizontally"
        elseif c.snapped == "bottom_right" then
          c.snapped = "bottom"
          axis = "horizontally"
        else
          c.snapped = "left"
        end
      else
        c.floating = true
        c.snapped = "left"
      end
      c.maximized = false
      local f = awful.placement.scale
      + awful.placement[c.snapped]
      + (axis and awful.placement["maximize_"..axis] or nil)
      local g = f(c.focus, {honor_workarea=true, to_percent = 0.5})
    end
  end,
  {description = "Snap to Left", group="client"}),

  awful.key({ modkey, "Control" }, "Right",
  function (c)
    if c.floating and c.snapped == "right" then
      c.floating = false
      c.snapped = nil
    else
      local axis = "vertically"
      if c.floating then
        if c.snapped == "top" then
          c.snapped = "top_right"
          axis = nil
        elseif c.snapped == "bottom" then
          c.snapped = "bottom_right"
          axis = nil
        elseif c.snapped == "top_left" then
          c.snapped = "top"
          axis = "horizontally"
        elseif c.snapped == "bottom_left" then
          c.snapped = "bottom"
          axis = "horizontally"
        else
          c.snapped = "right"
        end
      else
        c.floating = true
        c.snapped = "right"
      end
      c.maximized = false
      local f = awful.placement.scale
      + awful.placement[c.snapped]
      + (axis and awful.placement["maximize_"..axis] or nil)
      local g = f(c.focus, {honor_workarea=true, to_percent = 0.5})
    end
  end,
  {description = "Snap to Right", group="client"}),

  awful.key({ modkey, "Control" }, "Up",
  function (c)
    if c.floating and c.snapped == "top" then
      c.floating = false
      c.snapped = nil
    else
      local axis = "horizontally"
      if c.floating then
        if c.snapped == "left" then
          c.snapped = "top_left"
          axis = nil
        elseif c.snapped == "right" then
          c.snapped = "top_right"
          axis = nil
        elseif c.snapped == "bottom_left" then
          c.snapped = "left"
          axis = "vertically"
        elseif c.snapped == "bottom_right" then
          c.snapped = "right"
          axis = "vertically"
        else
          c.snapped = "top"
        end
      else
        c.floating = true
        c.snapped = "top"
      end
      c.maximized = false
      local f = awful.placement.scale
      + awful.placement[c.snapped]
      + (axis and awful.placement["maximize_"..axis] or nil)
      local g = f(c.focus, {honor_workarea=true, to_percent = 0.5})
    end
  end,
  {description = "Snap to Top", group="client"}),

  awful.key({ modkey, "Control" }, "Down",
  function (c)
    if c.floating and c.snapped == "bottom" then
      c.floating = false
      c.snapped = nil
    else
      local axis = "horizontally"
      if c.floating then
        if c.snapped == "left" then
          c.snapped = "bottom_left"
          axis = nil
        elseif c.snapped == "right" then
          c.snapped = "bottom_right"
          axis = nil
        elseif c.snapped == "top_left" then
          c.snapped = "left"
          axis = "vertically"
        elseif c.snapped == "top_right" then
          c.snapped = "right"
          axis = "vertically"
        else
          c.snapped = "bottom"
        end
      else
        c.floating = true
        c.snapped = "bottom"
      end
      c.maximized = false
      local f = awful.placement.scale
      + awful.placement[c.snapped]
      + (axis and awful.placement["maximize_"..axis] or nil)
      local g = f(c.focus, {honor_workarea=true, to_percent = 0.5})
    end
  end,
  {description = "Snap to Bottom", group="client"}),

  awful.key({ modkey, "Control" }, "-",
  function (c)
    awful.titlebar.toggle(c)
    titlebars = not titlebars
  end, 
  {description = "Toggle Titlebars", group="client"}),

  awful.key({ modkey            }, "=",
  function (c)
    c.maxxximized = not c.maxxximized
    for s in screen do
      s.mywibox.visible = not c.maxxximized
      if s.mybottomwibox then
        s.mybottomwibox.visible = not c.maxxximized
      end
    end
    if c.maxxximized then
      awful.titlebar.hide(c)
      titlebars = false
      c.floating = false
      c.maximized = false
    end
    c:raise()
  end, 
  {description = "maxxximize client", group="client"}),

  awful.key({ modkey, "Control" }, "m",      lain.util.magnify_client,
  {description = "magnify client", group = "client"}),
  awful.key({ modkey            }, "f",
  function (c)
    c.fullscreen = not c.fullscreen
    c:raise()
  end,
  {description = "toggle fullscreen", group = "client"}),
  awful.key({ modkey, "Shift"   }, "q",
  function (c) c:kill() end,
  {description = "close", group = "client"}),
  awful.key({ modkey            }, "-",
  awful.client.floating.toggle                     ,
  {description = "toggle floating", group = "client"}),
  --[[
  awful.key({ modkey, "Control" }, "Return",
  function (c) c:swap(awful.client.getmaster()) end,
  {description = "move to master", group = "client"}),
  ]]
  --[[
  awful.key({ modkey            }, "o",
  function (c) c:move_to_screen() end,
  {description = "move to screen", group = "client"}),
  ]]
  awful.key({ modkey, "Shift"   }, "=",
  function (c) c.ontop = not c.ontop end,
  {description = "toggle keep on top", group = "client"}),
  awful.key({ modkey            }, "z",
  function (c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
  end ,
  {description = "minimize", group = "client"}),
  awful.key({ modkey            }, "m",
  function (c)
    c.maximized = not c.maximized
    c:raise()
  end ,
  {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
  local descr_view, descr_toggle, descr_move, descr_toggle_focus
  if i == 1 or i == 9 then
    descr_view = {description = "view tag #", group = "tag"}
    descr_toggle = {description = "toggle tag #", group = "tag"}
    descr_move = {description = "move focused client to tag #", group = "tag"}
    descr_toggle_focus = {description = "toggle focused client on tag #", group = "tag"}
  end
  globalkeys = awful.util.table.join(globalkeys,
  -- View tag only.
  awful.key({ modkey }, "#" .. i + 9,
  function ()
    local screen = awful.screen.focused()
    local tag = screen.tags[i]
    if tag then
      tag:view_only()
    end
  end,
  descr_view),
  -- Toggle tag display.
  awful.key({ modkey, "Control" }, "#" .. i + 9,
  function ()
    local screen = awful.screen.focused()
    local tag = screen.tags[i]
    if tag then
      awful.tag.viewtoggle(tag)
    end
  end,
  descr_toggle),
  -- Move client to tag.
  awful.key({ modkey, "Shift" }, "#" .. i + 9,
  function ()
    if client.focus then
      local tag = client.focus.screen.tags[i]
      if tag then
        client.focus:move_to_tag(tag)
      end
    end
  end,
  descr_move),
  -- Toggle tag on focused client.
  awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
  function ()
    if client.focus then
      local tag = client.focus.screen.tags[i]
      if tag then
        client.focus:toggle_tag(tag)
      end
    end
  end,
  descr_toggle_focus)
  )
end

clientbuttons = awful.util.table.join(
awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ modkey }, 1, awful.mouse.client.move),
awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  { rule = { },
  properties = { border_width = beautiful.border_width,
  border_color = beautiful.border_normal,
  focus = awful.client.focus.filter,
  raise = true,
  keys = clientkeys,
  buttons = clientbuttons,
  screen = awful.screen.preferred,
  placement = awful.placement.no_overlap+awful.placement.no_offscreen,
  size_hints_honor = false
  }
},

-- Titlebars
{ rule_any = { type = { "dialog", "normal" } },
properties = { titlebars_enabled = window_titlebar } },

-- Maximize Firefox
{ rule = { class = "Firefox" },
properties = { screen = 1, maximized = true, switchtotag = false } },
{ rule = { class = "Opera" },
properties = { screen = 1, maximized = true, switchtotag = false } },
-- Maximize MPV
{ rule = { class = "mpv" },
properties = { maximized = true } },
-- Maximize Slack
{ rule = { class = "Slack" },
properties = { screen = 1, maximized = true, switchtotag = false } },
-- Caja is floating with fixed sizes. Titelbar enabled for Caja
{ rule = { class = "Caja" },
properties = { floating = true, titlebars_enabled = true, geometry = { x=200, y=150, height=600, width=1100 } } },
{ rule = { class = "Nm-connection-editor" },
properties = { floating = true } },
{ rule = { class = "Tilda"},
properties = { floating = true, below = true } },
--[[ Jetbrains
{ rule = { class = "jetbrains-webstorm" },
properties = { screen = 1, maximized = true, tag = awful.util.tagnames[2] } },
{ rule = { class = "jetbrains-idea" },
properties = { screen = 1, maximized = true, tag = awful.util.tagnames[2] } },
{ rule = { class = "jetbrains-pycharm" },
properties = { screen = 1, maximized = true, tag = awful.util.tagnames[2] } },
--]]
-- Disable titelbar for browsers
{ rule = { class = "Vivaldi-stable" },
properties = { screen = 1, maximized = true, titlebars_enabled = false, switchtotag = false } },
{ rule = { class = "Vivaldi-snapshot" },
properties = { screen = 1, maximized = true, titlebars_enabled = false, switchtotag = false } },
{ rule = { class = "Google-chrome" },
properties = { screen = 1, maximized = true, titlebars_enabled = false, switchtotag = false } },
{ rule = { class = "Google-chrome-unstable" },
properties = { screen = 1, maximized = true, titlebars_enabled = false } },
{ rule = { class = "Transmission-gtk" },
properties = { screen = 1, maximized = true, switchtotag = false } },
{ rule = { instance = "plugin-container" },
properties = { floating = true } },
{ rule = { instance = "exe" },
properties = { floating = true } },
{ rule = { role = "_NET_WM_STATE_FULLSCREEN" },
properties = { floating = true } },
{ rule = { class = "Gimp", role = "gimp-image-window" },
properties = { maximized = true } },
--{ rule = { class = "URxvt" },
--properties = { titlebars_enabled = false } },
--{ rule = { class = "XTerm" },
--properties = { titlebars_enabled = false } },
}

-- Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  -- if not awesome.startup then awful.client.setslave(c) end

  if awesome.startup and
    not c.size_hints.user_position
    and not c.size_hints.program_position then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
  -- Custom
  if beautiful.titlebar_fun then
    beautiful.titlebar_fun(c)
    return
  end

  -- Default
  -- buttons for the titlebar
  local buttons = awful.util.table.join(
  awful.button({ }, 1, function()
    client.focus = c
    c:raise()
    awful.mouse.client.move(c)
  end),
  awful.button({ }, 3, function()
    client.focus = c
    c:raise()
    awful.mouse.client.resize(c)
  end)
  )

  awful.titlebar(c, {size = dpi(18)}) : setup {
    { -- Left
    awful.titlebar.widget.iconwidget(c),
    buttons = buttons,
    layout  = wibox.layout.fixed.horizontal
    },
    { -- Middle
    -- { -- Title
    --     align  = "center",
    --     widget = awful.titlebar.widget.titlewidget(c)
    -- },
    buttons = buttons,
    layout  = wibox.layout.flex.horizontal
    },
    { -- Right
    awful.titlebar.widget.floatingbutton (c),
    awful.titlebar.widget.stickybutton   (c),
    awful.titlebar.widget.ontopbutton    (c),
    awful.titlebar.widget.maximizedbutton(c),
    awful.titlebar.widget.closebutton    (c),
    layout = wibox.layout.fixed.horizontal()
    },
    layout = wibox.layout.align.horizontal
  }

  -- Hide titlebars
  awful.titlebar.hide(c)
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
  if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    and awful.client.focus.filter(c) then
    client.focus = c
  end
end)

-- No border for maximized clients
client.connect_signal("focus",
function(c)
  if c.maximized then -- no borders if only 1 client visible
    c.border_width = 0
  elseif #awful.screen.focused().clients > 1 then
    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_focus
  end
end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
