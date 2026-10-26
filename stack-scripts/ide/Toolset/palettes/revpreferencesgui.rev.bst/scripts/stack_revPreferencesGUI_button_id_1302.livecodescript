script "stack_revPreferencesGUI_button_id_1302"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Updates" (id 1299) > button "Notify me of beta releases" (id 1302)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cNotifyMeOfBetaReleases of stack "revPreferences" to the hilite of me
end mouseUp
