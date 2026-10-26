script "stack_SQLite_Tour_button_id_1245"
-- Stack file: ide/Resources/Examples/SQLite Tour.oxtstack
-- Object: stack "SQLite Tour" > card "Reports" (id 1110) > button "Outer Join 2" (id 1245)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tSQL, tList
   if gConID = empty then
      answer "Sorry, please connect to the database first." with "OK" titled "Error"
      exit to top
   end if
   answer information "This will return a list of all users and the number of apps they purchased (if any)." with "Cancel" or "OK" titled "Outer Join 2"
   if it = "Cancel" then exit to top
   put "SELECT users.name, COUNT(apps.appID) FROM users LEFT JOIN apps ON users.userID=apps.appUserID GROUP BY name ORDER BY name" into tSQL
   put revDataFromQuery(,,gConID,tSQL) into tList
   if "revdberr" is in the result then
      answer warning the result with "OK" titled "Error"
      exit mouseUp
   end if
   replace tab with comma in tList  --for answer dialog
   sort lines of tList by word 1 of item 1 of each  --first name a-z
   sort lines of tList by word -1 of item 1 of each  --last name a-z
   sort lines of tList descending numeric by item 2 of each  --integer
   answer information "Records returned:" &cr& tList with "OK" titled "Outer Join 2"
end mouseUp
