script "stack_A_Tour_of_SQLite_group_id_1454"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "View and Delete" (id 1037) > group "Delete Row" (id 1454)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tRowNumber, tUserID, tSQL
   if gConID = empty then
      showResult "error", "Sorry, please connect to the database first."
      exit to top
   end if
   put the hilitedLine of fld "users" into tRowNumber
   if tRowNumber is empty or line tRowNumber of fld "users" is empty then  --no row selected (added: or an empty one)
      showResult "info", "Choose a row of the table first."  --(added)
      exit mouseUp
   end if
   set the itemDel to tab
   put item 1 of line tRowNumber of fld "users" into tUserID
   put "DELETE FROM users WHERE userID=" & tUserID into tSQL
   revExecuteSQL gConID,tSQL
   if the result is an integer then send "mouseUp" to group "Refresh Table"  --(a button of the kit is a group)
   else showResult "error", the result
end mouseUp
