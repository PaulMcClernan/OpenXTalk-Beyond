script "stack_DataGrid_Table_field_id_4897"
-- Stack file: ide/Resources/Examples/DataGrid Table.oxtstack
-- Object: stack "DataGrid Table" > card (id 4896) > field "Table 1" (id 4897)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField  --conditional color in field table column, msg sent when text changes and fld loses focus
   local tData, tLines
   put fld "Table 1" into tData
   put number(lines in tData) into tLines
   set the itemDel to tab
   lock screen
   repeat with i = 2 to tLines
      if item -1 of line i of tData is a number and item -1 of line i of tData >= "3" then set the textColor of item -1 of line i of fld "Table 1" to "Red"
      else set the textcolor of item -1 of line i of fld "Table 1" to empty  --default black
   end repeat
end closeField
