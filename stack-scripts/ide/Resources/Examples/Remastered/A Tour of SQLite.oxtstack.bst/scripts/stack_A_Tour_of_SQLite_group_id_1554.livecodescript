script "stack_A_Tour_of_SQLite_group_id_1554"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Reports" (id 1040) > group "Inner Join 2" (id 1554)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tSQL, tList
   if gConID = empty then
      showResult "error", "Sorry, please connect to the database first."
      exit to top
   end if
   --This will return a list of the apps purchased by John Smith.
   put "SELECT users.Name, apps.appName FROM users,apps WHERE users.userID=apps.appUserID AND users.name='John Smith'" into tSQL
   put revDataFromQuery(,,gConID,tSQL) into tList
   if "revdberr" is in the result then
      showResult "error", the result
      exit mouseUp
   end if
   set the itemDelimiter to tab  --(the columns are tab-delimited)
   sort lines of tList by item 2 of each  --apps a-z
   put tSQL into field "ReportSQL"  --the SQL, and the records returned
   put tList into field "Report"
   showResult "ok", "The apps purchased by John Smith." & return & "Records returned:" && the number of lines of tList
end mouseUp
