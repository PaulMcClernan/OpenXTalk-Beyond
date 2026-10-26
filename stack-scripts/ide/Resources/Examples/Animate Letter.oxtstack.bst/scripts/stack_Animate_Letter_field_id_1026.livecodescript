script "stack_Animate_Letter_field_id_1026"
-- Stack file: ide/Resources/Examples/Animate Letter.oxtstack
-- Object: stack "Animate Letter" > card (id 1025) > field "Letter" (id 1026)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --move me
   local tStartLoc
   put the loc of me into tStartLoc  --starting point
   put the loc of this card into tEndLoc
   move me from tStartLoc to tEndLoc  --move to new point
   wait .5 sec with messages  --optional
   move me from tEndLoc to tStartLoc  --move back
end mouseUp

--x,y point on card: position mouseArrow, in msg box type "put mouseLoc()", press returnKey (enter).
