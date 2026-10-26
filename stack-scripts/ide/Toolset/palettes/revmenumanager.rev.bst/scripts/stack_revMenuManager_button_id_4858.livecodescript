script "stack_revMenuManager_button_id_4858"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menubar" (id 3260) > button "Edit..." (id 4858)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if the cAnswerDialog of field "Menu Name" or the cAnswerDialog of field "Item Name" then
    exit mouseUp
  end if
  
  revCheckNameChanged
  modal "revMenuDialog"
  if the cREVResult of stack "revMenuDialog" is not "OK" then
    pass mouseUp
  end if
  
  revEditMenubar
end mouseUp
