script "stack_revPreferencesGUI_button_id_1213"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "App Browser" (id 1013) > button "Show video clips" (id 1213)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cShowVideoclips of stack "revPreferences" to the hilite of me
  revUpdateAB
end mouseUp
