script "stack_A_Data_Grid_Tour_button_id_1436"
-- Stack file: ide/Resources/Examples/Remastered/A Data Grid Tour.oxtstack
-- Object: stack "A Data Grid Tour" > card "Table" (id 1033) > button "step4" (id 1436)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   lock screen
   resetDemonstration

   ## These action handlers can be found in the card script
   columnsSetNames
   loadData
   columnsSetLook
   columnsSetOrder

   stepSet 4
   unlock screen
end mouseUp
