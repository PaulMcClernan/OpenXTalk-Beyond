script "stack_revStandaloneSettings_group_id_3603"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Basic Settings" (id 30336) > group "Basic Settings" (id 29811) > group (id 3593) > group "iPad Status Bar" (id 3603)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   storeSetting "ipad status bar hidden", the hilitedButtonName of me
end mouseUp
