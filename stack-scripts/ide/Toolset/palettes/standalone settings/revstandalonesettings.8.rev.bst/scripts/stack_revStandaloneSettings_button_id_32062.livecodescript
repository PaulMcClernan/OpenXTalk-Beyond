script "stack_revStandaloneSettings_button_id_32062"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Splash" (id 3538) > group "launch-image-dark-1x" (id 32061) > button "Splash Chooser4" (id 32062)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   chooseImageFile the short name of the owner of me
end mouseUp

