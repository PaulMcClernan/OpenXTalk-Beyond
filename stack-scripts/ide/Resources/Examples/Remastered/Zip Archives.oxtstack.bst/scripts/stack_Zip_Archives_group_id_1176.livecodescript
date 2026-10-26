script "stack_Zip_Archives_group_id_1176"
-- Stack file: ide/Resources/Examples/Remastered/Zip Archives.oxtstack
-- Object: stack "Zip Archives" > card "Make an Archive" (id 1031) > group "Clear" (id 1176)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   -- Clear the files list and show the instruction label
   put empty into field "Files"
   labelShow
   -- (remaster) and the count, and what the card says
   filesSummary
   statusShow "tip", "Add the files you want to pack, then make one zip of them all."
end mouseUp
