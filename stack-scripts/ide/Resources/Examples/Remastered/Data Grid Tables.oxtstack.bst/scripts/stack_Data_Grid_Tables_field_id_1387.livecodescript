script "stack_Data_Grid_Tables_field_id_1387"
-- Stack file: ide/Resources/Examples/Remastered/Data Grid Tables.oxtstack
-- Object: stack "Data Grid Tables" > card "Lesson 5" (id 1035) > field "Table 1" (id 1387)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField  --conditional color in field table column, msg sent when text changes and fld loses focus
   local tData, tLines, i  --(remaster) i added: strict compilation declares every variable
   put fld "Table 1" into tData
   put number(lines in tData) into tLines
   set the itemDel to tab
   lock screen
   repeat with i = 2 to tLines
      if item -1 of line i of tData is a number and item -1 of line i of tData >= "3" then set the textColor of item -1 of line i of fld "Table 1" to "Red"
      else set the textcolor of item -1 of line i of fld "Table 1" to empty  --default black
   end repeat
end closeField
