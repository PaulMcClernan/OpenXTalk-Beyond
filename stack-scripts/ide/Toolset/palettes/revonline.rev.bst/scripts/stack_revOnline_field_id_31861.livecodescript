script "stack_revOnline_field_id_31861"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > field "Author" (id 31861)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tUserEmail
   put the cAuthor of the owner of me into tUserEmail
   updateView "list", "user", tUserEmail
end mouseUp

on mousemove
   lock screen
   set the textStyle of me to empty
   if the mouseText is not empty then
      set the textStyle of me to "underline"
   end if
   unlock screen
end mousemove

on mouseleave
   --set the textcolor of me to rvoHiliteColor()
   set the textStyle of me to empty
end mouseleave
