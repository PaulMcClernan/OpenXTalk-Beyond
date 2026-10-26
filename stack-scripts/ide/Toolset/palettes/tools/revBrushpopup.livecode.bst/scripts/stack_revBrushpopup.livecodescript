script "stack_revBrushpopup"
-- Stack file: ide/Toolset/palettes/tools/revBrushpopup.livecode
-- Object: stack "revBrushpopup"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
   set the blendlevel of this stack to 99
   hide this stack
   lock screen
   set the systemwindow of this stack to true
   set the height of this stack to the cHeight of this stack
   set the itemdelimiter to ","
   put globalLoc(the mouseLoc) into tPos
   put item 2 of tPos + the cHeight of this stack into tVertTest
   if tVertTest > item 4 of the screenrect then
      -- would disappear off the bottom of screen
      put the bottom of stack "revTools" into item 2 of tPos
      set the bottomLeft of this stack to tPos
   else
      -- it's fine, it fits
      put globalLoc(the mouseLoc) into tPos
      set the topLeft of this stack to tPos
   end if
   unlock screen
   send tDelayedShow to me in 1 ticks
end preOpenStack

on tDelayedShow
   show this stack
   set the blendlevel of this stack to 0
end tDelayedShow
