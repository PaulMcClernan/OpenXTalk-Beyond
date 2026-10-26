script "stack_revPreferencesGUI_button_id_1058"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Files & Memory" (id 1007) > group "Files & Memory" (id 1041) > button "absoluteImagePaths" (id 1058)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cImageFileRelative of stack "revPreferences" to not (the hilite of me)
end mouseUp
