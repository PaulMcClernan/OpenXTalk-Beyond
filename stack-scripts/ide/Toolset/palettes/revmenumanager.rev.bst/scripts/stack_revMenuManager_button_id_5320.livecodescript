script "stack_revMenuManager_button_id_5320"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > button "MacOS Menu Bar" (id 5320)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  revCheckNameChanged
  if the hilite of me then  --set menubar    
    set the menubar of stack (the cREVDefaultStack of this stack) to the short name \
        of bg id (the cREVMenuID of this stack) of stack (the cREVDefaultStack of this stack)
  else set the menubar of stack (the cREVDefaultStack of this stack) to empty
  pass mouseUp
end mouseUp
