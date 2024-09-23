-- to obtain bundle ID:
-- /usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' /Applications/Safari.app/Contents/Info.plist
-- lsappinfo info -only bundleid Finder
-------------------------------------------------------------
local myhyper = {'option'}
hs.hotkey.bind(myhyper, "w", function() toggleEmacs() end)
-- hs.hotkey.bind(myhyper, "`", function() toggleEmacs() hs.eventtap.keyStroke({"option", "cmd"}, "h", 0) end)
hs.hotkey.bind(myhyper, "1", function() toggleFinder() end)
-- hs.hotkey.bind(myhyper, "3", function() toggleApp("com.microsoft.edgemac") end)
hs.hotkey.bind(myhyper, "3", function() toggleApp("org.mozilla.firefox") end)
-- hs.hotkey.bind(myhyper, "2", function() toggleApp("com.apple.Terminal") end)
hs.hotkey.bind(myhyper, "2", function() toggleApp("com.googlecode.iterm2") end)
hs.hotkey.bind(myhyper, "4", function() toggleApp("com.apple.mail") end)
hs.hotkey.bind(myhyper, ",", function() toggleApp("com.netease.163music") end)
hs.hotkey.bind(myhyper, "s", function() toggleApp("com.tencent.xinWeChat") end)
-- hs.hotkey.bind(myhyper, ",", function() toggleApp("com.apple.MobileSMS") end)
hs.hotkey.bind(myhyper, "`", function() toggleApp("com.mathworks.matlab") end)
hs.hotkey.bind(myhyper, "p", function() toggleApp("com.tencent.qq") end)
hs.hotkey.bind(myhyper, "u", function() toggleApp("com.microsoft.VSCode") end)
hs.hotkey.bind(myhyper, "q", function() toggleApp("com.apple.Preview") end)
hs.hotkey.bind(myhyper, "z", function() toggleApp("org.zotero.zotero") end)
hs.hotkey.bind(myhyper, "i", function() toggleApp("com.kingsoft.wpsoffice.mac") end)
hs.hotkey.bind(myhyper, ".", function() toggleApp("com.linguee.DeepLCopyTranslator") end)
-- hs.hotkey.bind(myhyper, "u", function() toggleApp("com.TickTick.task.mac") end)
hs.hotkey.bind(myhyper, "k", function() hs.execute("/opt/homebrew/opt/emacs-plus@29/bin/emacsclient -e '(emacs-everywhere)'") end)


-- hs.hotkey.bind(myhyper, "t", function() hs.execute("/Library/Input\\ Methods/Squirrel.app/Contents/MacOS/squirrel_client -t ascii_mode")  end )
-- hs.hotkey.bind(myhyper, "w", function() toggleApp("com.wunderkinder.wunderlistdesktop") end )
-- hs.hotkey.bind(myhyper, "/", function() toggleApp("com.apple.Notes") end )
-- hs.hotkey.bind(myhyper, "n", function() toggleApp("com.apple.Notes") end )
-- hs.hotkey.bind(myhyper, "w",function() appKill() end)
-- hs.hotkey.bind(myhyper, "d", function() toggleApp("com.emmac.mac") end )
-- hs.hotkey.bind(myhyper, "f", function() toggleApp("com.apple.Safari") end )
-- hs.hotkey.bind(myhyper, "f", function() toggleApp("com.google.Chrome") end )
-- hs.hotkey.bind(myhyper, "d", function() toggleApp("com.googlecode.iterm2") end)
-- hs.hotkey.bind(myhyper, "3", function() toggleApp("com.tencent.WeWorkMac") end)
-- hs.hotkey.bind(myhyper, "4", function() toggleApp("com.electron.lark") end)
-- hs.hotkey.bind(myhyper, "x", function() toggleApp("com.apple.dt.Xcode") end)
-- hs.hotkey.bind(myhyper, "s", function() toggleApp("com.sequelpro.SequelPro") end)
-- hs.hotkey.bind(myhyper, "c", function() toggleApp("com.mongodb.compass") end)

