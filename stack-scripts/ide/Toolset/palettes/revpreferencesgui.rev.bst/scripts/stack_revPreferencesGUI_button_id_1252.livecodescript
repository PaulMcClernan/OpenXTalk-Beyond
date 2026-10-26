script "stack_revPreferencesGUI_button_id_1252"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Object Sizes" (id 1009) > button "Reset Object Sizes" (id 1252)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  local tName
  
  repeat for each line tDefaultSize in the cDefaultSizes of stack "revPreferences"
    put item 1 of tDefaultSize into tName
    set the tName of stack "revPreferences" to item 2 of tDefaultSize
  end repeat
  updateDefaultSizeFields
end mouseUp
