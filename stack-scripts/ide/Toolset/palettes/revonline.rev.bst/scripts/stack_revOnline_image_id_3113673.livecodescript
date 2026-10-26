script "stack_revOnline_image_id_3113673"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > group "image importer" (id 3107893) > image "user image thumbnail" (id 3113673)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   local tUserEmail
   put the cAuthor of the owner of me into tUserEmail
   updateView "list", "user", tUserEmail
end mousedown
   
   
