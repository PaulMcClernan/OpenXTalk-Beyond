script "stack_Animate_Letter_field_id_1094"
-- Stack file: ide/Resources/Examples/Animate Letter.oxtstack
-- Object: stack "Animate Letter" > card (id 1093) > field "Letter" (id 1094)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --make story
   local tChoice1, tChoice2, tChoice3, tStory
   lock screen for visual effect
   if not the visible of group "Fox1" then  --show groups
      show group "Fox1"
      show group "Fox2"
      show group "Fox3"
   else if not the visible of field "Story" then  --load story
      put the label of btn (the hilitedButton of group "Fox1") of group "Fox1" into tChoice1
      put the label of btn (the hilitedButton of group "Fox2") of group "Fox2" into tChoice2
      put the label of btn (the hilitedButton of group "Fox3") of group "Fox3" into tChoice3
      put "A Fox Adventure Story" &cr&cr& \
            "Red Fox wanted to go on an adventure this sunny day and decided to go to" && tChoice1 &cr&cr& \
            "It took almost an hour, but now Red Fox could finally" && tChoice2 &cr&cr& \
            "If you saw Red Fox on one of YOUR adventures, you could say" && quote& tChoice3 &quote into tStory  --"\" continues command to next line 
      put tStory into field "Story"  --display
      show field "Story"
   else  --hide all
      hide group "Fox1"
      hide group "Fox2"
      hide group "Fox3"
      hide field "Story"
   end if
   unlock screen with visual effect dissolve
end mouseUp
