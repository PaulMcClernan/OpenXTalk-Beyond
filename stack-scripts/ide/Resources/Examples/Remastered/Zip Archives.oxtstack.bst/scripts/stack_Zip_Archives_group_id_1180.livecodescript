script "stack_Zip_Archives_group_id_1180"
-- Stack file: ide/Resources/Examples/Remastered/Zip Archives.oxtstack
-- Object: stack "Zip Archives" > card "Make an Archive" (id 1031) > group "Create" (id 1180)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   -- This will hold the path of the archive to create
   local tArchive

   -- (remaster) say so, and stop, if the zip library is not loaded here
   if not zipLoaded() then
      statusShow "problem", "The zip library, revZip, is not loaded here, so this card cannot make an archive."
      exit mouseUp
   end if

   -- Find out where the user would like to save their archive
   -- (remaster: with a name to start from)
   ask file "Please choose the name of the archive" with "Archive.zip"
   put it into tArchive

   -- Only continue if they have chosen a name
   if tArchive is empty then exit mouseUp

   -- (remaster) a name that does not end in .zip gets it
   if char -4 to -1 of tArchive is not ".zip" then put ".zip" after tArchive

   -- Create the archive (see the card's script, which was the stack script)
   -- filesList is a function there that returns a
   -- list of the all the files in the files list that can
   -- be added to the archive.
   archiveCreate tArchive, filesList()

end mouseUp
