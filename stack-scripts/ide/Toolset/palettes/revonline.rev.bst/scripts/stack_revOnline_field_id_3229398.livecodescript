script "stack_revOnline_field_id_3229398"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > group "tag template 2" (id 3229396) > field "input" (id 3229398)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on returninfield
   if there is a field "auto copy" of the owner of me then
      if the visible of field "auto copy" of the owner of me then
         hide field "auto copy" of the owner of me
         select after me
      else
         addTag
         refreshList
      end if
   end if
end returninfield

on enterinfield
   if there is a field "auto copy" of the owner of me then
      if the visible of field "auto copy" of the owner of me then
         hide field "auto copy" of the owner of me
         select after me
      else
         addTag
         refreshList
      end if
   end if
end enterinfield
