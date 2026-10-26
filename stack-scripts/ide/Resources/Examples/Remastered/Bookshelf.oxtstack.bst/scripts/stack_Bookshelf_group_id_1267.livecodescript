script "stack_Bookshelf_group_id_1267"
-- Stack file: ide/Resources/Examples/Remastered/Bookshelf.oxtstack
-- Object: stack "Bookshelf" > card "Book Data" (id 1032) > group "Cancel" (id 1267)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   lock screen
   clearFields
   lockFields
   -- (remaster) and Save and Cancel are off, and
   -- no book is chosen in the list, as when the
   -- card opens; the typing stops
   set the enabled of group "Cancel" to false
   set the enabled of group "Save" to false
   buttonsLook
   set the hilitedLines of field "List" to empty
   focus on nothing
   unlock screen
end mouseUp
