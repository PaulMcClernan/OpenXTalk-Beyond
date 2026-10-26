script "stack_revPreferencesGUI_button_id_1374"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Appearance" (id 1008) > button "G+" (id 1374)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   add 1 to fld "gridSize"
   set the cGridSize of stack "revPreferences" to fld "gridSize" -- simple fix, tperry 25-11-23
   set the gridSize to fld "gridSize"
end mouseUp
