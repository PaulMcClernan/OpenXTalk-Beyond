script "stack_Zip_Archives_field_id_1171"
-- Stack file: ide/Resources/Examples/Remastered/Zip Archives.oxtstack
-- Object: stack "Zip Archives" > card "Make an Archive" (id 1031) > field "Files" (id 1171)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on dragEnter
   -- This will hold the list of files/folders the user
   -- has dragged onto the field
   local tData
   local tLine -- (remaster) declared, for strict compilation

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
   -- (remaster: filesAdd, in the card's script, does it now, and puts
   -- each file's name and size in its line)
   filesAdd tData

end dragDrop

on dragLeave
   -- This message is sent if the user decides not to drop the object
   -- This handler just makes the instruction label reappear if appropriate
   if the text of me is empty then labelShow
end dragLeave
