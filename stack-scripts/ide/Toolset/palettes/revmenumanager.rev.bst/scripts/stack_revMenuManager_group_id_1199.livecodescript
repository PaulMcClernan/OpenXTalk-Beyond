script "stack_revMenuManager_group_id_1199"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Item Insert" (id 1199)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lMouseDown, lBottom, lTop

on mouseDown
  if the owner of the target is me then 
    put true into lMouseDown
    put the top of fld "Menu Items" into lTop
    put the bottom of fld "Menu Items" into lBottom
  end if
  pass mouseDown
end mouseDown

on mouseUp
  if the owner of the target is me then 
    put false into lMouseDown
    revMouseReleased
  end if
  pass mouseUp
end mouseUp

on mouseRelease
  if the owner of the target is me then 
    put false into lMouseDown
    revMouseReleased
  end if
  pass mouseRelease
end mouseRelease

on mouseMove x,y
  if the owner of the target is not me or the text of fld "Menu Items" is empty then pass mouseMove
  if lMouseDown  and y > lTop and y < lBottom 
  then set the loc of me to item 1 of the loc of me,y
  pass mouseMove
end mouseMove

on revMouseReleased
  global gREVTextHeight
  put the mouseV - lTop into tMouseV
  if the scroll of fld "Menu Items" is 0 then subtract 5 from tMouseV -- adjustment factor
  put max(0,round(tMouseV/gREVTextHeight)) into tLineScroll
  
  if tLineScroll > the num of lines in fld "Menu Items"
  then put the num of lines in fld "Menu Items" into tLineScroll
  put (tLineScroll * gREVTextHeight) + lTop - (the scroll of fld "Menu Items" mod gREVTextHeight) + 5 into tVertical
  if tVertical > lBottom then put lBottom into tVertical
  if tVertical < lTop then put lTop into tVertical
  set the loc of me to item 1 of the loc of me, tVertical
  set the cREVLine of me to round (the scroll of fld "Menu Items"/gREVTextHeight) + tLineScroll
end revMouseReleased

on mouseDoubleUp
  if the owner of the target is not me then pass mouseDoubleUp
  put the num of lines in fld "Menu Items" into tNumLines
  set the loc of me to item 1 of the loc of me, min(lBottom,the formattedTop of line tNumLines of fld "Menu Items" + 16)
  put the formattedHeight of fld "Menu Items" into tFormattedHeight
  set the scroll of fld "Menu Items" to tFormattedHeight
  set the thumbPosition of sb "Menu Items" to tFormattedHeight
  set the cREVLine of me to tNumLines
  pass mouseDoubleUp
end mouseDoubleUp
