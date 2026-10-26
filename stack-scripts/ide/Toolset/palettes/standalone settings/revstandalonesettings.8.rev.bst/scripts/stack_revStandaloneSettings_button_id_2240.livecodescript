script "stack_revStandaloneSettings_button_id_2240"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Android" (id 2060) > group "Android Settings" (id 2072) > group "User Interface Options" (id 2238) > button "Initial Orientation" (id 2240)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   replace space with empty in pItemName
   replace "-" with empty in pItemName
   storeSetting "initial orientation", tolower(pItemName)
   updateOrientationSettings
end menuPick
