script "stack_Print_Dialog_scrollbar_id_5738"
-- Stack file: ide/Toolset/palettes/revprintdialog.rev
-- Object: stack "Print Dialog" > card (id 1002) > group "Copies" (id 1417) > group (id 5712) > scrollbar "Copy scroll" (id 5738)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

# Code for the inc/decrement arrows in the number of print copies field
on scrollbarLineDec
  lock screen
  subtract 1 from field "No of copies"
  if field "No of copies" < 1 then
    put 1 into field "No of copies"
  end if
  unlock screen
end scrollbarLineDec

on scrollbarLineInc
  add 1 to field "No of copies"
end scrollbarLineInc
