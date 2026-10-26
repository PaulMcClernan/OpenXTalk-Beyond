script "stack_SQLite_Books_field_id_1136"
-- Stack file: ide/Resources/Examples/Remastered/SQLite Books.oxtstack
-- Object: stack "SQLite Books" > card "Library" (id 1031) > field "Search Term" (id 1136)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on returnInField
   put dbSearch(line 1 of me) into msg  --message box
   put dbSearch(line 1 of me) into fld "Display"  --added: and the Display field, which SQLite To DGTable copies
end returnInField
