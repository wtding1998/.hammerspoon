-- TODO: use Winwin spoon.  https://github.com/ashfinal/awesome-hammerspoon/blob/master/init.lua
-- copied from https://github.com/wangshub/hammerspoon-config/blob/master/window/window.lua
-- Window management
hs.window.animationDuration = 0
-- Defines for window maximize toggler
local frameCache = {}
local logger = hs.logger.new("windows")

-- Resize current window

function winresize(how)
   local win = hs.window.focusedWindow()
   local app = win:application():name()
   local windowLayout
   local newrect

   if how == "left" then
      newrect = hs.layout.left50
   elseif how == "right" then
      newrect = hs.layout.right50
   elseif how == "up" then
      newrect = {0,0,1,0.5}
   elseif how == "down" then
      newrect = {0,0.5,1,0.5}
   elseif how == "max" then
      newrect = hs.layout.maximized
   elseif how == "left_third" or how == "hthird-0" then
      newrect = {0,0,1/3,1}
   elseif how == "middle_third_h" or how == "hthird-1" then
      newrect = {1/3,0,1/3,1}
   elseif how == "right_third" or how == "hthird-2" then
      newrect = {2/3,0,1/3,1}
   elseif how == "top_third" or how == "vthird-0" then
      newrect = {0,0,1,1/3}
   elseif how == "middle_third_v" or how == "vthird-1" then
      newrect = {0,1/3,1,1/3}
   elseif how == "bottom_third" or how == "vthird-2" then
      newrect = {0,2/3,1,1/3}
   end

   win:move(newrect)
end

function winmovescreen(how)
   local win = hs.window.focusedWindow()
   if how == "left" then
      win:moveOneScreenWest()
   elseif how == "right" then
      win:moveOneScreenEast()
   end
end

-- Toggle a window between its normal size, and being maximized
function toggle_window_maximized()
   local win = hs.window.focusedWindow()
   if frameCache[win:id()] then
      win:setFrame(frameCache[win:id()])
      frameCache[win:id()] = nil
   else
      frameCache[win:id()] = win:frame()
      win:maximize()
   end
end

-- Move between thirds of the screen
function get_horizontal_third(win)
   local frame=win:frame()
   local screenframe=win:screen():frame()
   local relframe=hs.geometry(frame.x-screenframe.x, frame.y-screenframe.y, frame.w, frame.h)
   local third = math.floor(3.01*relframe.x/screenframe.w)
   logger.df("Screen frame: %s", screenframe)
   logger.df("Window frame: %s, relframe %s is in horizontal third #%d", frame, relframe, third)
   return third
end

function get_vertical_third(win)
   local frame=win:frame()
   local screenframe=win:screen():frame()
   local relframe=hs.geometry(frame.x-screenframe.x, frame.y-screenframe.y, frame.w, frame.h)
   local third = math.floor(3.01*relframe.y/screenframe.h)
   logger.df("Screen frame: %s", screenframe)
   logger.df("Window frame: %s, relframe %s is in vertical third #%d", frame, relframe, third)
   return third
end

function left_third()
   local win = hs.window.focusedWindow()
   local third = get_horizontal_third(win)
   if third == 0 then
      winresize("hthird-0")
   else
      winresize("hthird-" .. (third-1))
   end
end

function right_third()
   local win = hs.window.focusedWindow()
   local third = get_horizontal_third(win)
   if third == 2 then
      winresize("hthird-2")
   else
      winresize("hthird-" .. (third+1))
   end
end

function up_third()
   local win = hs.window.focusedWindow()
   local third = get_vertical_third(win)
   if third == 0 then
      winresize("vthird-0")
   else
      winresize("vthird-" .. (third-1))
   end
end

function down_third()
   local win = hs.window.focusedWindow()
   local third = get_vertical_third(win)
   if third == 2 then
      winresize("vthird-2")
   else
      winresize("vthird-" .. (third+1))
   end
end

function center()
   local win = hs.window.focusedWindow()
   win:centerOnScreen()
end

-------- Key bindings

local resizeWindow = {"shift", "option"}
local moveWindow = {"ctrl", "option"}

hs.loadSpoon("WinWin")

