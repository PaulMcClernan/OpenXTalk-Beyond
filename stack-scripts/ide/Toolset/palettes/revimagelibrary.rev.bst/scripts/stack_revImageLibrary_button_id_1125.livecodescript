script "stack_revImageLibrary_button_id_1125"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary" > card "Images" (id 1002) > group "Buttons" (id 1165) > button "Insert Image into Stack" (id 1125)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
   if revIDEStackIsIDEStack(the topStack) then
      answer warning "Please open a stack first"
      exit mouseUp
   end if
   local tWhich, tStackname, tImageID
   put the label of btn "library chooser" into tWhich
   put revLibraryStackName(tWhich) into tStackName
   put word -1 of fld "image id" into tImageID
   set the defaultStack to tStackName
   repeat with c = 1 to the number of cds
      repeat with i = 1 to the number of images in cd c
         if the ID of image i of cd c is tImageID then
            lock screen
            copy image i of cd c to the topStack
            set the loc of last image of the topStack to the loc of this cd of the topStack
            select last image of the topStack
            unlock screen
            exit mouseup
         end if
      end repeat
   end repeat
end mouseup
