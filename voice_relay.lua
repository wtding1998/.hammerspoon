-- Plain input window; returns text to the owning Emacs session without keystrokes.
local M = {}
local base64 = require "hs.base64"
local session
local tasks = {}
local html = [=[<!doctype html><meta charset="utf-8">
<style>
html,body{height:100%;margin:0;background:#fff}
body{box-sizing:border-box;padding:8px}
textarea{box-sizing:border-box;width:100%;height:100%;resize:none;
font:19px -apple-system;padding:8px;border:1px solid #ddd;border-radius:4px;outline:none}
</style>
<textarea id="text" autofocus></textarea>
<script>
const field=document.getElementById('text');
const send=(kind)=>window.webkit.messageHandlers.voiceRelay.postMessage({kind,text:field.value});
field.addEventListener('input',()=>send('text'));
field.addEventListener('compositionend',()=>send('text'));
document.addEventListener('keydown',event=>{
  if(event.metaKey && event.key==='Enter'){
    event.preventDefault();
    field.readOnly=true;
    send('submit');
  }
});
field.focus();
</script>]=]

local function alive(s) return session == s end
local function callEmacs(s, expression, done)
  local finished, timer, task = false, nil, nil
  local function finish(ok)
    if finished then return end
    finished = true
    if timer then timer:stop() end
    if task then tasks[task] = nil end
    done(ok)
  end
  task = hs.task.new('/opt/homebrew/bin/emacsclient', function(code, stdout)
    finish(code == 0 and stdout:match('^%s*ok%s*$') ~= nil)
  end, {'--socket-name', s.socket, '--eval', expression})
  if not task then finish(false); return end
  tasks[task] = true
  if not task:start() then finish(false); return end
  timer = hs.timer.doAfter(5, function()
    if finished then return end
    task:terminate()
    finish(false)
  end)
end
local function dispose(s)
  if s.poll then s.poll:stop() end
  if session == s then session = nil end
  s.view:delete()
end
function M.pending() return session ~= nil end
function M.sessionID() return session and session.id end
function M.focused()
  local focused = hs.window.focusedWindow()
  return session and focused and focused:id() == session.view:hswindow():id()
end
local function deliver(s, text)
  if not alive(s) or s.delivering then return end
  s.delivering = true
  s.view:evaluateJavaScript("document.getElementById('text').readOnly=true")
  -- Clipboard is a recovery copy only, never the transport to Emacs.
  if text ~= '' then hs.pasteboard.setContents(text) end
  local encoded = base64.encode(text)
  callEmacs(s, '(dwt/doubao--receive "' .. s.id .. '" "' .. encoded .. '")', function(ok)
    if not alive(s) then return end
    if ok then
      s.finished()
      dispose(s)
    else
      s.delivering = false
      s.view:evaluateJavaScript("document.getElementById('text').readOnly=false")
      s.view:show():hswindow():focus()
      hs.alert.show('未能送回原 buffer，文字已保留。修复目标后可再按 ⌘Return；Esc 取消。')
    end
  end)
end
function M.open(request, ready, finished, failed)
  local frame = hs.screen.mainScreen():frame()
  local s = {id=request.id, socket=request.socket, finished=finished,
             started=hs.timer.secondsSinceEpoch(), latest=''}
  session = s
  s.controller = hs.webview.usercontent.new('voiceRelay')
  s.controller:setCallback(function(message)
    if not alive(s) then return end
    local body = message.body
    if type(body) ~= 'table' or type(body.text) ~= 'string' then return end
    s.latest = body.text
    if body.kind == 'submit' then deliver(s, body.text) end
  end)
  s.view = hs.webview.new({x=frame.x+(frame.w-460)/2,y=frame.y+(frame.h-160)/2,w=460,h=160},
    {privateBrowsing=true}, s.controller)
    :windowStyle({'titled'}):windowTitle('')
    :allowTextEntry(true):allowNewWindows(false):closeOnEscape(false)
  s.view:navigationCallback(function(event)
    if event ~= 'didFinishNavigation' or not alive(s) or s.loaded then return end
    s.loaded = true
    s.view:hswindow():focus()
    s.view:evaluateJavaScript("document.getElementById('text').focus()")
  end)
  s.view:html(html):show()
  s.poll = hs.timer.doEvery(0.05, function()
    if not alive(s) then return end
    if s.loaded and M.focused() then
      s.poll:stop()
      ready()
    elseif hs.timer.secondsSinceEpoch()-s.started > 5 then
      M.cancel()
      failed()
    end
  end)
end
function M.pause()
  if session and session.poll then session.poll:stop() end
end
function M.forget(request)
  callEmacs(request, '(dwt/doubao--cancel "' .. request.id .. '")', function(ok)
    if not ok then
      hs.alert.show('Emacs 未确认取消；恢复后可执行 M-x dwt/doubao-cancel-voice-input')
    end
  end)
end
function M.cancel()
  local s = session
  if not s then return true end
  -- Submission may already have committed in Emacs. Wait for its acknowledgement.
  if s.delivering then return false end
  if s.latest ~= '' then hs.pasteboard.setContents(s.latest) end
  M.forget(s)
  dispose(s)
  return true
end
return M
