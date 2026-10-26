script "stack_Animate_Letter_field_id_1031"
-- Stack file: ide/Resources/Examples/Animate Letter.oxtstack
-- Object: stack "Animate Letter" > card (id 1030) > field "Letter" (id 1031)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --jump
   local tStartLoc
   put the loc of me into tStartLoc  --starting point
   move me relative 0,-40  --move up to new point
   wait .5 sec with messages  --optional
   move me from the loc of me to tStartLoc  --move back
end mouseUp

--x,y point on card: position mouseArrow, in msg box type "put mouseLoc()", press returnKey (enter).
