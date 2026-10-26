script "stack_revStandaloneSettings_button_id_3716"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Requirement" (id 30344) > group "Reqs" (id 29852) > button "Persistent WiFi" (id 3716)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   storeSetting "persistent wifi", the hilite of me
end mouseUp
