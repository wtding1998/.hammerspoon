-- reload configuration
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "i", function()
  hs.reload()
  hs.alert.show("Config loaded")
end)

-- load other config
require "window"
require "toggle"
-- require "clipboard"
require "sound"
require "edit"
