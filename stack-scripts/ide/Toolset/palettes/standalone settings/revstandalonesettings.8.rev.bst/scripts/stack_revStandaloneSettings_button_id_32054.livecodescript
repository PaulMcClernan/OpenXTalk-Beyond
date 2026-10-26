script "stack_revStandaloneSettings_button_id_32054"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Basic Settings" (id 30336) > group "Basic Settings" (id 29811) > group "Basic Application Settings" (id 3462) > button "supports dark mode" (id 32054)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   storeSetting "supports dark mode", the hilite of me
end mouseUp
