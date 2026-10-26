script "stack_revPreferencesGUI_group_id_1353"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Project Browser" (id 1320) > group "objectType" (id 1353)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   updatePreference "pb_indicator",the hilitedButtonName of me
end mouseUp
