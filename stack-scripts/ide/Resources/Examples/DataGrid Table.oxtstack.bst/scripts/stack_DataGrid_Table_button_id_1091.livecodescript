script "stack_DataGrid_Table_button_id_1091"
-- Stack file: ide/Resources/Examples/DataGrid Table.oxtstack
-- Object: stack "DataGrid Table" > card (id 1002) > group "Nav" (id 1092) > button "Next >" (id 1091)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   go next cd
   set the vScroll of fld "Info" to "0"  --top
end mouseUp
