script "stack_macOS_Tools_Tester_button_id_1005"
-- Stack file: ide/Extensions/org.openxtalk.library.macosnativeapptools/samples/MacOS-Native-Tools-Tester.oxtstack
-- Object: stack "macOS Tools Tester" > card (id 1002) > button "macOS Native FullScreen" (id 1005)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on mouseUp pMouseButton
   if (IsFullScreenAllowed(the windowID of this stack)) then 
      put "This window can go full screen."
   else 
      FullScreenAllowed the windowID of this stack, true
   end if
   -- lock screen
   -- set the fullscreenmode of this stack to "noScale" -- {empty|"exactFit"|"letterbox"|"noBorder"|"noScale"|"showAll"}
   -- set the fullscreen of this stack to false
   -- set the scalefactor of this stack to 1.25
   ToggleFullScreen the windowID of this stack
   
end mouseUp
