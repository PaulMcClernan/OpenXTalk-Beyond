script "stack_SQLite_Tour_button_id_1178"
-- Stack file: ide/Resources/Examples/SQLite Tour.oxtstack
-- Object: stack "SQLite Tour" > card "View And Delete Data" (id 1153) > button "Refresh Table" (id 1178)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  global gConID
  local tSQL, tList
  if gConID = empty then
      answer "Sorry, please connect to the database first." with "OK" titled "Error"
      exit to top
   end if
  put "SELECT * FROM users" into tSQL  --select all
  put revDataFromQuery(,,gConID,tSQL) into tList
  if "revdberr" is not in the result then put tList into fld "Users"
  else answer warning the result with "OK" titled "Error"
end mouseUp
