script "stack_revPreferencesGUI_button_id_1460"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Compatibility" (id 1015) > group "Compatibility Options" (id 1247) > button "disDataGrid" (id 1460)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the hilite of me is true then
      set the hilite of me to false
      set the cDisableDataGrid of stack "revPreferences" to false
   else
      set the hilite of me to true
      set the cDisableDataGrid of stack "revPreferences" to true
   end if
   
end mouseUp
