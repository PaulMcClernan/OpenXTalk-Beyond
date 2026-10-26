script "stack_revPreferencesGUI_field_id_1032"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "General" (id 1002) > group "General" (id 1016) > group (id 1029) > field "http proxy" (id 1032)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField
  set the httpProxy to the text of me
  set the cHttpProxy of stack "revPreferences" to the text of me
end closeField
