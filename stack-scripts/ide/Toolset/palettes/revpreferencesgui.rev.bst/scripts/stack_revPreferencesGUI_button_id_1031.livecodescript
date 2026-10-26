script "stack_revPreferencesGUI_button_id_1031"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "General" (id 1002) > group "General" (id 1016) > group (id 1029) > button "Image Editor..." (id 1031)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put the cEditorpath of stack "revPreferences" into tEditorPath
  set the itemDel to "/"
  put item 1 to -1 of tEditorPath into tSelector
  set the itemDel to comma
  answer file "Select an image editor:" with tSelector
  lock screen
  if it is not empty then
    put it into fld "external editor"
    set the cEditorpath of stack "revPreferences" to the text of fld "external editor"
    set the itemDel to "/"
    put item -1 of fld "external editor" into fld "external editor"
    set the itemDel to comma
  end if
  unlock screen
end mouseUp
