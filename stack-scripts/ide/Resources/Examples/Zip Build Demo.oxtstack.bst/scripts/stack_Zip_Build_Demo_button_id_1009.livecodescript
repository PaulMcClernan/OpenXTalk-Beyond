script "stack_Zip_Build_Demo_button_id_1009"
-- Stack file: ide/Resources/Examples/Zip Build Demo.oxtstack
-- Object: stack "Zip Build Demo" > card "Main" (id 1002) > button "Create" (id 1009)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  -- This will hold the path of the archive to create
  local tArchive
  
  -- Find out where the user would like to save their archive
  ask file "Please choose the name of the archive"
  put it into tArchive
  
  -- Only continue if they have chosen a name
  if tArchive is empty then exit mouseUp
  
  -- Create the archive (see stack script)
  -- filesList is a stack script function that returns a 
  -- list of the all the files in the files list that can
  -- be added to the archive.
  archiveCreate tArchive, filesList()
  
end mouseUp
