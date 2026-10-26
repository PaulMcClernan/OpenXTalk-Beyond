script "stack_revOnline_field_id_146658"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "search filter" (id 1007) > field "user filter" (id 146658)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cSelectedUser of the owner of me to empty  
end mouseUp

on mouseEnter
   set the textstyle of me to "underline,bold"
   set the icon of button "remove user filter" of the owner of me to 205421
end mouseEnter

on mouseLeave
   set the textstyle of me to "bold"
   set the icon of button "remove user filter" of the owner of me to 205422
end mouseLeave

on mouseMove
   set the textstyle of me to "underline,bold"
   set the icon of button "remove user filter" of the owner of me to 205421
end mouseMove
