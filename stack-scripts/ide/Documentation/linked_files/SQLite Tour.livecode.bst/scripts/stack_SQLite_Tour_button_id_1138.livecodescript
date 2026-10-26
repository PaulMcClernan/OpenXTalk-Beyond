script "stack_SQLite_Tour_button_id_1138"
-- Stack file: ide/Documentation/linked_files/SQLite Tour.livecode
-- Object: stack "SQLite Tour" > card "Create Tables" (id 1102) > button "Create Table Users" (id 1138)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tSQL
   if gConID is empty then
      answer information "Sorry, the database is not connected. Please connect to the database first." with "OK" titled "Error"
      exit mouseUp
   end if
   put "CREATE TABLE users(userID integer primary key,name text,email text,emailList boolean)" into tSQL
   revExecuteSQL gConID,tSQL
   if the result is an integer then answer information "The table Users was added to the database." with "OK" titled "Create Table Users"
   else answer warning tResult with "OK" titled "Error"
end mouseUp
