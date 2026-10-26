script "stack_macOS_Tools_Tester_button_id_2643"
-- Stack file: ide/Extensions/org.openxtalk.library.macosnativeapptools/samples/MacOS-Native-Tools-Tester.oxtstack
-- Object: stack "macOS Tools Tester" > card (id 1002) > button "SetDockTileBadge" (id 2643)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on mouseUp pMouseButton
   -- Answer "The Application icon in the Dock will now be labeled with the word Hello"
   if fld "badge text" is empty then 
      setDockTileBadge "Hello!"
   else
      setDockTileBadge fld "badge text"
   end if
end mouseUp
