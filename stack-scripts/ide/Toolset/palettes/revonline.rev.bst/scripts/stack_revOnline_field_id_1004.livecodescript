script "stack_revOnline_field_id_1004"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "search filter" (id 1007) > field "types" (id 1004)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tLine
   put word 2 of the mouseLine into tLine
   if the mousetext is not empty then
      set the cSelectedType of the long owner of me to line tLine of the text of me
   end if
end mouseUp

on mouseMove
   local tLine
   get the mouseLine
   put word 2 of it into tLine
   hiliteHoverText tLine, (the long id of me)
end mouseMove

on mouseLeave
   clearColors (the long id of me)
end mouseLeave
