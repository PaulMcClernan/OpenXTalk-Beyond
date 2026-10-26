script "stack_SQLite_Tour_button_id_1295"
-- Stack file: ide/Resources/Examples/SQLite Tour.oxtstack
-- Object: stack "SQLite Tour" > card "Introduction" (id 1002) > button "togglePaletteMode" (id 1295)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if the mode of this stack is 1 then
    modeless this stack
  else
    toplevel this stack
  end if
end mouseUp
