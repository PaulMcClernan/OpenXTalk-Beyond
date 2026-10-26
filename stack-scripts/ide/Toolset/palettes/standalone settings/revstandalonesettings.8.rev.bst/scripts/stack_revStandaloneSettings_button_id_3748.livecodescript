script "stack_revStandaloneSettings_button_id_3748"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "iOS Settings" (id 30345) > group (id 30343) > button "32bit_only" (id 3748)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   -- SN-2015-03-30: [[ Bug 14794 ]] Add the new standalone parameter
   --  32-bit only
   storeSetting "32-bit only", the hilite of me
end mouseUp
