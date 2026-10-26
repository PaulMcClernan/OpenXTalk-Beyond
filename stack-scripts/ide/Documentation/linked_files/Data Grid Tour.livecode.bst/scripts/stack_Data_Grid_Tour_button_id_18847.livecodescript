script "stack_Data_Grid_Tour_button_id_18847"
-- Stack file: ide/Documentation/linked_files/Data Grid Tour.livecode
-- Object: stack "Data Grid Tour" > card "Table" (id 5536) > button "step2" (id 18847)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   lock screen
   resetDemonstration
   
   ## These action handlers can be found in the card script 
   columnsSetNames
   loadData
   
   stepSet 2
   unlock screen
end mouseUp
