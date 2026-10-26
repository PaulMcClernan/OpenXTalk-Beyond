script "stack_Zip_Archives_group_id_1213"
-- Stack file: ide/Resources/Examples/Remastered/Zip Archives.oxtstack
-- Object: stack "Zip Archives" > card "Look Inside" (id 1032) > group "Extract" (id 1213)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   -- (remaster) Takes the items selected in the list out of the archive,
   -- or all of them if none is selected, into a folder you choose. A
   -- browser cannot give a page a folder: there, the files download
   local tFolder
   if archiveShown() is empty then
      statusShow "tip", "Drop a zip on the list, or choose one, first."
      exit mouseUp
   end if
   if the platform is "HTML5" then
      put specialFolderPath("downloads") into tFolder
   else
      answer folder "Choose the folder to take the files out into"
      put it into tFolder
      if tFolder is empty then exit mouseUp
   end if
   archiveExtract archiveShown(), itemsChosen(), tFolder
end mouseUp
