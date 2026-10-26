script "stack_Animate_a_Letter_field_id_1189"
-- Stack file: ide/Resources/Examples/Remastered/Animate a Letter.oxtstack
-- Object: stack "Animate a Letter" > card "Popup" (id 1035) > field "Letter" (id 1189)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --random popup
   local tX, tY
   repeat 8
      put the left of graphic "Stage" + 40 + random(the width of graphic "Stage" - 80) into tX  --a random x on the stage
      put the top of graphic "Stage" + 40 + random(the height of graphic "Stage" - 80) into tY  --and a random y
      set the loc of me to tX,tY
      wait .5 sec with messages
   end repeat
   set the loc of me to the cStartLoc of me  --reset, cStartLoc is a custom property of this object
end mouseUp
