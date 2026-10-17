-- Global Option+/ controls voice directly. Emacs calls openRelay explicitly.
-- Doubao must use hands-free mode and the voiceKey configured below.
local M = {}
local relay = require "voice_relay"
require "hs.ipc" -- Local CLI bridge used by the Emacs command.
local cfg = {
  english = "com.apple.keylayout.ABC",
  doubao = "com.bytedance.inputmethod.doubaoime.pinyin",
  voiceKey = "rightalt", -- Match Doubao's own voice shortcut.
  settleDelay = 0.5,
  restoreDelay = 2.0, -- Grace period, NOT a transcription-completion detector.
}
local state, previous, generation = "idle", nil, 0
local voiceDown = false
local timers = {}
local syntheticTag = 0x444256
local tagProperty = hs.eventtap.event.properties.eventSourceUserData
local function voiceEvent(down)
  voiceDown = down
  -- Do not inherit Hammerspoon's cached synthetic modifier state (e.g. C-y).
  local masks = hs.eventtap.event.rawFlagMasks
  local flags = down and (masks.alternate | masks.deviceRightAlternate) or 0
  hs.eventtap.event.newKeyEvent(cfg.voiceKey, down)
    :rawFlags(flags)
    :setProperty(tagProperty, syntheticTag):post()
end
local function later(delay, fn)
  local token = generation
  local timer
  timer = hs.timer.doAfter(delay, function()
    timers[timer] = nil
    if generation == token then fn() end
  end)
  timers[timer] = true
end
local function clear()
  if voiceDown then voiceEvent(false) end
  generation = generation + 1
  for timer in pairs(timers) do timer:stop() end
  timers = {}
end
local function alert(text) hs.alert.show(text, 1.5) end
local function source() return hs.keycodes.currentSourceID() end
local function restore()
  local target = previous
  clear()
  state, previous = "idle", nil
  -- Respect a manual switch while voice was active.
  if target and source() == cfg.doubao then
    if not hs.keycodes.currentSourceID(target) then
      alert("恢复输入法失败，请从菜单栏选择")
    end
  end
end
local function tapVoice(done)
  voiceEvent(true)
  later(0.08, function()
    voiceEvent(false)
    done()
  end)
end
local function waitForSource(target, done, failed)
  local deadline = hs.timer.secondsSinceEpoch() + 2
  local function poll()
    if source() == target then done()
    elseif hs.timer.secondsSinceEpoch() >= deadline then failed()
    else later(0.05, poll) end
  end
  poll()
end
local function waitForModifiers(done)
  local deadline = hs.timer.secondsSinceEpoch() + 2
  local function poll()
    local f = hs.eventtap.checkKeyboardModifiers()
    if not (f.cmd or f.alt or f.ctrl or f.shift or f.fn) then done()
    elseif hs.timer.secondsSinceEpoch() >= deadline then
      alert("请松开修饰键后重试")
      relay.cancel()
      restore()
    else later(0.05, poll) end
  end
  poll()
end
local function toggleVoice(request)
  if state == "preparing" or state == "stopping" then return end
  -- Inside the relay, Doubao owns recording; Cmd+Return only submits text.
  if relay.pending() then return end
  if state == "active" then
    if source() ~= cfg.doubao then relay.cancel(); restore(); return end
    state = "stopping"
    waitForModifiers(function()
      tapVoice(function() later(cfg.restoreDelay, restore) end)
    end)
    return
  end
  if hs.eventtap.isSecureInputEnabled() then
    alert("当前为安全输入，无法启动语音")
    return
  end
  previous = source()
  if previous == cfg.doubao then previous = cfg.english end
  state = "preparing"
  local function startVoice()
    if not hs.keycodes.currentSourceID(cfg.doubao) then
      alert("无法切换豆包：请确认已添加到系统输入源")
      relay.cancel()
      restore()
      return
    end
    waitForSource(cfg.doubao, function()
      later(cfg.settleDelay, function()
        waitForModifiers(function()
          if source() ~= cfg.doubao then relay.cancel(); restore(); return end
          if request and not relay.focused() then
            alert("中转框已失去焦点，请重新启动")
            relay.cancel(); restore(); return
          end
          tapVoice(function() state = "active" end)
        end)
      end)
    end, function() alert("切换豆包超时"); relay.cancel(); restore() end)
  end
  if request then
    relay.open(request, startVoice, restore, function()
      alert("中转窗口未能获得焦点")
      restore()
    end)
  else
    startVoice()
  end
end
function M.toggleVoice() toggleVoice(nil) end
local function emacsRequest(id, encodedSocket)
  if type(id) ~= "string" or not id:match('^%d+$') then return nil end
  local socket = hs.base64.decode(encodedSocket or '')
  if not socket or socket:sub(1, 1) ~= '/' then return nil end
  return {id=id, socket=socket}
end
function M.openRelay(id, encodedSocket)
  if state ~= "idle" or relay.pending() then return false end
  local request = emacsRequest(id, encodedSocket)
  if not request or hs.eventtap.isSecureInputEnabled() then return false end
  toggleVoice(request)
  return true
end
function M.reconcileSession(id, encodedSocket)
  local request = emacsRequest(id, encodedSocket)
  if not request then return false end
  if relay.sessionID() ~= id then relay.forget(request) end
  return true
end
function M.cancelRelay(id)
  if relay.sessionID() == id and relay.cancel() then restore() end
end
-- Trigger on release; waitForModifiers waits for Option to lift.
M.voiceHotkey = hs.hotkey.bind({"alt"}, "/", nil, M.toggleVoice)
local types = hs.eventtap.event.types
M.escapeWatcher = hs.eventtap.new({types.keyDown}, function(event)
  -- Escape reaches Doubao; cancel pending startup immediately so it cannot record later.
  if event:getKeyCode() == 53 and (state == "active" or relay.pending()) then
    clear()
    state = "stopping"
    relay.pause()
    later(0.15, function() if relay.cancel() then restore() end end)
  end
  return false
end):start()
M.recoverHotkey = hs.hotkey.bind({"ctrl", "alt", "cmd"}, "escape", function()
  -- Emergency recovery: close Doubao's voice panel first if needed.
  if relay.cancel() then
    restore()
    alert("语音切换状态已重置")
  end
end)
-- Reconcile an unfinished Emacs session after a Hammerspoon reload.
M.sessionSyncTask = hs.task.new('/opt/homebrew/bin/emacsclient', function() end,
  {'--eval', '(when (fboundp \'dwt/doubao--resync) (dwt/doubao--resync))'})
if M.sessionSyncTask then M.sessionSyncTask:start() end
M.config = cfg
function M.status() return state end
return M
