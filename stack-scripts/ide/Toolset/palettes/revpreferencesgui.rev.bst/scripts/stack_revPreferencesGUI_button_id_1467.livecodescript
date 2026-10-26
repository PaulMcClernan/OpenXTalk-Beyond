script "stack_revPreferencesGUI_button_id_1467"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Appearance" (id 1008) > group "Appearance" (id 1062) > button "tHandBtn" (id 1467)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   -- set the hand tool
   set the cBrowseIconIsArrow of stack "revPreferences" to false
   send tUpdBrowseCursors to stack "home"
   revUpdateAB
end mouseUp
