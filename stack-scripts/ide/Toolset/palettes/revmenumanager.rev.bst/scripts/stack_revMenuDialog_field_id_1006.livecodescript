script "stack_revMenuDialog_field_id_1006"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > substack "revMenuDialog" > card (id 1002) > field "Menus" (id 1006)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDoubleUp
  # OK-2007-09-25: Changed this for clarity
  # click at the loc of btn "OK"
  closeAccept
  pass mouseDoubleUp
end mouseDoubleUp

on mouseDown
  # OK-2007-09-25: Bug 5407, we only enable the button if a group has been selected
  # enable btn "OK"
  if the hilitedLine of me is not empty then
    enable button "OK"
  end if
  pass mouseDown
end mouseDown
