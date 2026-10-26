script "stack_revPreferencesGUI_button_id_1210"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Property Profiles" (id 1012) > group "Property Profiles" (id 1207) > button "Create profiles automatically" (id 1210)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  global gREVAutoCreateProfiles
  put the hilite of me into gREVAutoCreateProfiles
  set the cREVAutoCreateProfiles of stack "revPreferences" to the hilite of me
  if the hilite of me then
    answer warning "If you change an object's profile to a profile name that doesn't exist" \
        & ", a new profile with that name will automatically be added to the object." \
        && "With this option, misspellings and mistakes when setting an object's profile" \
        && "can add unwanted additional profiles to the object." titled "Warning"
  end if
end mouseUp
