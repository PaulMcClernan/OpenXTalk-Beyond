script "stack_revOnline_field_id_2099027"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > field "type" (id 2099027)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cSelectedType of group "search filter" of this stack to the text of me
end mouseUp

on mousemove
   --set the textcolor of me to rvoHiliteColor()
   set the textStyle of me to "underline"
end mousemove

on mouseleave
   set the textcolor of me to rvoHiliteColor()
   set the textStyle of me to empty
end mouseleave
