script "stack_A_Data_Grid_Tour_card_id_1038"
-- Stack file: ide/Resources/Examples/Remastered/A Data Grid Tour.oxtstack
-- Object: stack "A Data Grid Tour" > card "Properties" (id 1038)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preopencard
   stepSet 1
   pass preOpenCard  --(remaster) so that the window lays this card out
end preopencard

on stepSet pStep
   local x  --(remaster) declared: strict compilation
   ## This iterates over the step 'buttons' on the interface and fades out the buttons not applied.
   repeat with x = 1 to 3
      set the blendLevel of button ("Step" & x) to 50
      hide group ("prop" & x)  --(remaster) each pane is a group here, where it was a picture: hide image ("prop" & x)
      hide field ("prop1")
   end repeat
   set the blendLevel of button ("Step" & pStep) to 0
   show group ("prop" & pStep)  --(remaster) it was show image ("prop" & pStep)
   if pStep = 1 then show field "Prop1"
end stepSet
