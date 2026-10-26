script "stack_revMenuManager_scrollbar_id_4838"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menu Items:" (id 3226) > scrollbar "Menu Items" (id 4838)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on scrollbarDrag pWhich
  global gREVTextHeight
  lock screen
  put round(pWhich/gREVTextHeight) into tTopLine
  put tTopLine * gREVTextHeight into tNewScroll
  if the scroll of fld "Menu Items" is not tNewScroll then
    set the scroll of fld "Menu Items" to tNewScroll
    revResetTriangles
    set the cREVLine of grp "Item Insert" to round(((item 2 of the loc of grp "Item Insert" - the top of fld "Menu Items")/gREVTextHeight) + (the scroll of fld "Menu Items"/gREVTextHeight))
  end if
  unlock screen
  pass scrollbarDrag
end scrollbarDrag
