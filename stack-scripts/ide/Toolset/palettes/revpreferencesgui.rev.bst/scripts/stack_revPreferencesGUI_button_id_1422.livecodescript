script "stack_revPreferencesGUI_button_id_1422"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Appearance" (id 1008) > group "Appearance" (id 1062) > button "gridCheckAtStartup" (id 1422)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the hilite of me is true then
      set the cGrid of stack "revPreferences" to true
      set the grid to true
   else
      set the cGrid of stack "revPreferences" to false
      set the grid to false
   end if
   revUpdateAB
end mouseUp
