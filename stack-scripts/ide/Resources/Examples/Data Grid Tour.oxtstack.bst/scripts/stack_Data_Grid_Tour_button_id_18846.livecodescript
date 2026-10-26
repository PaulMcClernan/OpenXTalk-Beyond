script "stack_Data_Grid_Tour_button_id_18846"
-- Stack file: ide/Resources/Examples/Data Grid Tour.oxtstack
-- Object: stack "Data Grid Tour" > card "Table" (id 5536) > button "step1" (id 18846)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   lock screen
   resetDemonstration
   
   ## The load data handler found on the card script inserts
   ## our data into the data grid
   loadData
   
   stepSet 1
   unlock screen
end mouseUp
