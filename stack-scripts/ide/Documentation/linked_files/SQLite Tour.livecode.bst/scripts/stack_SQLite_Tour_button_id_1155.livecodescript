script "stack_SQLite_Tour_button_id_1155"
-- Stack file: ide/Documentation/linked_files/SQLite Tour.livecode
-- Object: stack "SQLite Tour" > card "Add Data" (id 1106) > button "Add Data To Users" (id 1155)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tColumnItems, tRowData, tSQL
   if gConID = empty then
      answer "Sorry, please connect to the database first." with "OK" titled "Error"
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
   if the result is an integer then answer information "A new row has been added to table Users." with "OK" titled "Add Data To Users"
   else answer warning tResult with "OK" titled "Error"
end mouseUp

function cleanSQL pSQL
  replace "'" with "''" in pSQL  --replace single quote with double quote
  return pSQL
end cleanSQL
