script "stack_macOS_Tools_Tester_button_id_1003"
-- Stack file: ide/Extensions/org.openxtalk.library.macosnativeapptools/samples/MacOS-Native-Tools-Tester.oxtstack
-- Object: stack "macOS Tools Tester" > card (id 1002) > button "AppHide & AppUnhide" (id 1003)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on mouseUp pMouseButton
   AppHide
   wait 2 second with messages
   AppUnhide -- the windowID of this stack
   do "tell application "& quote & "OXT-Beyond" & quote & " to activate" as AppleScript
end mouseUp
