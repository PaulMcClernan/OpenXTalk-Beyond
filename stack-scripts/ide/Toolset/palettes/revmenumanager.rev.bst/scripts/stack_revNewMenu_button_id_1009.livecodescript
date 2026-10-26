script "stack_revNewMenu_button_id_1009"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > substack "revNewMenu" > card (id 1002) > button "OK" (id 1009)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

# OK-2007-09-19 : Bug 5410, refactored to make fixing the bug easier
on mouseUp
  closeAccept
  if the result is not empty then
    pass mouseUp
  end if
end mouseUp

