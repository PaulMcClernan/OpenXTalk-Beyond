script "stack_revPreferencesGUI_button_id_1303"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Updates" (id 1299) > button "Notify me of development releases" (id 1303)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cNotifyMeOfDevelopmentReleases of stack "revPreferences" to the hilite of me
end mouseUp
