script "stack_revPreferencesGUI_group_id_1051"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Files & Memory" (id 1007) > group "Files & Memory" (id 1041) > group "Recent Files Sort" (id 1051)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cRecentSort of stack "revPreferences" to the hilitedButtonName of me
end mouseUp
