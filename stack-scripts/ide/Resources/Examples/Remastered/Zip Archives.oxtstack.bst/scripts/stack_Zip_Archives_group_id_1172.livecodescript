script "stack_Zip_Archives_group_id_1172"
-- Stack file: ide/Resources/Examples/Remastered/Zip Archives.oxtstack
-- Object: stack "Zip Archives" > card "Make an Archive" (id 1031) > group "Add" (id 1172)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   -- (remaster) Dropping files does not work everywhere (in a browser
   -- tab, for one), so this button asks for them instead
   local tFiles
   answer files "Choose the files to add to the archive"
   put it into tFiles
   if tFiles is empty then exit mouseUp
   labelHide
   filesAdd tFiles
end mouseUp
