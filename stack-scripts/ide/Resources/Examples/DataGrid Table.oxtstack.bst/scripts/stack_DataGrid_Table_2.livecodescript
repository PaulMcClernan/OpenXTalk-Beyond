script "stack_DataGrid_Table_2"
-- Stack file: ide/Resources/Examples/DataGrid Table.oxtstack
-- Object: stack "DataGrid Table" > card (id 1002) > button "DG > Text" (id 1517)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --dg > text
   local tText
   put the dgText of grp "DataGrid 1" into tText
   put tText into fld "Display"
end mouseUp

--put the dgHilitedLine of grp "DataGrid 1"  --2, if line two is selected
--put line 2 of the dgText of grp "DataGrid 1"  --extract line 2 of tabbed data
--set the itemDel to tab; put item 3 of line 2 of the dgText of grp "Datagrid 1"  --extract data from one cell
