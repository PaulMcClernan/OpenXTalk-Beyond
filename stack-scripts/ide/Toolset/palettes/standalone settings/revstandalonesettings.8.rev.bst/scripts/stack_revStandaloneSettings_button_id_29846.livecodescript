script "stack_revStandaloneSettings_button_id_29846"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Requirement" (id 30344) > group "Background Modes" (id 3614) > button "Background Fetch" (id 29846)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   storeSetting "background fetch", the hilite of me
end mouseUp
