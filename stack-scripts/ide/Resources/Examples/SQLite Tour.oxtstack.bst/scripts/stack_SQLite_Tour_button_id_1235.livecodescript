script "stack_SQLite_Tour_button_id_1235"
-- Stack file: ide/Resources/Examples/SQLite Tour.oxtstack
-- Object: stack "SQLite Tour" > card "Edit Databases" (id 1206) > button "Delete Row" (id 1235)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tNum, tAppID, tSQL
   put the hilitedLine of fld "Apps" into tNum
   if tNum is empty then exit mouseUp
   set the itemDel to tab
   put item 1 of line tNum of fld "Apps" into tAppID
   put "DELETE FROM apps WHERE appID=" & tAppID into tSQL
   revExecuteSQL gConID,tSQL
   if the result is an integer then send "mouseUp" to btn "Refresh Apps"
   else answer warning the result with "OK" titled "Error"
end mouseUp
