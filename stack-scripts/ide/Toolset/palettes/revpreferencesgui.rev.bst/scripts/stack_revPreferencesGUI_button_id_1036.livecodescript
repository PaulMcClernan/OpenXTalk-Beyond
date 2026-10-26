script "stack_revPreferencesGUI_button_id_1036"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "General" (id 1002) > group "General" (id 1016) > button "Crash Report Style" (id 1036)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pLabel
  set the cCrashReportStyle of stack "revPreferences" to pLabel
end menuPick

