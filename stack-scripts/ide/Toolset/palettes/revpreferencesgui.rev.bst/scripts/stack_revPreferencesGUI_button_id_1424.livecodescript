script "stack_revPreferencesGUI_button_id_1424"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Appearance" (id 1008) > group "Appearance" (id 1062) > button "revMenubarStandardWD" (id 1424)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cMakeRevMenuBarStandard of stack "revPreferences" to the hilite of me
   revUpdateAB
   send tMenuBar_WDdecorations to stack "revMenubar"
end mouseUp
