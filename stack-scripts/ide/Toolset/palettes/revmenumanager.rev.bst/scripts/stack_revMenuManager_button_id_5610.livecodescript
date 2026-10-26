script "stack_revMenuManager_button_id_5610"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menubar" (id 3260) > button "Edit Menu Bar Script" (id 5610)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if the cAnswerDialog of fld "Menu Name" or the cAnswerDialog of fld "Item Name" then exit mouseUp
  revCheckNameChanged
  edit script of bg id (the cREVMenuID of this stack) \
      of stack (the cREVDefaultStack of this stack)
  pass mouseUp
end mouseUp
