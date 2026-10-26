script "stack_revStandaloneSettings_button_id_3816"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Android" (id 2060) > group "Android Settings" (id 2072) > group "Basic Application Settings" (id 2073) > button "Hardware Accelerated" (id 3816)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   storeSetting "hardware accelerated", the hilited of me
end mouseUp
