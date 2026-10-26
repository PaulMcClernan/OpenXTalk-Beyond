script "stack_revOnline_field_id_1702872"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > field "AddTag" (id 1702872)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   tagContent
end mouseUp

on mousemove
   set the textStyle of me to "underline"
   set the icon of button "tag" of the owner of me to 205424
end mousemove

on mouseleave
   --set the textcolor of me to rvoHiliteColor()
   set the textStyle of me to empty
   set the icon of button "tag" of the owner of me to 205425
end mouseleave
