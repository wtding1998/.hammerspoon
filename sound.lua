function changeVolume(diff)
  return function()
    local current = hs.audiodevice.defaultOutputDevice():volume()
    local new = math.min(100, math.max(0, math.floor(current + diff)))
    if new > 0 then
      hs.audiodevice.defaultOutputDevice():setMuted(false)
    end
    hs.alert.closeAll(0.0)
    hs.alert.show("Volume " .. new .. "%", {}, 0.5)
    hs.audiodevice.defaultOutputDevice():setVolume(new)
  end
end

local soundHyper = {'option', 'ctrl'}
hs.hotkey.bind(soundHyper, 'j', changeVolume(-5))
hs.hotkey.bind(soundHyper, 'k', changeVolume(5))

function toggleVolume()
  if hs.audiodevice.defaultOutputDevice():outputMuted() then
    hs.audiodevice.defaultOutputDevice():setMuted(false)
    hs.alert('unmuted')
  else
    hs.audiodevice.defaultOutputDevice():setMuted(true)
    hs.alert('muted')
  end
end

hs.hotkey.bind(soundHyper, 'm', function() toggleVolume() end)

-- local hyper     = {"ctrl", "alt", "cmd"}
-- local lesshyper = {"ctrl", "alt"}
-- hs.loadSpoon("GlobalMute")
-- spoon.GlobalMute:bindHotkeys({
--   unmute = {hyper, "u"},
--   mute   = {hyper, "m"},
--   toggle = {hyper, "space"}
-- })
-- spoon.GlobalMute:configure({
--   -- unmute_background = 'file:///Library/Desktop%20Pictures/Solid%20Colors/Red%20Orange.png',
--   -- mute_background   = 'file:///Library/Desktop%20Pictures/Solid%20Colors/Turquoise%20Green.png',
--   enforce_desired_state = true,
--   stop_sococo_for_zoom  = true,
--   unmute_title = " U",
--   mute_title = " M",
--   -- change_screens = "SCREENNAME1, SCREENNAME2"  -- This will only change the background of the specific screens.  string.find()
-- })
