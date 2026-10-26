script "stack_revPreferencesGUI_button_id_1167"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Script Editor" (id 1010) > group "Script Editor" (id 1142) > button "Hide Errors" (id 1167)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cSEHideErrors of stack "revPreferences" to the hilite of me
end mouseUp
