script "stack_revPreferencesGUI_button_id_1483"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Automatic Updates" (id 1404) > button "relNotes" (id 1483)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  send tOpenReleaseNotes to card "Automatic Updates" of stack "revPreferencesGUI"
end mouseUp
