script "stack_revOnline_button_id_3614614"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "edit controls" (id 3610310) > button "no" (id 3614614)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   hideAll
   showEditControls
end mouseUp

on mousemove
   set the textcolor of field "no" of the owner of me to rvoHiliteColor()
end mousemove

on mouseleave
   set the textcolor of field "no" of the owner of me to empty
end mouseleave
