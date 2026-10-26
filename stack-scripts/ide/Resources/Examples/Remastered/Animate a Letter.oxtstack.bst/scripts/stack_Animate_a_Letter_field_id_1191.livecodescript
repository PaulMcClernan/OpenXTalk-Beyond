script "stack_Animate_a_Letter_field_id_1191"
-- Stack file: ide/Resources/Examples/Remastered/Animate a Letter.oxtstack
-- Object: stack "Animate a Letter" > card "Dance Crazy" (id 1036) > field "Letter" (id 1191)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --dance crazy
   local tStartLoc, tEndLoc
   put the loc of me into tStartLoc  --starting point
   put the loc of graphic "Stage" into tEndLoc  --the middle of the stage
   move me from tStartLoc to tEndLoc  --move to new point
   repeat 15
      move me relative (item random(4) of "-15,-10,10,15",0)  --side to side
      wait .25 sec with messages
   end repeat
   move me from the loc of me to tStartLoc  --move back
end mouseUp
