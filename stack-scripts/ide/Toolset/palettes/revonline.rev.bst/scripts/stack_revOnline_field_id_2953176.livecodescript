script "stack_revOnline_field_id_2953176"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "user" (id 31884) > field "change password" (id 2953176)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   revOnlineShowChangePasswordDialog
end mouseUp

on mousemove
   --set the textcolor of me to rvoHiliteColor()
   set the textStyle of me to "underline"
end mousemove

on mouseleave
   set the textStyle of me to empty
   --set the textcolor of me to empty
end mouseleave
