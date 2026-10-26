script "stack_revStandaloneSettings_button_id_1331"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "OS X" (id 1015) > group "OSX" (id 1221) > group "enter" (id 1282) > button "help" (id 1331)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  revDocsGoToTopic the toolTip of me
end mouseUp
