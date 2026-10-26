script "stack_File_Selector_field_id_1006"
-- Stack file: ide/Toolset/palettes/revfileselector.rev
-- Object: stack "File Selector" > card "File Selector Card" (id 1002) > field "Files" (id 1006)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put the clickText into field "Selection"
end mouseUp

on mouseDoubleUp
  send "mouseUp" to button id 1012
end mouseDoubleUp

on rawKeyUp
  put the selectedText of me into field "Selection"
end rawKeyUp
