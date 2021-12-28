-- reload configuration
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "j", function()
  hs.reload()
end)
hs.alert.show("Config loaded")

-- load other config
require "window"
require "toggle"
