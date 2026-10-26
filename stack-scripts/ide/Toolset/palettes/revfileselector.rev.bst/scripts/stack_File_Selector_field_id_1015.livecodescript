script "stack_File_Selector_field_id_1015"
-- Stack file: ide/Toolset/palettes/revfileselector.rev
-- Object: stack "File Selector" > card "File Selector Card" (id 1002) > field "Directory" (id 1015)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField
  local olddir, newdir
  put the directory into olddir
  put me into newdir
  if newdir contains "/" then
    repeat until the last char of newdir is "/"
      delete last char of newdir
    end repeat
  end if
  set the directory to newdir
  if the result is not empty then
    answer "Can't set to that directory."
    set the directory to olddir
    put olddir into me
  else refresh
end closeField

on openField
  select after last char of me
end openField
