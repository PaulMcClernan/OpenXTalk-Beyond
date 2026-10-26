script "stack_revStandaloneSettings_button_id_32072"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > group "Splash" (id 3538) > group "launch-image-dark-3x" (id 32069) > button "Splash Chooser6" (id 32072)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   chooseImageFile the short name of the owner of me
end mouseUp
