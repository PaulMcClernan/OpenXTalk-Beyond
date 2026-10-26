script "stack_Quick_Dictionary_field_id_1006"
-- Stack file: ide/Plugins/Quick Dictionary.livecode
-- Object: stack "Quick Dictionary" > card (id 1002) > field "Cerca2" (id 1006)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--put revDatabaseTableNames(tID)  --apis, dictionary_data
--put revDatabaseColumnNames(tID, dictionary_data)  --apis_id, entry_data, entry_name, entry_type, library_name
--put revDatabaseColumnNamed(tRecordSetID, library_name)  --script, builder, data grid
--stock dictionary library_name = livecode script, livecode builder, Data Grid

local tID, temp, tSQL, tRecords, tRiga

on textChanged
   put the text of me into temp
   if the number of chars in temp <3 then
      set the dgText of grp "Risultati" to ""
      exit textChanged
   end if
   if not (the pendingmessages contains "SearchDB") then
      SearchDB
   end if
end textChanged

on SearchDB
   lock screen
   put the cConnID of this card into tID
   put the text of me into temp
   put "SELECT entry_name, entry_type FROM dictionary_data WHERE entry_name LIKE '%" & temp & "%' " into tSQL
   --filter output by library
   if the hilite of btn "Script" then put " AND library_name = 'Script' " after tSQL
   else if the hilite of btn "Datagrid" then put " AND library_name = 'Data Grid' " after tSQL
   else if the hilite of btn "Builder" then put " AND library_name = 'Builder' " after tSQL
   --filter output by type
   put the number of buttons of grp "filtro" into temp
   put "AND entry_type IN ( " after tSQL
   repeat with i=1 to temp
      if the hilite of  btn i of grp "filtro" then put " '" & lower( the short name of btn i of grp "filtro") & "'," after tSQL
   end repeat
   delete last char of tSQL
   put ")" after tSQL
   put revDataFromQuery(tab,cr,tID,tSQL) into tRecords
   put urlDecode(tRecords) into tRecords 
   set the itemDel to tab   
   --version 1
   repeat  with i=1 to the number of lines of tRecords
      put item 1 of line i of tRecords into tRiga
      put correctNames(tRiga) into item 1 of line i of tRecords
   end repeat
   set the dgText of grp "Risultati" to tRecords
   unlock screen
end SearchDB

function correctNames tString
   replace "$_" with "§" in tString
   replace "_" with space in tString
   replace "§" with "$_"   in tString
   replace "&lt;" with "<" in tString
   replace "&gt;" with ">" in tString
   return  tString
end correctNames

on returnInField  --trap returnKey
  SearchDB
end returnInField
