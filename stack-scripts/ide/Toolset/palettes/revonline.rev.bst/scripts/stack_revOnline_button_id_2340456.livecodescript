script "stack_revOnline_button_id_2340456"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > button "resize bar" (id 2340456)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

constant kSnapDistance = 20

local sMouseDown = "false"
  
on mouseDown
  put true into sMouseDown
end mouseDown

on mouseUp
   put false into sMouseDown
   rvoResize "true"
end mouseUp

on mouseRelease
   put false into sMouseDown
   rvoResize "true"
end mouseRelease

on mouseMove
   
   if not sMouseDown then
      exit mouseMove
   end if
   
   local tOffset
   
   #put the width of me * 0.5 into tOffset
   put 1 into tOffset
   
   if item 1 of the mouseLoc + tOffset >= the right of this card of stack "revonline" - 743 then
      exit mouseMove
   end if
   
   if item 1 of the mouseLoc - tOffset <= the left of group "search filter" of stack "revonline" + 180 then
      exit mouseMove
   end if
   
   
   local tHorizontalLoc
   put item 1 of the mouseLoc into tHorizontalLoc
   --   if item 1 of the mouseLoc + tOffset + kSnapDistance >= the right of this card of stack "revonline" - 743 then
   --      put the right of this card of stack "revonline" - 743 - tOffset into tHorizontalLoc
   --   else if item 1 of the mouseLoc - kSnapDistance - tOffset <= the left of this card of stack "revonline" + 180 then
   --      put the left of this card of stack "revonline" + 180 + tOffset into tHorizontalLoc
   --   else
   --      put item 1 of the mouseLoc into tHorizontalLoc
   --   end if
   
   lock screen
   set the loc of me to tHorizontalLoc, (item 2 of the loc of me)
   set the rect of graphic "border" of stack "revonline" to \
          (the right of me - 1, the top of group "paging" of stack "revonline" - 1, the right of this card + 40, the bottom of this card)  
   
   rvoResize
   set the minWidth of stack "revOnline" to item 1 of the loc of me + 743
   unlock screen
end mouseMove
  
  

on mouseEnter
   --   local tOffset
   --   put the width of me * 0.5 into tOffset
   --if the right of me >= the right of this card - 743 then
   --exit mouseEnter
   --end if
   
   --   if item 1 of the mouseLoc - tOffset <= the left of group "search filter" + 180 then
   --      exit mouseEnter
   --   end if
   
   
   if the width of stack "revonline" > 927 then
      lock cursor
      set the cursor to 31
   end if
end mouseEnter

on mouseLeave
  unlock cursor
end mouseLeave
