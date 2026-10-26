script "stack_Zip_Build_Demo_field_id_1004"
-- Stack file: ide/Resources/Examples/Zip Build Demo.oxtstack
-- Object: stack "Zip Build Demo" > card "Main" (id 1002) > field "Files" (id 1004)
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
  
  -- Only allow files for simplicity. It would be
  -- easy to allow the user to drag folders on too.
  repeat for each line tLine in tData
    if there is a folder tLine then exit dragEnter
  end repeat
   
   -- At this stage, the drop is going to be accepted,
   -- so hide the instruction label and accept the drop.
  labelHide
  set the acceptDrop to true
  
end dragEnter

on dragDrop
  local tData
  
  -- Grab the list of the files that the user is dragging
  put the dragData["files"] into tData
  
  -- Put them into the field, making sure there is 
  -- one file per line and no empty lines
  if the text of me is empty then
    set the text of me to tData
  else
    set the text of me to the text of me & return & tData
  end if
  
end dragDrop

on dragLeave
  -- This message is sent if the user decides not to drop the object
  -- This handler just makes the instruction label reappear if appropriate
  if the text of me is empty then labelShow
end dragLeave
