script "stack_A_Tour_of_SQLite_group_id_1590"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "The Schema" (id 1041) > group "Delete Users" (id 1590)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--(the original's "Delete Users Table")
on mouseUp
   global gConID
   local tSQL
   if gConID = empty then
      showResult "error", "Sorry, please connect to the database first."
      exit to top
   end if
   put "DROP TABLE users" into tSQL
   revExecuteSQL gConID,tSQL
   if "revdberr" is in the result then
      showResult "error", the result
      exit mouseUp
   end if
   if the result is an integer then showResult "ok", "The Users table has been deleted."
   else showResult "error", the result
end mouseUp
