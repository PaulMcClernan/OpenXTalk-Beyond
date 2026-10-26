script "stack_File_Selector_field_id_1010"
-- Stack file: ide/Toolset/palettes/revfileselector.rev
-- Object: stack "File Selector" > card "File Selector Card" (id 1002) > field "Directories" (id 1010)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if not the visible of field "Files" then put the selectedText of me into field "Selection"
end mouseUp

on mouseDoubleUp
  local olddir
  put the directory into olddir
  set the directory to olddir & "/" & the clickText
  if the result is not empty then
    answer "Can't set to that directory."
    set the directory to olddir
  else refresh
  if not the visible of field "Files" then put empty into field "Selection"
end mouseDoubleUp
