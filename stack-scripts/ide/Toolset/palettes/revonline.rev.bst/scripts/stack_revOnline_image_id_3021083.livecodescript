script "stack_revOnline_image_id_3021083"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > group "template new 2" (id 3021066) > image "thumbnail" (id 3021083)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tStackId
   put the cStackId of the owner of me into tStackId
   --updateView "list","stack",tStackId
   # Need to send in 0 milliseconds because potentially this call will delete this group
   local tMode = "list"
   local tView = "stack"
   send "updateView tMode, tView, tStackId" to stack "revonline" in 0 milliseconds
end mouseUp
