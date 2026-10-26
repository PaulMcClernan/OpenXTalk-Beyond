script "stack_SQLite_Tour_button_id_1268"
-- Stack file: ide/Resources/Examples/SQLite Tour.oxtstack
-- Object: stack "SQLite Tour" > card "Delete Tables" (id 1112) > button "Delete Users Table" (id 1268)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tSQL
   if gConID = empty then
      answer "Sorry, please connect to the database first." with "OK" titled "Error"
      exit to top
   end if
   put "DROP TABLE users" into tSQL
   revExecuteSQL gConID,tSQL
   if "revdberr" is in the result then 
      answer warning the result with "OK" titled "Error"
      exit mouseUp
   end if
   if the result is an integer then answer information "The Users table has been deleted." with "OK" titled "Delete Users Table"
   else answer warning the result titled "Error"
end mouseUp
