script "stack_revStandaloneSettings_button_id_1335"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Windows" (id 1016) > button "help" (id 1335)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  revDocsGoToTopic the toolTip of me
end mouseUp
