script "stack_Zip_Build_Demo"
-- Stack file: ide/Resources/Examples/Zip Build Demo.oxtstack
-- Object: stack "Zip Build Demo"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preopenstack
  -- Initialise the stack, putting empty into the files
  -- list and making sure the instruction field is visible
  set the text of field "Files" of card "Main" of me to empty
  set the blendLevel of field "Label" of card "Main" of me to 0
end preopenstack

on archiveCreate pArchive, pFilelist
  -- It is useful to keep track of the contents of the result
  -- global property when using external library commands
  local tResult
  
  -- Open the archive for write, this will fail if the
  -- archive already exists
  revZipOpenArchive pArchive, "write"
  put the result into tResult
  
  if tResult is not empty then
    -- The archive cannot be created.
    answer "Couldn't create archive, try another name"
    exit archiveCreate
  end if
  
  -- Check that the list of files to include is not empty
  if pFilelist is empty then
    answer "No files choosen!"
    exit archiveCreate
  end if
  
  -- Loop through the files and add them to the archive.
  -- Note that the name of each file in the archive is the 
  -- the last part of the file's name. This is returned by
  -- the nameFile() function, further down this script
  repeat for each line tFile in pFilelist
    revZipAddItemWithFile pArchive, nameFile(tFile), tFile
  end repeat
  
  -- Now close the archive. This will write the zip file
  -- to disk.
  revZipCloseArchive pArchive
  put the result into tResult
  
  -- As a lot of the work is done on closing the archive,
  -- it is worth checking the result at this stage to make
  -- sure no errors have ocurred.
  if tResult is not empty then
    answer "There was an error writing the archive, the zip library returned: " & tResult
    exit archiveCreate
  end if
  
end archiveCreate

function filesList
  local tFiles, tFormattedFiles
  
  -- Get the list of files that the user has dragged onto the field
  put the text of field "Files" of card "Main" of me into tFiles
  
  -- We are going to format the list of files, by going through them
  -- one by one and putting all the good ones into a new variable.
  -- In this case, all the lines that are files and exist are kept,
  -- folders and anything else are discarded.
  repeat for each line tLine in tFiles
    if there is a folder tLine then next repeat
    if there is a file tLine then put tLine & return after tFormattedFiles
  end repeat
  
  -- Remove the trailing return character
  delete the last char of tFormattedFiles
  
  -- Return the formatted list of files
  return tFormattedFiles
end filesList

-- Given an absoute file path, returns the name of the file
function nameFile pPath
  set the itemDelimiter to slash
  return item -1 of pPath
end nameFile

-- Shows the instruction label with a simple visual effect.
-- This could easily be changed to use one of Revolution's
-- build in visual effects, including quicktime or a MacOS X
-- core image effect.
on labelShow
  if the blendLevel of field "Label" of card "Main" of me is 0 then
    exit labelShow
  end if
  repeat with x=100 down to 0 step -2
    set the blendLevel of field "Label" of card "Main" of me to x
  end repeat
end labelShow

-- Hides the instruction label.
on labelHide
  if the blendLevel of field "Label" of card "Main" of me is 100 then
    exit labelHide
  end if
  repeat with x=0 to 100 step 2
    set the blendLevel of field "Label" of card "Main" of me to x
  end repeat
end labelHide
