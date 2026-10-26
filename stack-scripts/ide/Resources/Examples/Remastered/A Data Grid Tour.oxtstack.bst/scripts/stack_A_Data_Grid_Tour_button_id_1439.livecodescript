script "stack_A_Data_Grid_Tour_button_id_1439"
-- Stack file: ide/Resources/Examples/Remastered/A Data Grid Tour.oxtstack
-- Object: stack "A Data Grid Tour" > card "Table" (id 1033) > button "step5" (id 1439)
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
   columnsAddFlags

   stepSet 5
   unlock screen
end mouseUp
