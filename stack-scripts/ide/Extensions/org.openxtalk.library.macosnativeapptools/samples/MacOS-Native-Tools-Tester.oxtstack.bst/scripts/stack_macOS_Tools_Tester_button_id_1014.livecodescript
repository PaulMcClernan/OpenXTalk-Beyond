script "stack_macOS_Tools_Tester_button_id_1014"
-- Stack file: ide/Extensions/org.openxtalk.library.macosnativeapptools/samples/MacOS-Native-Tools-Tester.oxtstack
-- Object: stack "macOS Tools Tester" > card (id 1002) > button "LightMode" (id 1014)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on mouseUp pMouseButton
   lock screen
   setWindowToLightMode the windowID of this stack
   set the backColor of this stack to "white"
   set the backColor of this card to "white"
   set the foreColor of this stack to "black"
   set the foreColor of this card to "black"
   unlock screen
end mouseUp
