script "stack_revMenuManager_button_id_5319"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > button "MacOS Preview" (id 5319)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if not the hilite of me then
    set the defaultMenuBar to the short name of group "revMenuBar" of stack "revMenuBar"
  else
    set the defaultMenuBar to the short name of bg id (the cREVMenuID of this stack) \
        of stack (the cREVDefaultStack of this stack)
  end if
end mouseUp
