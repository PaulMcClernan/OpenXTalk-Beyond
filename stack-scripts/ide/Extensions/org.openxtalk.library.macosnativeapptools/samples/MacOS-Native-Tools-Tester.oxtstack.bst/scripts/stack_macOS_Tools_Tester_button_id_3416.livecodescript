script "stack_macOS_Tools_Tester_button_id_3416"
-- Stack file: ide/Extensions/org.openxtalk.library.macosnativeapptools/samples/MacOS-Native-Tools-Tester.oxtstack
-- Object: stack "macOS Tools Tester" > card (id 1002) > button "Tabbing (not working)" (id 3416)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on mouseUp pMouseButton
   open stack "TestSubStack"
   lock screen
   MergeWindowWithWindow the windowID of this stack, the windowID of stack "TestSubStack"
   unlock screen
end mouseUp
