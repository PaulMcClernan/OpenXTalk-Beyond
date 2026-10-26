script "stack_revNewMenu_field_id_1005"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > substack "revNewMenu" > card (id 1002) > field "Menus" (id 1005)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on rawKeyDown
  send "revUpdateDisabling" to me in 10 milliseconds
  pass rawKeyDown
end rawKeyDown
  
on revUpdateDisabling
  if me is not empty and fld "Name" is not empty and the label of btn "Open Stacks" is not space 
  then enable btn "OK"
  else disable btn "OK"
end revUpdateDisabling

on enterInField
  if me is not empty then click at the loc of btn "OK"
end enterInField
