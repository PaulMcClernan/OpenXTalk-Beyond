script "stack_A_Tour_of_SQLite_group_id_1428"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Add Data" (id 1036) > group "Add Data" (id 1428)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tColumnItems, tRowData, tSQL, i
   if gConID = empty then
      showResult "error", "Sorry, please connect to the database first."
      exit to top
   end if
   --
   put "name,email" into tColumnItems
   repeat for each item i in tColumnItems
      ask question "Please enter a new value for column:" && i &"." titled "Add Data To Users"
      if it is empty or the result is "cancel" then exit to top
      put "'" & cleanSQL(it) & "'" & "," after tRowData
   end repeat
   answer question "Does" && item 1 of tRowData && "want to be on the Email List?" with "Cancel" or "No" or "Yes" titled "Add Data To Users"
   if it = "Cancel" then exit to top
   if it = "No" then put "'" & "false" & "'" after tRowData
   else put "'" & "true" & "'" after tRowData
   --
   put "INSERT INTO users(userID,name,email,emailList) VALUES (null," & tRowData & ")" into tSQL
   revExecuteSQL gConID,tSQL
   if the result is an integer then showResult "ok", "A new row has been added to table Users."
   else showResult "error", the result  --(the original answered tResult, a variable it never set)
end mouseUp

function cleanSQL pSQL
   replace "'" with "''" in pSQL  --replace single quote with double quote
   return pSQL
end cleanSQL
