script "stack_Data_Grid_Tour_button_id_151474"
-- Stack file: ide/Documentation/linked_files/Data Grid Tour.livecode
-- Object: stack "Data Grid Tour" > card "Table" (id 5536) > button "step5" (id 151474)
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
