script "stack_Zip_Archives_group_id_1209"
-- Stack file: ide/Resources/Examples/Remastered/Zip Archives.oxtstack
-- Object: stack "Zip Archives" > card "Look Inside" (id 1032) > group "Clear" (id 1209)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   -- Clear the file list and show the instruction label
   put empty into field "Files"
   labelShow
   -- (remaster) and forget the archive
   archiveForget
   statusShow "tip", "Select the items to take out, or none to take them all."
end mouseUp
