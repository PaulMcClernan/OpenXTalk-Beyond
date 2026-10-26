script "stack_revImageLibrary_button_id_1126"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary" > card "Images" (id 1002) > group "Buttons" (id 1165) > button "Insert Reference into Stack" (id 1126)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if revIDEStackIsIDEStack(the topStack) then
      answer warning "Please open a stack first"
      exit mouseUp
   end if
   local tID
   put word -1 of fld "image ID" into tID
   lock screen
   set the defaultStack to the topStack
   reset the templateButton
   set the icon of the templateButton to tID
   set the showName of the templateButton to false
   set the showBorder of the templateButton to false
   set the traversalOn of the templateButton to false
   set the loc of the templateButton to the loc of this cd
   set the autoHilite of the templateButton to false
   set the opaque of the templateButton to false
   create button
   reset the templateButton
   set the width of the last button to the formattedWidth of the last button
   set the height of the last button to the formattedHeight of the last button
   select last btn
   unlock screen
end mouseUp
