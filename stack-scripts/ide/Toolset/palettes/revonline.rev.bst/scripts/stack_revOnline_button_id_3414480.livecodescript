script "stack_revOnline_button_id_3414480"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "user" (id 31884) > group "edit profile" (id 3414548) > button "cancel" (id 3414480)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   hideEditControls
   discardChanges
end mouseUp

on mousemove
   set the textcolor of field "cancel" of the owner of me to rvoHiliteColor()
end mousemove

on mouseleave
   set the textcolor of field "cancel" of the owner of me to empty
end mouseleave
