script "stack_revOnline_field_id_3610309"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "edit controls" (id 3610310) > field "edit" (id 3610309)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   showEditControls
end mouseUp

on mouseEnter
   set the textColor of me to rvoHiliteColor()
end mouseEnter

on mouseMove
   set the textColor of me to rvoHiliteColor()
end mouseMove

on mouseLeave
   set the textColor of me to empty
end mouseLeave
