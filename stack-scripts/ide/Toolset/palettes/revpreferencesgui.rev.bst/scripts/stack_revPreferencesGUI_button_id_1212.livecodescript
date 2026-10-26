script "stack_revPreferencesGUI_button_id_1212"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "App Browser" (id 1013) > button "Show audio clips" (id 1212)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cShowAudioclips of stack "revPreferences" to the hilite of me
  revUpdateAB
end mouseUp
