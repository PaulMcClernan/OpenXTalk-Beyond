script "stack_Animate_Letter_field_id_1057"
-- Stack file: ide/Resources/Examples/Animate Letter.oxtstack
-- Object: stack "Animate Letter" > card (id 1056) > field "Letter" (id 1057)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --dance crazy
   local tStartLoc
   put the loc of me into tStartLoc  --starting point
   put the loc of this card into tEndLoc
   move me from tStartLoc to tEndLoc  --move to new point
   repeat 15
      move me relative (item random(4) of "-15,-10,10,15",0)  --side to side
      wait .25 sec with messages
   end repeat
   move me from the loc of me to tStartLoc  --move back
end mouseUp

--x,y point on card: position mouseArrow, in msg box type "put mouseLoc()", press returnKey (enter).
