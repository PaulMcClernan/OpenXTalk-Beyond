script "stack_revPreferencesGUI_button_id_1300"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Updates" (id 1299) > button "Notify me of stable releases" (id 1300)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cNotifyMeOfStableReleases of stack "revPreferences" to the hilite of me
end mouseUp
