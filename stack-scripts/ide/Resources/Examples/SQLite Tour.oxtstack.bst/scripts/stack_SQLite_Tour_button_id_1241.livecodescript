script "stack_SQLite_Tour_button_id_1241"
-- Stack file: ide/Resources/Examples/SQLite Tour.oxtstack
-- Object: stack "SQLite Tour" > card "Reports" (id 1110) > button "Inner Join 2" (id 1241)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tSQL, tList
   if gConID = empty then
      answer "Sorry, please connect to the database first." with "OK" titled "Error"
      exit to top
   end if
   answer information "This will return a list of the apps purchased by John Smith." with "Cancel" or "OK" titled "Inner Join 2"
   if it = "Cancel" then exit to top
   put "SELECT users.Name, apps.appName FROM users,apps WHERE users.userID=apps.appUserID AND users.name='John Smith'" into tSQL
   put revDataFromQuery(,,gConID,tSQL) into tList
   if "revdberr" is in the result then
      answer warning the result with "OK" titled "Error"
      exit mouseUp
   end if
   replace tab with comma in tList  --for answer dialog
   sort lines of tList by item 2 of each  --apps a-z
   answer information "Records returned:" &cr& tList with "OK" titled "Inner Join 2"
end mouseUp
