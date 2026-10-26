script "stack_Data_Grid_Tour_card_id_17771"
-- Stack file: ide/Documentation/linked_files/Data Grid Tour.livecode
-- Object: stack "Data Grid Tour" > card "Properties" (id 17771)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preopencard
   stepSet 1
end preopencard

on stepSet pStep
   ## This iterates over the step 'buttons' on the interface and fades out the buttons not applied.
   repeat with x = 1 to 3
      set the blendLevel of button ("Step" & x) to 50
      hide image ("prop" & x)
      hide field ("prop1")
   end repeat
   set the blendLevel of button ("Step" & pStep) to 0
   show image ("prop" & pStep)
   if pStep = 1 then show field "Prop1"
end stepSet
