script "stack_revStandaloneSettings_field_id_3184"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Android" (id 2060) > group "Android Settings" (id 2072) > group "In App Purchasing" (id 3173) > group "Samsung" (id 3182) > field "Item Group Id" (id 3184)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField
   storeSetting "samsungItemGroupId", me
end closeField
