script "stack_SQLite_Tour_button_id_1231"
-- Stack file: ide/Resources/Examples/SQLite Tour.oxtstack
-- Object: stack "SQLite Tour" > card "Edit Databases" (id 1206) > button "Refresh Apps" (id 1231)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tSQL, tList
   if gConID = empty then
      answer "Sorry, please connect to the database first." with "OK" titled "Error"
      exit to top
   end if
   put "SELECT * FROM apps" into tSQL
   put revDataFromQuery(,,gConID,tSQL) into tList
   if "revdberr" is not in the result then put tList into fld "apps"
   else answer warning the result with "OK" titled "Error"
end mouseUp
