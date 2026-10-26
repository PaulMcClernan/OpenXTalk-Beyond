script "stack_revOnline_field_id_4036403"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "search list" (id 1691) > group "Object 685" (id 4036400) > field "author" (id 4036403)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tUserId
   put the cUserId of the owner of me into tUserId
   lock screen
   put the cUserDisplayName of the owner of me into field "user filter" of group "search filter" of stack "revonline"
   set the cSelectedUser of group "search filter" of this stack to tUserId
   unlock screen
   --updateView "list","user",tUserId
   # Need to send in 0 milliseconds because potentially this call will delete this group
   local tMode = "list"
   local tView = "user"
   send "updateView tMode, tView, tUserId" to stack "revonline" in 0 milliseconds
end mouseUp

on mouseEnter
   if the text of me is not empty then
      set the textStyle of me to "underline"
   end if
end mouseEnter

on mouseMove
   if the text of me is not empty then
      set the textStyle of me to "underline"
   end if
end mouseMove

on mouseLeave
   set the textStyle of me to empty
end mouseLeave
