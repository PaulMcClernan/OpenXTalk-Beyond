script "stack_revOnline_field_id_157901"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > group "template original" (id 157898) > field "author" (id 157901)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tUserId
   put the cUserId of the owner of me into tUserId
   lock screen
   put the cUserDisplayName of the owner of me into field "user filter" of group "search filter" of stack "revonline"
   --put the text of me into field "user filter" of group "search filter" of this stack
   set the cSelectedUser of group "search filter" of this stack to tUserId
   unlock screen
   updateView "list","user",tUserId
   --   updateSearchList 0, tUserId
end mouseUp

on mouseEnter
   set the textStyle of me to "underline"
end mouseEnter

on mouseMove
   set the textStyle of me to "underline"
end mouseMove

on mouseLeave
   set the textStyle of me to empty
end mouseLeave
