script "stack_revStandaloneSettings_field_id_2081"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Android" (id 2060) > group "Android Settings" (id 2072) > group "Basic Application Settings" (id 2073) > field "Identifier" (id 2081)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField
   storeSetting "identifier", me
end closeField

on exitField
   storeSetting "identifier", me
end exitField
