script "stack_revStandaloneSettings_button_id_2802"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Android" (id 2060) > group "Android Settings" (id 2072) > group "Basic Application Settings" (id 2073) > button "Install Location" (id 2802)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   storeSetting "installLocation", pItemName
   updateSettings
end menuPick
