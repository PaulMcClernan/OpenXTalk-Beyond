script "stack_Animate_a_Letter_field_id_1182"
-- Stack file: ide/Resources/Examples/Remastered/Animate a Letter.oxtstack
-- Object: stack "Animate a Letter" > card "Move Around" (id 1032) > field "Letter" (id 1182)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --move me
   local tStartLoc, tEndLoc
   put the loc of me into tStartLoc  --starting point
   put the loc of graphic "Stage" into tEndLoc  --the middle of the stage
   move me from tStartLoc to tEndLoc  --move to new point
   wait .5 sec with messages  --optional
   move me from tEndLoc to tStartLoc  --move back
end mouseUp

--x,y point on card: position mouseArrow, in msg box type "put mouseLoc()", press returnKey (enter).
