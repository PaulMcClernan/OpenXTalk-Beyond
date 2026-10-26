script "stack_Data_Grid_Tour_button_id_168161"
-- Stack file: ide/Resources/Examples/Data Grid Tour.oxtstack
-- Object: stack "Data Grid Tour" > card "Form" (id 5539) > button "step2" (id 168161)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   lock screen
   resetDemonstration
   
   ## These action handlers can be found in the card script 
   formatForm
   loadData
   
   stepSet 2
   unlock screen
end mouseUp
