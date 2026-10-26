script "stack_revOnline_field_id_3021069"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > group "template new 2" (id 3021066) > field "author" (id 3021069)
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
