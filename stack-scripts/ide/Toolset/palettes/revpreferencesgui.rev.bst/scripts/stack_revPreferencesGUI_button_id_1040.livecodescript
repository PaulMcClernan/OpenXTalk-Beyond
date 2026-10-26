script "stack_revPreferencesGUI_button_id_1040"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "General" (id 1002) > group "General" (id 1016) > button "StartCenterClassicPref" (id 1040)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cStartCenterClassic of stack "revPreferences" to the hilite of me
end mouseUp
