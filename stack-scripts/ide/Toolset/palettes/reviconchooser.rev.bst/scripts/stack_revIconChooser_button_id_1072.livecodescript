script "stack_revIconChooser_button_id_1072"
-- Stack file: ide/Toolset/palettes/reviconchooser.rev
-- Object: stack "revIconChooser" > card (id 1002) > button "OK" (id 1072)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cReturnValue of this stack to fld "ID"
  close this stack
  exit to top
end mouseUp
