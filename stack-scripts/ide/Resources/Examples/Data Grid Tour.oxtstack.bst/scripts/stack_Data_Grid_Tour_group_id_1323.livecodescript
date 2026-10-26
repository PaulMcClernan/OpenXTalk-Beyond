script "stack_Data_Grid_Tour_group_id_1323"
-- Stack file: ide/Resources/Examples/Data Grid Tour.oxtstack
-- Object: stack "Data Grid Tour" > card "Welcome" (id 73190) > group "Chrome" (id 1321) > group "Scroller" (id 1323)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local maydrag, maxleft, maxright, w

on mouseleave
   unlock cursor
end mouseleave

on mouseenter
   set cursor to hand
   set the lockcursor to true
   put trunc(the width of me / 2) into w
   put the left of grc "Scroll Well" + w into maxleft
   put the right of grc "Scroll Well" - w into maxright
end mouseenter

on mousedown
   put true into maydrag
end mousedown

on mouseup
   put false into maydrag
   go to cd fld "Scroll Page"
   adjustSlider
end mouseup

on mouserelease
   mouseup
end mouserelease

on mousemove x,y
   if not maydrag then exit mousemove
   put max(maxleft, min(maxright, x)) into x
   set the loc of me to x, item 2 of the loc of me
   
   -- find which segment i'm within
   repeat with i = 1 to the numSegs of group "Scroll Well" 
      if the loc of me is within the rect of grc ("s" && i) then exit repeat
   end repeat
   
   -- update thumb display
   if the left of me <= left of grc "Scroll Well" then put 1 into i
   if the right of me >= right of grc "Scroll Well" then put the number of cards into i
   put i into fld "Scroll Page"
   put the short name of cd i into fld "Page Title"
   
   unlock screen

end mousemove
