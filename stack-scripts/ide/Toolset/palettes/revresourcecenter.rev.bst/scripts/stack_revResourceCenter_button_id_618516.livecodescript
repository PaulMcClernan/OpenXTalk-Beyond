script "stack_revResourceCenter_button_id_618516"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Textmenu:populatingwithcontent" (id 82654) > group (id 2127) > button "resizeButton" (id 618516)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

constant kSnapDistance = 20

local sMouseDown = "false"
  
on mouseDown
  put true into sMouseDown
end mouseDown

on mouseUp
  put false into sMouseDown
end mouseUp

on mouseRelease
  put false into sMouseDown
end mouseRelease

on mouseMove
   
   if not sMouseDown then
      exit mouseMove
   end if
   
   local tOffset
   
   put the width of me * 0.5 into tOffset
   
   if item 1 of the mouseLoc + tOffset >= the right of this card then
      exit mouseMove
   end if
   
   if item 1 of the mouseLoc - tOffset <= the left of group "Tree" + 10 then
      exit mouseMove
   end if
   
   local tHorizontalLoc
   put item 1 of the mouseLoc into tHorizontalLoc
   
   
   lock screen
   set the loc of me to tHorizontalLoc, (item 2 of the loc of me)
   prefSet "treeSplit", the left of me
   
   --setConstant
   resizeStack
   unlock screen
end mouseMove
  
  

on mouseEnter
   lock cursor
   set the cursor to 31
end mouseEnter

on mouseLeave
  unlock cursor
end mouseLeave
