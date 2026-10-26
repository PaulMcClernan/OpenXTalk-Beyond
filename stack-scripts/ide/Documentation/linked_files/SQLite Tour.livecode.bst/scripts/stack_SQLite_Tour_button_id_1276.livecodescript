script "stack_SQLite_Tour_button_id_1276"
-- Stack file: ide/Documentation/linked_files/SQLite Tour.livecode
-- Object: stack "SQLite Tour" > card "Understanding Schema" (id 1264) > button "Show SQLite_Master Schema" (id 1276)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tSQL, tList
   answer information "This will return a list of the SQL used to create all tables in the current database." with "Cancel" or "OK" titled "Master Schema"
   put "SELECT sql FROM sqlite_master" into tSQL
   put revDataFromQuery(,,gConID,tSQL) into tList
   if "revdberr" is in the result then 
      answer warning the result with "OK" titled "Error"
      exit to top
   end if
   replace tab with comma in tList  --for answer dialog
   answer information "Records returned:" &cr& tList with "OK" titled "Master Schema"
end mouseUp
