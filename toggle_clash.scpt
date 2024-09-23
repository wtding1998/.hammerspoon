ignoring application responses
    tell application "System Events" to tell process "ClashX Meta"
        click menu bar item 1 of menu bar 2
    end tell
end ignoring
delay 0.001
do shell script "killall System\\ Events"
tell application "System Events" to tell process "ClashX Meta"
    tell menu bar item 1 of menu bar 2
        click menu item "Set as system proxy" of menu 1
    end tell
end tell
