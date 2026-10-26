script "stack_revOnline_button_id_1647600"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "search filter" (id 1007) > button "remove user filter" (id 1647600)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cSelectedUser of the owner of me to empty  
end mouseUp

on mouseEnter
   set the textstyle of field "user filter" of the owner of me to "underline,bold"
end mouseEnter

on mouseLeave
   set the textstyle of field "user filter" of the owner of me to "bold"
end mouseLeave

on mouseMove
   set the textstyle of field "user filter" of the owner of me to "underline,bold"
end mouseMove
