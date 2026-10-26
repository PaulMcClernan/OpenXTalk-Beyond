script "stack_A_Tour_of_SQLite_group_id_1526"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Both Tables" (id 1039) > group "Refresh Users" (id 1526)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tSQL, tList
   if gConID = empty then
      showResult "error", "Sorry, please connect to the database first."
      exit to top
   end if
   put "SELECT * FROM users" into tSQL
   put revDataFromQuery(,,gConID,tSQL) into tList
   if "revdberr" is not in the result then
      put tList into fld "Users"
      showResult "ok", "Records returned from users:" && the number of lines of tList  --(added)
   else
      showResult "error", the result
   end if
end mouseUp
