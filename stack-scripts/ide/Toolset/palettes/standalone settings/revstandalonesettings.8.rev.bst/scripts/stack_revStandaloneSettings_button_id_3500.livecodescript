script "stack_revStandaloneSettings_button_id_3500"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Icons" (id 3494) > button "Prerendered Icon" (id 3500)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   storeSetting "prerendered icon", the hilite of me
end mouseUp
