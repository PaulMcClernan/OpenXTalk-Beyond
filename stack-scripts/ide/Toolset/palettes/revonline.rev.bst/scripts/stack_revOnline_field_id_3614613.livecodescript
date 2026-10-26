script "stack_revOnline_field_id_3614613"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "edit controls" (id 3610310) > field "no" (id 3614613)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   hideAll
   showEditControls
end mouseUp

on mousemove
   set the textcolor of me to rvoHiliteColor()
   set the icon of button "no" of the owner of me to 205421
end mousemove

on mouseleave
   set the textcolor of me to empty
   set the icon of button "no" of the owner of me to 205422
end mouseleave
