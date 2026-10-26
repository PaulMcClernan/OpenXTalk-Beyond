script "stack_Data_Grid_Tables_group_id_1155"
-- Stack file: ide/Resources/Examples/Remastered/Data Grid Tables.oxtstack
-- Object: stack "Data Grid Tables" > card "Lesson 1" (id 1031) > group "DataGrid 1" (id 1155)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --in dg table main group script
   put line (the dgHilitedLine of me) of the dgText of me into msg  --selected line of data
   put msg into fld "Message"  --added: the message box, under the grid too
end mouseUp
