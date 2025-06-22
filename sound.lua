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

local soundHyper = {'option', 'cmd'}
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

local function nextOutput()
    local currDevice = hs.audiodevice.defaultOutputDevice()
    local outputDevices = hs.audiodevice.allOutputDevices()
    local index = 0
    for i, device in pairs(outputDevices) do
        if device == currDevice then
            index = i
            break
        end
    end
    if index >= #outputDevices then
        index = 0
    end
    outputDevices[index + 1]:setDefaultOutputDevice()
    hs.alert.show("Output: " .. outputDevices[index + 1]:name(), {}, 0.5)
end
local function nextInput()
    local currDevice = hs.audiodevice.defaultInputDevice()
    local inputDevices = hs.audiodevice.allInputDevices()
    local index = 0
    for i, device in pairs(inputDevices) do
        if device == currDevice then
            index = i
            break
        end
    end
    if index >= #inputDevices then
        index = 0
    end
    inputDevices[index + 1]:setDefaultInputDevice()
    hs.alert.show("Input: " .. inputDevices[index + 1]:name(), {}, 0.5)
end

hs.hotkey.bind(soundHyper, 'm', function() toggleVolume() end)
hs.hotkey.bind(soundHyper, "space", nextOutput)
hs.hotkey.bind(soundHyper, "/", nextInput)

-- copied from https://gist.github.com/huytd/20f98ecb2bf1d76b4de9f6c21f5fb37c
-- hyper + l = Next song
hs.hotkey.bind(soundHyper, "]", function()
  hs.eventtap.event.newSystemKeyEvent('NEXT', true):post()
  hs.eventtap.event.newSystemKeyEvent('NEXT', false):post()
end)

-- hyper + h = Prev song
hs.hotkey.bind(soundHyper, "[", function()
  hs.eventtap.event.newSystemKeyEvent('PREVIOUS', true):post()
  hs.eventtap.event.newSystemKeyEvent('PREVIOUS', false):post()
end)

-- hyper + space = Play / Pause
hs.hotkey.bind(soundHyper, "p", function()
  hs.eventtap.event.newSystemKeyEvent('PLAY', true):post()
  hs.eventtap.event.newSystemKeyEvent('PLAY', false):post()
end)


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
