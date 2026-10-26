script "stack_Animate_a_Letter_field_id_1190"
-- Stack file: ide/Resources/Examples/Remastered/Animate a Letter.oxtstack
-- Object: stack "Animate a Letter" > card "Popup" (id 1035) > field "Letter2" (id 1190)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --dropping popup
   local tX, tY
   put the left of graphic "Stage" + 40 + random(the width of graphic "Stage" - 80) into tX  --x-axis coordinate, anywhere across the stage
   put the bottom of graphic "Stage" - 240 into tY  --y-axis coordinate
   set the loc of me to tX,tY
   wait .75 sec with messages
   repeat 4
      set the loc of me to (item 1 of the loc of me) , (item 2 of the loc of me + 50)  --drop down in 50 pixel increments (200 px total)
      wait .75 sec with messages
   end repeat
   set the loc of me to the cStartLoc of me  --reset, cStartLoc is a custom property of this object
end mouseUp
