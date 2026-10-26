script "stack_revSearch_button_id_1376"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002) > button "Card Resize" (id 1376)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lMoving, lCardHorizontalDistance, lMaxRight

on mouseDown
  put true into lMoving
  put the right of btn "Card" - the mouseH into lCardHorizontalDistance
  put the left of sb "Results"+1 into lMaxRight
end mouseDown

on mouseUp
  put false into lMoving
  set the hilitedLines of fld "card" to the hilitedLines of fld "stack"
  set the scroll of fld "card" to the scroll of fld "stack"
end mouseUp

on mouseRelease
  put false into lMoving
  set the hilitedLines of fld "card" to the hilitedLines of fld "stack"
  set the scroll of fld "card" to the scroll of fld "stack"
end mouseRelease

on mouseMove x
  lock screen
  if lMoving then
    put x+lCardHorizontalDistance into tCardRight
    if tCardRight - the left of btn "Card" > the cREVMinWidth of btn "Card" and tCardRight < lMaxRight then
      set the rect of btn "Card" to the topleft of btn "Card", tCardRight, the bottom of btn "Card"
      set the left of btn "Stack" to tCardRight
      set the right me to tCardRight
      
      set the rect of fld "Card" to the topLeft of fld "Card", tCardRight, the bottom of fld "Card"
      set the left of fld "Stack" to the right of fld "Card"-2
      if the right of fld "Stack" < lMaxRight
      then set the rect of fld "Stack" to the topLeft of fld "Stack", lMaxRight, the bottom of fld "Stack"
      set the hilitedLines of fld "card" to the hilitedLines of fld "stack"
      set the scroll of fld "card" to the scroll of fld "stack"
    end if
  end if
  unlock screen
end mouseMove

on mouseEnter
  set the cursor to 31
  lock cursor
end mouseEnter

on mouseLeave
  unlock cursor
end mouseLeave
