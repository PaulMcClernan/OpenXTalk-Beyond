script "stack_SQLite_Tour_button_id_1275"
-- Stack file: ide/Documentation/linked_files/SQLite Tour.livecode
-- Object: stack "SQLite Tour" > card "Delete And Add Columns" (id 1272) > button "Delete Columns" (id 1275)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tSQL, tList
   answer information "This will delete the columns 'email' and 'emailList' from table 'users' and " & \
         "rename column 'name' to 'fullname'." with "Cancel" or "OK" titled "Delete Columns"
   if it = "Cancel" then exit to top
   --
   put "BEGIN TRANSACTION;" into tSQL
   put "CREATE TEMPORARY TABLE users_temp(userID,name);" after tSQL
   put "INSERT INTO users_temp SELECT userID,name FROM users;" after tSQL
   put "DROP TABLE users;" after tSQL
   put "CREATE TABLE users(userID,fullname);" after tSQL
   put "INSERT INTO users SELECT userID,name FROM users_temp;" after tSQL
   put "DROP TABLE users_temp;" after tSQL
   put "COMMIT;" after tSQL
   revExecuteSQL gConID,tSQL
   if the result is not an integer then
      answer warning the result with "OK" titled "Error"
      exit to top
   end if
   --
   put "SELECT sql FROM sqlite_master" into tSQL  --new schema
   put revDataFromQuery(,,gConID,tSQL) into tList
   if "revdberr" is in the result then
      answer warning the result with "OK" titled "Error"
      exit to top
   end if
   replace tab with comma in tList  --for answer dialog
   answer information "New schema created:" &cr& tList with "OK" titled "Delete Columns"
   --
   put "SELECT * FROM users" into tSQL  --new table users
   put revDataFromQuery(,,gConID,tSQL) into tList
   if "revdberr" is in the result then
      answer warning the result with "OK" titled "Error"
      exit to top
   end if
   replace tab with comma in tList
   answer information "New table 'users':" &cr& tList with "OK" titled "Delete Columns"
end mouseUp
