script "stack_revObjectLibrary_button_id_1090"
-- Stack file: ide/Resources/Object Libraries/revObjectLibrary.rev
-- Object: stack "revObjectLibrary" > card "Mac Style Stack Resizer" (id 1089) > button "Mac Style Stack Resizer" (id 1090)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lMoving, lDistance

on mouseDown
  put true into lMoving
  put the right of this stack - item 1 of the screenMouseloc,the bottom of this stack - item 2 of the screenMouseLoc into lDistance
end mouseDown

on mouseUp
  put false into lMoving
  unlock cursor
end mouseUp

on mouseRelease
  put false into lMoving
  unlock Cursor
end mouseRelease

on mouseMove
  if lMoving then
    put item 1 to 2 of the rect of this stack,item 1 of the screenMouseloc+item 1 of lDistance,item 2 of the screenMouseloc+item 2 of lDistance into tRect
    if item 3 of tRect < (the minWidth of this stack+the left of this stack) then put (the minWidth of this stack+the left of this stack) into item 3 of tRect
    if item 4 of tRect < (the minHeight of this stack+the top of this stack) then put (the minHeight of this stack+the top of this stack) into item 4 of tRect
    if item 3 of tRect > (the maxWidth of this stack+the left of this stack) then put (the maxWidth of this stack+the left of this stack) into item 3 of tRect
    if item 4 of tRect > (the maxHeight of this stack+the top of this stack) then put (the maxHeight of this stack+the top of this stack) into item 4 of tRect
    lock screen
    set the rect of this stack to tRect
    set the bottomRight of me to the width of this stack, the height of this stack
    unlock screen
  end if
end mouseMove
