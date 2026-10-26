script "stack_SQLite_Tour_button_id_1242"
-- Stack file: ide/Documentation/linked_files/SQLite Tour.livecode
-- Object: stack "SQLite Tour" > card "Reports" (id 1110) > button "Inner Join 3" (id 1242)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tSQL, tList
   if gConID = empty then
      answer "Sorry, please connect to the database first." with "OK" titled "Error"
      exit to top
   end if
   answer information "This will return a list of all the people who purchased AppRed." with "Cancel" or "OK" titled "Inner Join 3"
   if it = "Cancel" then exit to top
   put "SELECT users.Name, apps.appName FROM users,apps WHERE users.userID=apps.appUserID AND apps.appName='AppRed'" into tSQL
   put revDataFromQuery(,,gConID,tSQL) into tList
   if "revdberr" is in the result then
      answer warning the result with "OK" titled "Error"
      exit mouseUp
   end if
   replace tab with comma in tList  --for answer dialog
   sort lines of tList by word 1 of item 1 of each  --first name a-z
   sort lines of tList by word -1 of item 1 of each  --last name a-z
   answer information "Records returned:" &cr& tList with "OK" titled "Inner Join 3"
end mouseUp
