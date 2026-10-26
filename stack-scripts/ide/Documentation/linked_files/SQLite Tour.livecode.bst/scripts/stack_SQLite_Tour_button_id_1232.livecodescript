script "stack_SQLite_Tour_button_id_1232"
-- Stack file: ide/Documentation/linked_files/SQLite Tour.livecode
-- Object: stack "SQLite Tour" > card "Edit Databases" (id 1206) > button "Delete Row" (id 1232)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tNum, tUserID, tSQL
   put the hilitedLine of fld "Users" into tNum
   if tNum is empty then exit mouseUp
   set the itemDel to tab
   put item 1 of line tNum of fld "Users" into tUserID
   put "DELETE FROM users WHERE userID=" & tUserID into tSQL
   revExecuteSQL gConID,tSQL
   if the result is an integer then send "mouseUp" to btn "Refresh Users"
   else answer warning the result with "OK" titled "Error"
end mouseUp
