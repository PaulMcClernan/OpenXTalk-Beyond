script "stack_SQLite_Tour_button_id_1233"
-- Stack file: ide/Resources/Examples/SQLite Tour.oxtstack
-- Object: stack "SQLite Tour" > card "Edit Databases" (id 1206) > button "Add Row" (id 1233)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tColumnItems, tRowData, tSQL
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
   if the result is an integer then send "mouseUp" to btn "Refresh Users"
   else answer warning the result with "OK" titled "Error"
end mouseUp

function cleanSQL pSQL
  replace "'" with "''" in pSQL
  return pSQL
end cleanSQL
