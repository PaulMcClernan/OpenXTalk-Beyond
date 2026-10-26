script "stack_DataGrid_Table_group_id_3963"
-- Stack file: ide/Resources/Examples/DataGrid Table.oxtstack
-- Object: stack "DataGrid Table" > card (id 1002) > group "DataGrid 1" (id 3963)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --in dg table main group script
   put line (the dgHilitedLine of me) of the dgText of me into msg  --selected line of data
end mouseUp
