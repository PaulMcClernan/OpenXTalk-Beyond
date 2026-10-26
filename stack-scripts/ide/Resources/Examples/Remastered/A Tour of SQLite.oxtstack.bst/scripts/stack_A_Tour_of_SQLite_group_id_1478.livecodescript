script "stack_A_Tour_of_SQLite_group_id_1478"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Update Data" (id 1038) > group "Refresh Table" (id 1478)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   global gConID
   local tSQL, tList, tLine, tItem, tRowData
   if gConID = empty then
      showResult "error", "Sorry, please connect to the database first."
      exit to top
   end if
   put "SELECT * FROM users" into tSQL  --select all records
   put revDataFromQuery(,,gConID,tSQL) into tList
   if "revdberr" is in the result then
      showResult "error", the result
      exit mouseUp
   end if
   set the itemDelimiter to tab  --(the columns are tab-delimited: split at commas, a value with a comma in it became two)
   repeat for each line tLine in tList
      repeat for each item tItem in tLine
         put tItem & tab after tRowData
      end repeat
      delete last char of tRowData  --last tab
      put return after tRowData
   end repeat
   delete last char of tRowData  --last return
   put tRowData into fld "Users"  --display
   showResult "ok", "Records returned:" && the number of lines of tList & ". Click a cell to change it."  --(added)
end mouseUp
