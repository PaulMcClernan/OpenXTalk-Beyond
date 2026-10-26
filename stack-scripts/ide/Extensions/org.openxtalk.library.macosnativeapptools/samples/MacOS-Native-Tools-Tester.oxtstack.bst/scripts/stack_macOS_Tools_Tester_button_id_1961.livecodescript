script "stack_macOS_Tools_Tester_button_id_1961"
-- Stack file: ide/Extensions/org.openxtalk.library.macosnativeapptools/samples/MacOS-Native-Tools-Tester.oxtstack
-- Object: stack "macOS Tools Tester" > card (id 1002) > button "Tabbing (not working)" (id 1961)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on mouseUp pMouseButton
   lock screen
   MergeAllWindows the windowID of this stack
   unlock screen
end mouseUp
