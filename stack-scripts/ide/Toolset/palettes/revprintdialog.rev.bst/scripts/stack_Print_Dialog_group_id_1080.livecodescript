script "stack_Print_Dialog_group_id_1080"
-- Stack file: ide/Toolset/palettes/revprintdialog.rev
-- Object: stack "Print Dialog" > card (id 1002) > group "Range" (id 1080)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if the hilite of button "Page range select" is true then
    set the enabled of field "Pages" to true
  else
    set the enabled of field "Pages" to false
  end if
  pass mouseUp
end mouseUp


 
 
