script "stack_Zip_Archives_group_id_1205"
-- Stack file: ide/Resources/Examples/Remastered/Zip Archives.oxtstack
-- Object: stack "Zip Archives" > card "Look Inside" (id 1032) > group "Open" (id 1205)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   -- (remaster) Dropping a file does not work everywhere (in a browser
   -- tab, for one), so this button asks for an archive instead
   local tArchive
   if not zipLoaded() then
      statusShow "problem", "The zip library, revZip, is not loaded here, so this card cannot open an archive."
      exit mouseUp
   end if
   answer file "Choose a zip archive to look inside" with type "Zip archives|zip|"
   put it into tArchive
   if tArchive is empty then exit mouseUp
   labelHide
   archiveShow tArchive
end mouseUp
