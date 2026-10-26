script "stack_revSearch_button_id_1374"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002) > button "Type Resize" (id 1374)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lMoving, lTypeHorizontalDistance, lMaxRight

on mouseDown
  put true into lMoving
  put the right of btn "Type" - the mouseH into lTypeHorizontalDistance
  put the left of sb "Results"+1 into lMaxRight
end mouseDown

on mouseUp
  put false into lMoving
  set the hilitedLines of fld "type" to the hilitedLines of fld "stack"
  set the scroll of fld "type" to the scroll of fld "stack"
end mouseUp

on mouseRelease
  put false into lMoving
  set the hilitedLines of fld "type" to the hilitedLines of fld "stack"
  set the scroll of fld "type" to the scroll of fld "stack"
end mouseRelease

on mouseMove x
  lock screen
  if lMoving then
    put x+lTypeHorizontalDistance into tTypeRight    
    if tTypeRight - the left of btn "Type" > the cREVMinWidth of btn "Type" and tTypeRight < lMaxRight then
      set the rect of btn "Type" to the topleft of btn "Type", tTypeRight, the bottom of btn "Type"
      set the left of btn "Name" to tTypeRight
      set the left of btn "Card" to the right of btn "Name"
      set the left of btn "Stack" to the right of btn "Card"
      set the right me to tTypeRight
      set the right of btn "Name Resize" to the right of btn "Name"
      set the right of btn "Card Resize" to the right of btn "Card"
      
      set the rect of fld "type" to the topLeft of fld "type", tTypeRight, the bottom of fld "type"
      set the left of fld "Name" to tTypeRight-2
      set the left of fld "Card" to the right of fld "Name"-2
      set the left of fld "Stack" to the right of fld "Card"-2
      if the right of fld "Stack" < lMaxRight
      then set the rect of fld "Stack" to the topLeft of fld "Stack", lMaxRight, the bottom of fld "Stack"
      set the hilitedLines of fld "type" to the hilitedLines of fld "stack"
      set the scroll of fld "type" to the scroll of fld "stack"
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
