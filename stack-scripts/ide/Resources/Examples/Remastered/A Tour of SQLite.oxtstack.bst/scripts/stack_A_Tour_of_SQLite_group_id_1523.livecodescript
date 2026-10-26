script "stack_A_Tour_of_SQLite_group_id_1523"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Both Tables" (id 1039) > group "Add User" (id 1523)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--(the original's "Add Row" of the table users)
on mouseUp
   global gConID
   local tColumnItems, tRowData, tSQL, i
   if gConID = empty then  --(added, as the other buttons do)
      showResult "error", "Sorry, please connect to the database first."
      exit to top
   end if
   put "name,email" into tColumnItems
   repeat for each item i in tColumnItems
      ask question "New value for column:" && i titled "Add Users Row"
      if it is empty or the result is "Cancel" then exit to top
      put "'" & cleanSQL(it) & "'" & "," after tRowData
   end repeat
   answer question "Does" && item 1 of tRowData && "want to be on the Email List?" with "Cancel" or "No" or "Yes" titled "Add Users Row"
   if it = "Cancel" then exit to top
   if it = "No" then put "'" & "false" & "'" after tRowData
   else put "'" & "true" & "'" after tRowData
   put "INSERT INTO users(userID,name,email,emailList) VALUES(null," & tRowData & ")" into tSQL
   revExecuteSQL gConID,tSQL
   if the result is an integer then send "mouseUp" to group "Refresh Users"
   else showResult "error", the result
end mouseUp

function cleanSQL pSQL
   replace "'" with "''" in pSQL
   return pSQL
end cleanSQL
