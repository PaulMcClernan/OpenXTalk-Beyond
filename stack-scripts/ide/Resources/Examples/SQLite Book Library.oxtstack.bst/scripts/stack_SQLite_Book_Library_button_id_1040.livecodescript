script "stack_SQLite_Book_Library_button_id_1040"
-- Stack file: ide/Resources/Examples/SQLite Book Library.oxtstack
-- Object: stack "SQLite Book Library" > card (id 1002) > button "SQLite To DGTable" (id 1040)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  --in button script, populate dg table
   local tData, tHeaders
   put field "Display" into tData  --tab delimited line list
   put "ID" &cr& "Author" &cr& "Title" into tHeaders
   set the dgProp["columns"] of group "DataGrid 1" to tHeaders  --populate headers first, line list
   replace cr with tab in tHeaders  --tab delimited
  set the dgText["true"] of group "DataGrid 1" to tHeaders &cr& tData  --headers in line 1
end mouseUp
