script "stack_revOnline_field_id_3229400"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > group "tag template 2" (id 3229396) > field "Cancel" (id 3229400)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

constant kColor = "251,213,79"

on mousemove
   if the mousetext is not empty then
      set the textColor of me to kColor
   else
      set the textColor of me to "white"
   end if
end mousemove

on mouseleave
   set the textColor of me to "white"
end mouseleave
