script "stack_revNewMenu_field_id_1016"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > substack "revNewMenu" > card (id 1002) > field "Name" (id 1016)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on rawKeyDown
  send "revUpdateDisabling" to me in 10 milliseconds
  pass rawKeyDown
end rawKeyDown
  
on revUpdateDisabling
  if me is empty or field "Menus" is empty or the label of button "Open Stacks" is space then
    disable button "OK"
  else
    enable button "OK"
  end if
end revUpdateDisabling

on returnInField
  # OK-2007-09-19 : Bug 5410, when pressing return in a modal dialog the user will expect the dialog to close, saving changes
  closeAccept
  --select the text of me
end returnInField

on enterInField
  # OK-2007-09-19 : Bug 5410
  closeAccept
end enterInField 
