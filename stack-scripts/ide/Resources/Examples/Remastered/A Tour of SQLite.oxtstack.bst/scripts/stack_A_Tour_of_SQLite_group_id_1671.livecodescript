script "stack_A_Tour_of_SQLite_group_id_1671"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite" > card "Binary Data" (id 1043) > group "Reset Icon2" (id 1671)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the text of image "Icon2" to empty  --reset
   showResult "info", "Icon2 is empty again."  --(added)
end mouseUp
