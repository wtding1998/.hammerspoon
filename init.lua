-- reload configuration
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "i", function()
  hs.reload()
end)

hs.alert.show("Config Reloaded")
-- load other config
require "window"
require "toggle"
-- require "clipboard"
require "sound"
require "edit"
