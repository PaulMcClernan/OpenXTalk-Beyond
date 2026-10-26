script "stack_Animate_Letter_field_id_1054"
-- Stack file: ide/Resources/Examples/Animate Letter.oxtstack
-- Object: stack "Animate Letter" > card (id 1053) > field "Letter2" (id 1054)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --dropping popup
   local tX, tY
   put random(the right of this cd -40)+20 into tX  --x-axis coordinate, 20 to width in pixels-20
   put the bottom of this cd - 200 into tY  --y-axis coordinate
   set the loc of me to tX,tY
   wait .75 sec with messages
   repeat 4
      set the loc of me to (item 1 of the loc of me) , (item 2 of the loc of me + 50)  --drop down in 50 pixel increments (200 px total)
      wait .75 sec with messages
   end repeat
   set the loc of me to the cStartLoc of me  --reset, cStartLoc is a custom property of this object
end mouseUp
