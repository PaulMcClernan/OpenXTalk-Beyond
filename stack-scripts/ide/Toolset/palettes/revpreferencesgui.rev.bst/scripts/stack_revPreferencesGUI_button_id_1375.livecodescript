script "stack_revPreferencesGUI_button_id_1375"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Appearance" (id 1008) > button "G-" (id 1375)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   put fld "gridSize" into GSZ
   if GSZ > 1 then -- richmond?
      subtract 1 from fld "gridSize"
   end if
   set the cGridSize of stack "revPreferences" to fld "gridSize" -- simple fix, tperry 25-11-23
   set the gridSize to fld "gridSize"
   
end mouseUp
