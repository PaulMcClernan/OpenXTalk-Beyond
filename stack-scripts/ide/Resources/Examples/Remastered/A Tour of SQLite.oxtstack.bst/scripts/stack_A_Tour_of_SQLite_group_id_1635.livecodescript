script "stack_A_Tour_of_SQLite_group_id_1635"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Columns" (id 1042) > group "Add Columns" (id 1635)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tSQL, tList
   if gConID = empty then  --(added, as the other buttons do)
      showResult "error", "Sorry, please connect to the database first."
      exit to top
   end if
   answer information "This will add the columns 'city' and 'state' to table 'users'." with "Cancel" or "OK" titled "Add Columns"  --(the original had "and" for "or")
   if it = "Cancel" then exit to top
   --
   put "BEGIN TRANSACTION;" into tSQL
   put "CREATE TEMPORARY TABLE users_temp(userID,name,email,emailList);" after tSQL
   put "INSERT INTO users_temp SELECT userID,name,email,emailList FROM users;" after tSQL
   put "DROP TABLE users;" after tSQL
   put "CREATE TABLE users(userID integer primary key,name text,email text,emailList boolean,city text,state text);" after tSQL
   put "INSERT INTO users(userID,name,email,emailList) SELECT userID,name,email,emailList FROM users_temp;" after tSQL
   put "DROP TABLE users_temp;" after tSQL
   put "COMMIT;" after tSQL
   revExecuteSQL gConID,tSQL
   if the result is not an integer then
      showResult "error", the result
      revExecuteSQL gConID,"ROLLBACK"  --(added: undo what ran before the error, which left the transaction open)
      exit to top
   end if
   --
   put "SELECT sql FROM sqlite_master" into tSQL  --new schema
   put revDataFromQuery(,,gConID,tSQL) into tList
   if "revdberr" is in the result then
      showResult "error", the result
      exit to top
   end if
   put tList into field "Schema"  --(the original answered with it)
   --
   put "SELECT * FROM users" into tSQL  --new table users
   put revDataFromQuery(,,gConID,tSQL) into tList
   if "revdberr" is in the result then
      showResult "error", the result
      exit to top
   end if
   put tList into field "Users"  --(the original answered with it)
   showResult "ok", "New schema created, and the new table 'users': both are below."
end mouseUp
