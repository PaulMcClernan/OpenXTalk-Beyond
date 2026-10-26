script "stack_SQLite_Book_Library_field_id_1007"
-- Stack file: ide/Resources/Examples/SQLite Book Library.oxtstack
-- Object: stack "SQLite Book Library" > card (id 1002) > field "Search Term" (id 1007)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on returnInField
   put dbSearch(line 1 of me) into msg  --message box
end returnInField
