script "stack_A_Data_Grid_Tour_button_id_1477"
-- Stack file: ide/Resources/Examples/Remastered/A Data Grid Tour.oxtstack
-- Object: stack "A Data Grid Tour" > card "Form" (id 1034) > button "step1" (id 1477)
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
