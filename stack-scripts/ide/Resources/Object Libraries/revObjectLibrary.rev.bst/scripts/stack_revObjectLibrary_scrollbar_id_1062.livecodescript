script "stack_revObjectLibrary_scrollbar_id_1062"
-- Stack file: ide/Resources/Object Libraries/revObjectLibrary.rev
-- Object: stack "revObjectLibrary" > card "Scrolling Scrollbar" (id 1061) > scrollbar "Scrollbar for Fields and Groups" (id 1062)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on scrollBarDrag x
  if the cTargetType of me is "field" then
    put the formattedHeight of fld (the cTargetName of me) - the height of fld (the cTargetName of me) into tScrollDistance
    set the scroll of fld (the cTargetName of me) to round(((tScrollDistance/100) * x))
  else if the cTargetType of me is "group" then
    put the formattedHeight of grp (the cTargetName of me) - the height of grp (the cTargetName of me) into tScrollDistance
    set the scroll of grp (the cTargetName of me) to round(((tScrollDistance/100) * x))
  end if
end scrollBarDrag
