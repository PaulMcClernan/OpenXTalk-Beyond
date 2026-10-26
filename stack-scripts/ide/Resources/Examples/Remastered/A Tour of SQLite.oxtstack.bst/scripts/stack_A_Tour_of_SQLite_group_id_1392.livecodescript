script "stack_A_Tour_of_SQLite_group_id_1392"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Create Tables" (id 1035) > group "Create Users" (id 1392)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tSQL
   if gConID is empty then
      showResult "error", "Sorry, the database is not connected. Please connect to the database first."
      exit mouseUp
   end if
   put "CREATE TABLE users(userID integer primary key,name text,email text,emailList boolean)" into tSQL
   revExecuteSQL gConID,tSQL
   if the result is an integer then showResult "ok", "The table Users was added to the database."
   else showResult "error", the result  --(the original answered tResult, a variable it never set)
end mouseUp
