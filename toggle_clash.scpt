ignoring application responses
    tell application "System Events" to tell process "ClashX"
        click menu bar item 1 of menu bar 2
    end tell
end ignoring
delay 0.1
do shell script "killall System\\ Events"
tell application "System Events" to tell process "ClashX"
    tell menu bar item 1 of menu bar 2
        click menu item "Set as system proxy" of menu 1
    end tell
end tell
