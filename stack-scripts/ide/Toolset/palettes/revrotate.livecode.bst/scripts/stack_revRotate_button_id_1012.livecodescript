script "stack_revRotate_button_id_1012"
-- Stack file: ide/Toolset/palettes/revrotate.livecode
-- Object: stack "revRotate" > card (id 1002) > button "OK" (id 1012)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tRotate
   put fld "Rotate" into tRotate
   if the hilitedButtonName of grp "Direction" is "Right" then 
      put 360 - tRotate into tRotate
   end if
   set the cRotateImage of this stack to tRotate
   set the cRotateGraphic of this stack to tRotate
   close this stack
end mouseUp
