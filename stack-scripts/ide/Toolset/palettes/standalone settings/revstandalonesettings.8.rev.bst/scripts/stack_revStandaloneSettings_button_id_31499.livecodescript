script "stack_revStandaloneSettings_button_id_31499"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Android" (id 2060) > group "Android Settings" (id 2072) > group "Application Permissions" (id 2352) > button "NFC Tag Reading" (id 31499)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   storeSetting "nfc", the hilited of me
end mouseUp
