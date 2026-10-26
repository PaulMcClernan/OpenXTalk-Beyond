script "stack_SQLite_Tour_button_id_1181"
-- Stack file: ide/Resources/Examples/SQLite Tour.oxtstack
-- Object: stack "SQLite Tour" > card "View And Delete Data" (id 1153) > button "Delete Row" (id 1181)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tRowNumber, tUserID, tSQL
   if gConID = empty then
      answer "Sorry, please connect to the database first." with "OK" titled "Error"
      exit to top
   end if
   put the hilitedLine of fld "users" into tRowNumber
   if tRowNumber is empty then exit mouseUp  --no row selected
   set the itemDel to tab
   put item 1 of line tRowNumber of fld "users" into tUserID
   put "DELETE FROM users WHERE userID=" & tUserID into tSQL
   revExecuteSQL gConID,tSQL
   if the result is an integer then send "mouseUp" to btn "Refresh Table"
   else answer warning the result with "OK" titled "Error"
end mouseUp
