script "stack_revStandaloneSettings_button_id_29843"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Requirement" (id 30344) > group "Background Modes" (id 3614) > button "Location Update" (id 29843)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   storeSetting "background location update", the hilite of me
end mouseUp
