script "stack_revPreferencesGUI_field_id_1030"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "General" (id 1002) > group "General" (id 1016) > group (id 1029) > field "external editor" (id 1030)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField
  set the § of stack "revPreferences" to the text of fld "external editor"
end closeField