-- toggle App
function toggleApp(appBundleID)
   -- local win = hs.window.focusedWindow()
   -- local app = win:application()
   local app =hs.application.frontmostApplication()
   if app ~= nil and app:bundleID() == appBundleID    then
      app:hide()
      -- win:sendToBack()
   elseif app==nil then
      hs.application.launchOrFocusByBundleID(appBundleID)
   else
      -- app:activate()
      hs.application.launchOrFocusByBundleID(appBundleID)
      app=hs.application.get(appBundleID)
      if app==nil then
         return
      end
      local wins=app:visibleWindows()
      if #wins>0 then
         for k,win in pairs(wins) do
            if win:isMinimized() then
               win:unminimize()
            end
         end
      else
         hs.application.open(appBundleID)
         app:activate()
      end


      local win=app:mainWindow()
      if win ~= nil then
         win:application():activate(true)
         win:application():unhide()
         win:focus()
      end


   end
end
function toggleEmacs()        --    toggle emacsclient if emacs daemon not started start it
   -- local win = hs.window.focusedWindow()
   -- local topApp = win:application()

   local topApp =hs.application.frontmostApplication()

   if topApp ~= nil and topApp:title():lower() == "emacs"  and #topApp:visibleWindows()>0 and not topApp:isHidden() then
      topApp:hide()
      -- hideEAF()
      -- local apps=hs.application.runningApplications()
      -- for k,app in pairs(apps) do
      --    -- hs.alert.show(app:name())
      --    if string.match(app:path() , "python3") then
      --    end
      -- end
      -- local wins=hs.window.allWindows()
      -- for k,win in pairs(wins) do
      --    hs.alert.show(win:application():path())
      --    if string.match(win:application():path() , "python3") then
      --       win:application():hide()
      --       win:sendToBack()
      --    end
      -- end
   else
      local emacsApp=hs.application.get("Emacs")
      if emacsApp==nil then
         -- ~/.emacs.d/bin/ecexec 是对emacsclient 的包装，你可以直接用emacsclient 来代替
         -- 这个脚本会检查emacs --daemon 是否已启动，未启动则启动之
         -- hs.execute("~/.emacs.d/bin/ecexec --no-wait -c") -- 创建一个窗口
         hs.task.new("~/.emacs.d/bin/en",nil):start()
         -- 这里可能需要等待一下，以确保窗口创建成功后再继续，否则可能窗口不前置
         emacsApp=hs.application.get("Emacs")
         if emacsApp ~=nil then
            emacsApp:activate()      -- 将刚创建的窗口前置
         end
         return
      end
      local wins=emacsApp:allWindows() -- 只在当前space 找，
      if #wins==0 then
         wins=hs.window.filter.new(false):setAppFilter("Emacs",{}):getWindows() -- 在所有space找，但是window.filter的bug多，不稳定
      end

      if #wins>0 then
         for _,win in pairs(wins) do

            if win:isMinimized() then
               win:unminimize()
            end

            win:application():activate(true)
            win:application():unhide()
            -- showEAF()
            -- win:focus() -- 不主动聚焦，有可能有miniframe
            -- hs.alert.show(win:title())
         end
      else
         -- ~/.emacs.d/bin/ecexec 是对emacsclient 的包装，你可以直接用emacsclient 来代替
         -- 这个脚本会检查emacs --daemon 是否已启动，未启动则启动之
         -- hs.execute("cd ~;~/.emacs.d/bin/ec") -- 创建一个窗口
         hs.task.new("~/.emacs.d/bin/en",nil):start()
         -- hs.execute("~/.emacs.d/bin/ecexec --no-wait -c") -- 创建一个窗口
         -- 这里可能需要等待一下，以确保窗口创建成功后再继续，否则可能窗口不前置
         emacsApp=hs.application.get("Emacs")
         if emacsApp ~=nil then
            emacsApp:activate()      -- 将刚创建的窗口前置
         end
      end

   end
end

