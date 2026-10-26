script "stack_revStandaloneSettings_field_id_2823"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Android" (id 2060) > group "Android Settings" (id 2072) > group "Basic Application Settings" (id 2073) > field "Custom URL Scheme" (id 2823)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField
   storeSetting "customUrlScheme", me
end closeField
