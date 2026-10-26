script "stack_revStandaloneSettings_button_id_29849"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Requirement" (id 30344) > group "Background Modes" (id 3614) > button "ExAcComn" (id 29849)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   storeSetting "external acc comn", the hilite of me
end mouseUp
