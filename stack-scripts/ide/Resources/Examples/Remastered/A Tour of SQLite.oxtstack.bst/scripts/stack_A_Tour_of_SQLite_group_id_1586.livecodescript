script "stack_A_Tour_of_SQLite_group_id_1586"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "The Schema" (id 1041) > group "Show Schema" (id 1586)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--(the original's "Show SQLite_Master Schema": the table is sqlite_master)
on mouseUp
   global gConID
   local tSQL, tList
   if gConID = empty then  --(added, as the other buttons do)
      showResult "error", "Sorry, please connect to the database first."
      exit to top
   end if
   --This will return a list of the SQL used to create all tables in the current database.
   put "SELECT sql FROM sqlite_master" into tSQL
   put revDataFromQuery(,,gConID,tSQL) into tList
   if "revdberr" is in the result then
      showResult "error", the result
      exit to top
   end if
   put tList into field "Schema"  --(the original answered with it)
   showResult "ok", "Records returned:" && the number of lines of tList
end mouseUp
