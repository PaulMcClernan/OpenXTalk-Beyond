script "stack_A_Tour_of_SQLite_group_id_1396"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Create Tables" (id 1035) > group "Create Apps" (id 1396)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tSQL
   if gConID is empty then
      showResult "error", "Sorry, the database is not connected. Please connect to the database first."
      exit mouseUp
   end if
   put "CREATE TABLE apps(appID integer primary key,appName text,appRegCode text,appUserID integer)" into tSQL
   revExecuteSQL gConID,tSQL
   if the result is an integer then showResult "ok", "The table Apps was added to the database."
   else showResult "error", the result  --(the original answered tResult, a variable it never set)
end mouseUp
