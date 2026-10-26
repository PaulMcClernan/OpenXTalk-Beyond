script "stack_SQLite_Book_Library_button_id_1014"
-- Stack file: ide/Resources/Examples/SQLite Book Library.oxtstack
-- Object: stack "SQLite Book Library" > card (id 1002) > button "+/- Record" (id 1014)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tAuthor, tTitle
   ask "Add Record: enter Author,Title." &cr& "Delete Record: enter record's ID integer." with "1" titled "Add/Delete Record"
   if it = empty then exit to top
   if the number of items in it = "2" then
      put item 1 of it into tAuthor
      put word 1 to -1 of item 2 of it into tTitle  --remove char 1 space
      AddRecord tAuthor, tTitle
   else if it is an integer and it >= "1" then DeleteRecord it
end mouseUp