-- Halves of the screen
-- hs.hotkey.bind({"option"}, "Left",  hs.fnutils.partial(winresize, "left"))
-- hs.hotkey.bind({"option"}, "Right", hs.fnutils.partial(winresize, "right"))
-- hs.hotkey.bind({"option"}, "Up",    hs.fnutils.partial(winresize, "up"))
-- hs.hotkey.bind({"option"}, "Down",  hs.fnutils.partial(winresize, "down"))


hs.hotkey.bind(moveWindow, "h",  hs.fnutils.partial(winresize, "left"))
hs.hotkey.bind(moveWindow, "l", hs.fnutils.partial(winresize, "right"))
hs.hotkey.bind(moveWindow, "k",    hs.fnutils.partial(winresize, "up"))
hs.hotkey.bind(moveWindow, "j",  hs.fnutils.partial(winresize, "down"))


hs.hotkey.bind({"option", "shift", "ctrl"}, "h", function() spoon.WinWin:moveAndResize("cornerNW") end)
hs.hotkey.bind({"option", "shift", "ctrl"}, "l", function() spoon.WinWin:moveAndResize("cornerNE") end)
hs.hotkey.bind({"option", "shift", "ctrl"}, "j", function() spoon.WinWin:moveAndResize("cornerSW") end)
hs.hotkey.bind({"option", "shift", "ctrl"}, "k", function() spoon.WinWin:moveAndResize("cornerSE") end)

-- Center of the screen
hs.hotkey.bind(resizeWindow, "i", center)

-- Thirds of the screen
-- hs.hotkey.bind(moveWindow, "Left",  left_third)
-- hs.hotkey.bind(moveWindow, "Right", right_third)
-- hs.hotkey.bind(moveWindow, "Up",    up_third)
-- hs.hotkey.bind(moveWindow, "Down",  down_third)

-- Maximized
hs.hotkey.bind({"option"}, "F", toggle_window_maximized)
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Up",    hs.fnutils.partial(winresize, "max"))

-- Move between screens
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Left",  hs.fnutils.partial(winmovescreen, "left"))
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "Right", hs.fnutils.partial(winmovescreen, "right"))

-- close and lock
-- hs.hotkey.bind({"shift", "option"}, "l", function() hs.caffeinate.lockScreen() end)
hs.hotkey.bind({"shift", "option"}, "l", function() hs.caffeinate.startScreensaver() end)
hs.hotkey.bind({"ctrl", "option", "command"}, "l", function() hs.caffeinate.systemSleep() end)
-- https://github.com/Hammerspoon/hammerspoon/issues/142
-- hs.hotkey.bind({"shift", "option"}, "l", function() hs.execute("open '/System/Library/CoreServices/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine'") end)

-- close window and go to last app
hs.hotkey.bind({"option"}, "0", function() hs.eventtap.keyStroke({"cmd"}, "w", 0) local app = hs.application.frontmostApplication() app:hide() end)
hs.hotkey.bind({"option"}, "c", function() hs.eventtap.keyStroke({"cmd"}, "w", 0) local app = hs.application.frontmostApplication() app:hide() end)
hs.hotkey.bind({"option"}, "8", function() hs.eventtap.keyStroke({"cmd"}, "q", 0) end)

local grid = require "hs.grid"

-- grid.MARGINX = 10
-- grid.MARGINY = 10
-- grid.GRIDHEIGHT = 3
-- grid.GRIDWIDTH = 7


hs.hotkey.bind(moveWindow, "Left",  grid.pushWindowLeft)
hs.hotkey.bind(moveWindow, "Right",  grid.pushWindowRight)
hs.hotkey.bind(moveWindow, "Up",  grid.pushWindowUp)
hs.hotkey.bind(moveWindow, "Down",  grid.pushWindowDown)

hs.hotkey.bind(resizeWindow, "Left",  grid.resizeWindowThinner)
hs.hotkey.bind(resizeWindow, "Right",  grid.resizeWindowWider)
hs.hotkey.bind(resizeWindow, "Up",  grid.resizeWindowTaller)
hs.hotkey.bind(resizeWindow, "Down",  grid.resizeWindowShorter)
