script "stack_RecentStacksAsGallery_button_id_6259"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > substack "RecentStacksAsGallery" > card (id 1002) > button "scriptTemplate" (id 6259)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   put word 2 of the clickCharChunk into tClickedChar
   if tClickedChar is "" then exit mousedown
   put the imageSource of char tClickedChar of me into tImage
   if there is an image tImage then
      put the absStack of image tImage into myStackToOpen
      if there is a stack myStackToOpen then
         -- we have the stack
         open stack myStackToOpen
         send generateThumbOfStack to stack "revIDElibrary"
      else
         -- stack can't be found!
         Answer "can't find stack:" && myStackToOpen
      end if
   end if
end mousedown

