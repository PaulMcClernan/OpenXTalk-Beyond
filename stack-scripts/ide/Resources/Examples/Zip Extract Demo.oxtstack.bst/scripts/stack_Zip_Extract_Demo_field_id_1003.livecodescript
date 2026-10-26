script "stack_Zip_Extract_Demo_field_id_1003"
-- Stack file: ide/Resources/Examples/Zip Extract Demo.oxtstack
-- Object: stack "Zip Extract Demo" > card "Main" (id 1002) > field "Files" (id 1003)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on dragEnter
  -- This will hold the list of files/folders the user 
  -- has dragged onto the field
  local tData
  
  -- Get the drag data we need, and exit straight 
  -- away if it is empty
  put the dragData["files"] into tData
  if tData is empty then exit dragEnter
  
  -- We can only accept one archive at a time.
  if the number of lines of tData > 1 then exit dragEnter
  
  -- The file has to be a zip archive, check its extension
  local tFilename
  put line 1 of tData into tFilename
  set the itemDelimiter to "."
  if item -1 of tFilename is not "zip" then exit dragEnter
  
  -- At this stage, the drop is going to be accepted,
  -- so hide the instruction label and accept the drop.
  labelHide
  set the acceptDrop to true
  
end dragEnter

on dragDrop
  local tFile
  put the dragData["files"] into tFile
  set the text of me to archiveReturnContents(tFile)
end dragDrop

on dragLeave
  -- This message is sent if the user decides not to drop the object
  -- This handler just makes the instruction label reappear if appropriate
  if the text of me is empty then labelShow
end dragLeave
