script "stack_A_Tour_of_SQLite_group_id_1520"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Both Tables" (id 1039) > group "Delete User" (id 1520)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--(the original's "Delete Row" of the table users)
on mouseUp
   global gConID
   local tNum, tUserID, tSQL
   put the hilitedLine of fld "Users" into tNum
   if tNum is empty or line tNum of fld "Users" is empty then  --(added: no row chosen, or an empty one)
      showResult "info", "Choose a row of users first."  --(added)
      exit mouseUp
   end if
   set the itemDel to tab
   put item 1 of line tNum of fld "Users" into tUserID
   put "DELETE FROM users WHERE userID=" & tUserID into tSQL
   revExecuteSQL gConID,tSQL
   if the result is an integer then send "mouseUp" to group "Refresh Users"
   else showResult "error", the result
end mouseUp
