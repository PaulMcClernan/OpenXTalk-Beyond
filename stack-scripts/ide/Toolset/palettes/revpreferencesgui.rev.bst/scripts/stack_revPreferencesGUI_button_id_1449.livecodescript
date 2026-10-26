script "stack_revPreferencesGUI_button_id_1449"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Troubleshooting" (id 1439) > group (id 1447) > button "InspectorSysWin" (id 1449)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cInspectorSysWin of stack "revPreferences" to the hilite of me
   revUpdateAB
end mouseUp
