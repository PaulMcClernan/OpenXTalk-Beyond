script "stack_Animate_Letter_field_id_1055"
-- Stack file: ide/Resources/Examples/Animate Letter.oxtstack
-- Object: stack "Animate Letter" > card (id 1053) > field "Letter" (id 1055)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --random popup
   repeat 8
      set the loc of me to random(300)+100 , random(300)+100  --random x,y within card
      wait .5 sec with messages
   end repeat
   set the loc of me to the cStartLoc of me  --reset, cStartLoc is a custom property of this object
end mouseUp

--random(300)+100 = 101 to 400  (card x,y = 485,445)
