script "stack_revStandaloneSettings_button_id_3485"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Basic Settings" (id 30336) > group "Basic Settings" (id 29811) > group "User Interface Options" (id 3483) > button "iPhone Intial Orientation" (id 3485)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   replace space with empty in pItemName
   replace "-" with empty in pItemName
   storeSetting "iphone initial orientation", pItemName
   updateOrientationSettings
end menuPick
