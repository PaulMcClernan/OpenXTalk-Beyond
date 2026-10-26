script "stack_revOnline_field_id_3420212"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > group "edit stack" (id 3420214) > field "update" (id 3420212)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   showContentChooser "update"
end mouseUp

on mousemove
   set the textcolor of me to rvoHiliteColor()
   set the icon of button "update" of the owner of me to 205424
end mousemove

on mouseleave
   set the textcolor of me to empty
   set the icon of button "update" of the owner of me to 205425
end mouseleave
