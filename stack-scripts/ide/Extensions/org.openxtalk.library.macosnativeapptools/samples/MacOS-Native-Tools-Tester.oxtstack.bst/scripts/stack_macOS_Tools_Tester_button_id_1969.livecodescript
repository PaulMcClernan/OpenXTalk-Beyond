script "stack_macOS_Tools_Tester_button_id_1969"
-- Stack file: ide/Extensions/org.openxtalk.library.macosnativeapptools/samples/MacOS-Native-Tools-Tester.oxtstack
-- Object: stack "macOS Tools Tester" > card (id 1002) > button "UnifyTitleAndToolbar WinID" (id 1969)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on mouseUp pMouseButton
   Answer "UnifyTitleAndToolbar of:" with "Tools palette" or "this stack"
   lock screen
   if it is "Tools palette" then
      UnifyTitleAndToolbar the windowID of stack "revTools"
   else
      UnifyTitleAndToolbar the windowID of this stack
   end if
   unlock screen
end mouseUp
