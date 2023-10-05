
-- function deleteBackward()
--    local topApp =hs.application.frontmostApplication()
--    if topApp ~= nil and topApp:title():lower() == "emacs"  and #topApp:visibleWindows()>0 and not topApp:isHidden() then
--       hs.eventtap.keyStroke({"ctrl"}, "Backspace", 0)
--     else
--       hs.eventtap.keyStroke({"option"}, "Backspace", 0)
--
-- hs.hotkey.bind({"ctrl"}, "Backspace", function() deleteBackward() end)

local edit = {"shift", "option"}

hs.hotkey.bind(edit, "8", function() hs.eventtap.keyStrokes("Lzl=19980418") hs.eventtap.keyStroke({}, "return", 0) end)