hs.urlevent.bind("toggleEmacs", function(eventName, params) toggleEmacs() end)
-- open -g "hammerspoon://toggleEmacs"
---------------------------------------------------------------
function toggleFinder()
   local appBundleID="com.apple.finder"
   local topWin = hs.window.focusedWindow()
   -- if topWin==nil then
   --    return
   -- end
   -- local topApp = topWin:application()
   -- local topApp =hs.application.frontmostApplication()

   -- The desktop belongs to Finder.app: when Finder is the active application, you can focus the desktop by cycling through windows via cmd-`
   -- The desktop window has no id, a role of AXScrollArea and no subrole
   -- and #topApp:visibleWindows()>0
   if topWin~=nil and topWin:application() ~= nil and topWin:application():bundleID() == appBundleID   and topWin:role() ~= "AXScrollArea" then
      topWin:application():hide()
   else
      finderApp=hs.application.get(appBundleID)
      if finderApp==nil then
         hs.application.launchOrFocusByBundleID(appBundleID)
         return
      end
      local wins=finderApp:allWindows()
      local isWinExists=true
      if #wins==0  then
         isWinExists=false
      elseif  (wins[1]:role() =="AXScrollArea" and #wins==1 )  then
         isWinExists=false
      end

      -- local wins=app:visibleWindows()
      if not isWinExists then
         wins=hs.window.filter.new(false):setAppFilter("Finder",{}):getWindows()
      end


      if #wins==0 then
         hs.application.launchOrFocusByBundleID(appBundleID)
         for _,win in pairs(wins) do
            if win:isMinimized() then
               win:unminimize()
            end

            win:application():activate(true)
            win:application():unhide()
            win:focus()
         end
      else
         for _,win in pairs(wins) do
            if win:isMinimized() then
               win:unminimize()
            end

            win:application():activate(true)
            win:application():unhide()
            win:focus()
         end
      end
   end
end
-- open -g "hammerspoon://toggleFinder"
hs.urlevent.bind("toggleFinder", function(eventName, params) toggleFinder() end)

function toggle_clash()
   hs.osascript.applescriptFromFile("open_clash_menu.scpt")
   hs.eventtap.keyStroke({}, "down", 0)
   hs.eventtap.keyStroke({}, "down", 0)
   hs.eventtap.keyStroke({}, "down", 0)
   hs.eventtap.keyStroke({}, "down", 0)
   hs.eventtap.keyStroke({}, "down", 0)
   hs.eventtap.keyStroke({}, "return", 0)
end


function toggle_clash_global()
   hs.osascript.applescriptFromFile("open_clash_menu.scpt")
   hs.eventtap.keyStroke({}, "down", 0)
   hs.eventtap.keyStroke({}, "right", 0)
   hs.eventtap.keyStroke({}, "return", 0)
   hs.alert.show("Toggled to Global")
end


function toggle_clash_rule()
   hs.osascript.applescriptFromFile("open_clash_menu.scpt")
   hs.eventtap.keyStroke({}, "down", 0)
   hs.eventtap.keyStroke({}, "right", 0)
   hs.eventtap.keyStroke({}, "down", 0)
   hs.eventtap.keyStroke({}, "return", 0)
   hs.alert.show("Toggled to Rule")
end

function toggle_clash_direct()
   hs.osascript.applescriptFromFile("open_clash_menu.scpt")
   hs.eventtap.keyStroke({}, "down", 0)
   hs.eventtap.keyStroke({}, "right", 0)
   hs.eventtap.keyStroke({}, "down", 0)
   hs.eventtap.keyStroke({}, "down", 0)
   hs.eventtap.keyStroke({}, "return", 0)
   hs.alert.show("Toggled to Direct")
end

function setClashXProxy()
   hs.osascript.applescriptFromFile("toggle_clash.scpt")
end


-- hs.hotkey.bind(myhyper, '/', setClashXProxy)
hs.hotkey.bind(myhyper, '/', toggle_clash)
hs.hotkey.bind(myhyper, '-', toggle_clash_global)
hs.hotkey.bind(myhyper, '=', toggle_clash_rule)
hs.hotkey.bind(myhyper, '\\', toggle_clash_direct)
