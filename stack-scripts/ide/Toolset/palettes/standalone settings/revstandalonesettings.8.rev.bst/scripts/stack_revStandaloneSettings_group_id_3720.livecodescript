script "stack_revStandaloneSettings_group_id_3720"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Requirement" (id 30344) > group "location auth" (id 3717) > group "Location Auth Type" (id 3720)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   storeSetting "location auth type", the hilitedButtonName of me
end mouseUp
