script "stack_revPreferencesGUI_button_id_1468"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Appearance" (id 1008) > group "Appearance" (id 1062) > button "tArrowBtn" (id 1468)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   -- set the arrow tool
   set the cBrowseIconIsArrow of stack "revPreferences" to true
   send tUpdBrowseCursors to stack "home"
   revUpdateAB
end mouseUp
