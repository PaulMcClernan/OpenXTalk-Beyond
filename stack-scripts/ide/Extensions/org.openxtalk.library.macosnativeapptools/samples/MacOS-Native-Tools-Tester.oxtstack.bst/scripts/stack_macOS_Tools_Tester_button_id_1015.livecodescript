script "stack_macOS_Tools_Tester_button_id_1015"
-- Stack file: ide/Extensions/org.openxtalk.library.macosnativeapptools/samples/MacOS-Native-Tools-Tester.oxtstack
-- Object: stack "macOS Tools Tester" > card (id 1002) > button "DarkMode All App Windows" (id 1015)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on mouseUp pMouseButton
   lock screen
   setAppToDarkMode
   set the backColor of this stack to "gray 20"
   set the backColor of this card to "gray 20"
   set the foreColor of this stack to "white"
   set the foreColor of this card to "white"
   unlock screen
end mouseUp
