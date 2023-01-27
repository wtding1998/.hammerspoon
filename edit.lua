
-- function deleteBackward()
--    local topApp =hs.application.frontmostApplication()
--    if topApp ~= nil and topApp:title():lower() == "emacs"  and #topApp:visibleWindows()>0 and not topApp:isHidden() then
--       hs.eventtap.keyStroke({"ctrl"}, "Backspace", 0)
--     else
--       hs.eventtap.keyStroke({"option"}, "Backspace", 0)
--
-- hs.hotkey.bind({"ctrl"}, "Backspace", function() deleteBackward() end)
