script "stack_revOnline_field_id_3613678"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "edit controls" (id 3610310) > field "update" (id 3613678)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   updateStack
end mouseUp

on mousemove
   set the textcolor of me to rvoHiliteColor()
   set the icon of button "update" of the owner of me to 205424
end mousemove

on mouseleave
   set the textcolor of me to empty
   set the icon of button "update" of the owner of me to 205425
end mouseleave
