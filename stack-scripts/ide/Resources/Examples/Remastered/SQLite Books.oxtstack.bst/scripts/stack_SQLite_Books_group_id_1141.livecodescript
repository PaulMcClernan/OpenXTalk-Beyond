script "stack_SQLite_Books_group_id_1141"
-- Stack file: ide/Resources/Examples/Remastered/SQLite Books.oxtstack
-- Object: stack "SQLite Books" > card "Library" (id 1031) > group "SQLite To DGTable" (id 1141)
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
