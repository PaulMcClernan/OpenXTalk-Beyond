script "stack_revImageLibrary_button_id_1155"
-- Stack file: ide/Toolset/palettes/revimagelibrary.rev
-- Object: stack "revImageLibrary" > card "Objects" (id 1150) > group "Buttons" (id 1167) > button "Insert Into Stack" (id 1155)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if revIDEStackIsIDEStack(the topStack) then
      answer warning "Please open a stack first"
      exit mouseUp
   end if
   local tCardName, tStackName
   lock screen
   put line (the hilitedLines of fld "objects list") of fld "objects list" into tCardName
   put the cStackName of fld "objects list" into tStackName
   copy control 1 of cd tCardName of stack tStackName to the topStack
   set the defaultStack to the topStack
   if word 1 of the name of control 1 of cd tCardName of stack tStackName is "group" then 
      select last group
      if the right of last group > the right of this cd or the bottom of last group > the bottom of this cd then
         set the loc of last group to the loc of this cd
      end if
   else 
      select last control of the topStack
      if the right of last control > the right of this cd or the bottom of last control > the bottom of this cd then
         set the loc of last control to the loc of this cd
      end if
   end if
   unlock screen
end mouseUp
