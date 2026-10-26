script "stack_A_Tour_of_SQLite_group_id_1560"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Reports" (id 1040) > group "Outer Join 1" (id 1560)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tSQL, tList
   if gConID = empty then
      showResult "error", "Sorry, please connect to the database first."
      exit to top
   end if
   --This will return a list of all users and the apps purchased (if any).
   --SQLite has long had no right outer join, but a left outer join, the tables swapped, does what one would.
   put "SELECT users.name, apps.appName FROM users LEFT JOIN apps ON users.userID=apps.appUserID" into tSQL
   put revDataFromQuery(,,gConID,tSQL) into tList
   if "revdberr" is in the result then
      showResult "error", the result
      exit mouseUp
   end if
   set the itemDelimiter to tab  --(the columns are tab-delimited)
   sort lines of tList by word 1 of item 1 of each  --first name a-z
   sort lines of tList by word -1 of item 1 of each  --last name a-z
   put tSQL into field "ReportSQL"  --the SQL, and the records returned
   put tList into field "Report"
   showResult "ok", "All users and the apps purchased (if any)." & return & "Records returned:" && the number of lines of tList
end mouseUp
