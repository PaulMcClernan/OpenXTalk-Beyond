script "stack_revStandaloneSettings_group_id_3473"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Basic Settings" (id 30336) > group "Basic Settings" (id 29811) > group "Basic Application Settings" (id 3462) > group "Externals" (id 3473)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   storeSetting ("include" && the short name of the target), the hilite of the target
end mouseUp
