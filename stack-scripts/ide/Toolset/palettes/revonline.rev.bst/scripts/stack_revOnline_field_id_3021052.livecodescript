script "stack_revOnline_field_id_3021052"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > group "template new 1" (id 3021051) > field "title" (id 3021052)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tStackId
   put the cStackId of the owner of me into tStackId
   --put tStackId
   updateView "list","stack",tStackId
end mouseUp



on mouseEnter
   if the mousetext is not empty then
      set the textStyle of me to "underline, bold"
   end if
end mouseEnter

on mouseMove
   if the mousetext is not empty then
      set the textStyle of me to "underline, bold"
   end if
end mouseMove

on mouseLeave
   set the textStyle of me to "bold"
end mouseLeave
