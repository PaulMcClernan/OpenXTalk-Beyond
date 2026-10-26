script "stack_revStandaloneSettings_group_id_2246"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Android" (id 2060) > group "Android Settings" (id 2072) > group "User Interface Options" (id 2238) > group "Status Bar" (id 2246)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   storeSetting "status bar hidden", the hilitedButtonName of me
end mouseUp
