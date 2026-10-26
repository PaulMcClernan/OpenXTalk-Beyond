script "stack_A_Tour_of_SQLite_group_id_1717"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "All Done" (id 1044) > group "Copy Reference" (id 1717)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the clipboardData["text"] to the text of field "Reference"  --the reference, to paste into a script
   answer "The SQLite reference is on the clipboard: paste it into a script." with "OK" titled "A Tour of SQLite"
end mouseUp
