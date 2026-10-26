script "stack_Animate_a_Letter_field_id_1192"
-- Stack file: ide/Resources/Examples/Remastered/Animate a Letter.oxtstack
-- Object: stack "Animate a Letter" > card "Dance Crazy" (id 1036) > field "Letter2" (id 1192)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --dance crazy
   local tStartLoc, tEndLoc
   put the loc of me into tStartLoc  --starting point
   put the loc of graphic "Stage" into tEndLoc  --the middle of the stage
   move me from tStartLoc to tEndLoc  --move to new point
   repeat 15
      move me relative random(50)-25 , random(50)-25  --+25 to -25
      wait .25 sec with messages
   end repeat
   move me from the loc of me to tStartLoc  --move back
end mouseUp
