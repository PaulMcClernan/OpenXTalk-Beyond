script "stack_SQLite_Tour_button_id_1368"
-- Stack file: ide/Documentation/linked_files/SQLite Tour.livecode
-- Object: stack "SQLite Tour" > card "Update Data" (id 1363) > button "Refresh Table" (id 1368)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tSQL, tList, tLine, tItem, tRowData
   if gConID = empty then
      answer "Sorry, please connect to the database first." with "OK" titled "Error"
      exit to top
   end if
   put "SELECT * FROM users" into tSQL  --select all records
   put revDataFromQuery(,,gConID,tSQL) into tList
   if "revdberr" is in the result then 
      answer warning the result with "OK" titled "Error"
      exit mouseUp
   end if
   repeat for each line tLine in tList
      repeat for each item tItem in tLine
         put tItem & tab after tRowData
      end repeat
      delete last char of tRowData  --last tab
      put return after tRowData
   end repeat
   delete last char of tRowData  --last return
   put tRowData into fld "Users"  --display 
end mouseUp

