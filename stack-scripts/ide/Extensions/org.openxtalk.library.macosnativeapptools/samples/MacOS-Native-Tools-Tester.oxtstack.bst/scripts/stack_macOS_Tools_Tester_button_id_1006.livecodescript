script "stack_macOS_Tools_Tester_button_id_1006"
-- Stack file: ide/Extensions/org.openxtalk.library.macosnativeapptools/samples/MacOS-Native-Tools-Tester.oxtstack
-- Object: stack "macOS Tools Tester" > card (id 1002) > button "RequestUserAttention" (id 1006)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on mouseUp pMouseButton
    do "tell application "& quote & "Finder.app" & quote & " to activate" as AppleScript
    wait 1 second with messages
    RequestUserAttention TRUE
end mouseUp
