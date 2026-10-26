script "stack_Print_Dialog_group_id_9388"
-- Stack file: ide/Toolset/palettes/revprintdialog.rev
-- Object: stack "Print Dialog" > card (id 1002) > group "Print Target" (id 1442) > group "Printer List" (id 1431) > group "Lexmark C532 PS (MS)" (id 9388)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

setProp cName pValue
  set the cActualValue of me to pValue
  
  set the itemDelimiter to backslash
  put item -1 of pValue into field "Name" of me
  
  set the height of field "Name" of me to the formattedHeight of field "Name" of me
  set the width of field "Name" of me to the formattedWidth of field "Name" of me
  
  set the top of field "Name" of me to the bottom of image "Printer" of me
  
  set the itemDelimiter to comma
  set the loc of field "Name" of me to item 1 of the loc of me, item 2 of the loc of field "Name" of me
end cName

getProp cName
  return the cActualValue of me
end cName

local sHilite

setProp cHilite pValue
  if pValue is "true" then
    put true into sHilite
    set the backgroundColor of field "Name" of me to fieldHiliteColor()
    set the foregroundColor of field "Name" of me to "white"
    set the opaque of field "Name" of me to true
    set the visible of graphic "Overlay" of me to true
  else
    set the backgroundColor of field "Name" of me to empty
    set the foregroundColor of field "Name" of me to empty
    set the opaque of field "Name" of me to false
    set the visible of graphic "Overlay" of me to false
    put false into sHilite
  end if
end cHilite

getProp cHilite
  return sHilite
end cHilite



