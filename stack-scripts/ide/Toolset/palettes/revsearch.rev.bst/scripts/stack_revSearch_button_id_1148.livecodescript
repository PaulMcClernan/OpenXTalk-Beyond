script "stack_revSearch_button_id_1148"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002) > button "New Button" (id 1148)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lMoving, lDistance

on mouseDown
  put true into lMoving
  put the right of this stack - item 1 of the screenMouseloc,the bottom of this stack - item 2 of the screenMouseLoc into lDistance
end mouseDown

on mouseUp
  put false into lMoving
end mouseUp

on mouseRelease
  put false into lMoving
end mouseRelease

on mouseMove
  if lMoving then
    put item 1 to 3 of the rect of this stack,item 2 of the screenMouseloc+item 2 of lDistance into tRect
    if item 3 of tRect < (the minWidth of this stack+the left of this stack) then put (the minWidth of this stack+the left of this stack) into item 3 of tRect
    if item 4 of tRect < (the minHeight of this stack+the top of this stack) then put (the minHeight of this stack+the top of this stack) into item 4 of tRect
    set the rect of this stack to tRect
    set the bottom of me to the height of this stack
    set the bottom of grp "Controls" to the top of me +4
    set the rect of fld "Results" to item 1 to 3 of the rect of fld "Results",the top of grp "Controls" -1
  end if
end mouseMove

on mouseEnter
  if the platform is not "MacOS" then
    set cursor to 200308
    set the lockCursor to true
  end if
end mouseEnter

on mouseLeave
  set the lockCursor to false
end mouseLeave
