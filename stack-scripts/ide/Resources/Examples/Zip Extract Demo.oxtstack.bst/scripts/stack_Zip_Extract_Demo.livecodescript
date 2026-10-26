script "stack_Zip_Extract_Demo"
-- Stack file: ide/Resources/Examples/Zip Extract Demo.oxtstack
-- Object: stack "Zip Extract Demo"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preopenstack
  -- Initialise the stack, putting empty into the files
  -- list and making sure the instruction field is visible
  set the text of field "Files" of card "Main" of me to empty
  set the blendLevel of field "Label" of card "Main" of me to 0
end preopenstack

function archiveReturnContents pArchive
  local tResult, tItems
  if there is no file pArchive then return empty
  
  -- We need to open the archive first before
  -- we do anything. The archive only needs to be opened
  -- for reading, as we are not going to change it.
  revZipOpenArchive pArchive, "read"
  put the result into tResult
  
  -- Check the archive has opened correctly
  if tResult is not empty then
    answer "Error opening archive. The zip library answered: " & tResult
    return empty
  end if
   
  put revZipEnumerateItems(pArchive) into tItems
  return tItems
  
end archiveReturnContents


-- Given an absolute folder path, returns the name of the folder
function nameFolder pPath
  set the itemDelimiter to slash
  return item -1 of pPath
end nameFolder

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
