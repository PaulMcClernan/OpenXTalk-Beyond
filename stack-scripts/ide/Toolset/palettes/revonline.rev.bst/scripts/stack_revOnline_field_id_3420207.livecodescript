script "stack_revOnline_field_id_3420207"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > group "edit stack" (id 3420214) > field "Yes" (id 3420207)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   deleteStack
end mouseUp

on mousemove
   set the textcolor of me to rvoHiliteColor()
   set the icon of button "yes" of the owner of me to 205418
end mousemove

on mouseleave
   set the textcolor of me to empty
   set the icon of button "yes" of the owner of me to 205419
end mouseleave
