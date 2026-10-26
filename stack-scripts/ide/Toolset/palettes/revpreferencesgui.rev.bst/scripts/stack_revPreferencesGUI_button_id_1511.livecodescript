script "stack_revPreferencesGUI_button_id_1511"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Files & Memory" (id 1007) > group "Files & Memory" (id 1041) > group "Closing Stacks" (id 1043) > button "safetynet" (id 1511)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the hilite of me is true then
      set the hilite of me to false
      set the cDontUseCaution of stack "revPreferences" to true
   else
      set the hilite of me to true
      set the cDontUseCaution of stack "revPreferences" to false
   end if
end mouseUp
