script "stack_revStandaloneSettings_group_id_2090"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Android" (id 2060) > group "Android Settings" (id 2072) > group "Basic Application Settings" (id 2073) > group "Externals" (id 2090)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   storeSetting ("include" && the short name of the target), the hilite of the target
end mouseUp
