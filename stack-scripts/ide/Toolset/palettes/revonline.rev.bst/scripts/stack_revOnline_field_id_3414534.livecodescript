script "stack_revOnline_field_id_3414534"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "user" (id 31884) > group "edit profile" (id 3414548) > field "Edit profile" (id 3414534)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   showEditControls
   editProfile
end mouseUp

on mouseEnter
   --set the textStyle of me to "underline"
   set the textColor of me to rvoHiliteColor()
end mouseEnter

on mouseMove
   --set the textStyle of me to "underline"
   set the textColor of me to rvoHiliteColor()
end mouseMove

on mouseLeave
   --set the textStyle of me to empty
   set the textColor of me to empty
end mouseLeave
