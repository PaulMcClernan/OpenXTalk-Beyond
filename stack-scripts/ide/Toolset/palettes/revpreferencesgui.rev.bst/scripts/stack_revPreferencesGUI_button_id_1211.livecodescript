script "stack_revPreferencesGUI_button_id_1211"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Property Profiles" (id 1012) > group "Property Profiles" (id 1207) > button "Don't save changes" (id 1211)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  global gREVProfileReadOnly
  put the hilite of me into gREVProfileReadOnly
  set the cREVProfileReadOnly of stack "revPreferences" to the hilite of me
    if the hilite of me then
    answer warning "This option should only be used if you do not plan to make permanent changes" \
   && "to object properties. Before using this option, all objects should be set to their master profile." \
   && "If you have switched objects to other profiles and made changes since the switch, these changes" \
   && "will be lost unless you turn this option off now." titled "Warning"
  end if
end mouseUp
