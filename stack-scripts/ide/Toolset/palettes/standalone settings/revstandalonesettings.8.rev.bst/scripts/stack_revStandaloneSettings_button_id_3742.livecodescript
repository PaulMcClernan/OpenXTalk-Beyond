script "stack_revStandaloneSettings_button_id_3742"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Basic Settings" (id 30336) > group "Basic Settings" (id 29811) > group (id 3734) > group "Fontmap file" (id 3739) > button "Clear fontmap" (id 3742)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   clearSetting "fontmappings"
end mouseUp
