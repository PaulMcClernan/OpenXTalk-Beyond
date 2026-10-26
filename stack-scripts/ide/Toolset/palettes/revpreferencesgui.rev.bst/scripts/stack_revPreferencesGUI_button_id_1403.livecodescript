script "stack_revPreferencesGUI_button_id_1403"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Automatic Updates" (id 1404) > button "useAutomaticUpdates" (id 1403)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cUseAutoUpdates of stack "revPreferences" to the hilite of me
   revUpdateAB
end mouseUp
