script "stack_revPreferencesGUI_button_id_1039"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "General" (id 1002) > group "General" (id 1016) > button "ReloadStartCenter" (id 1039)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cReloadStartCenter of stack "revPreferences" to the hilite of me
end mouseUp
