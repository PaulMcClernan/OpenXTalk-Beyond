script "stack_revStandaloneSettings_button_id_3598"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Basic Settings" (id 30336) > group "Basic Settings" (id 29811) > group (id 3593) > button "Status Bar Style" (id 3598)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   replace space with empty in pItemName
   storeSetting "status bar style", pItemName
end menuPick
