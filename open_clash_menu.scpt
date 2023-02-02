ignoring application responses
    tell application "System Events" to tell process "ClashX"
        click menu bar item 1 of menu bar 2
    end tell
end ignoring
delay 0.001
