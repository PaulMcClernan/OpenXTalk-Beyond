script "stack_revOnline_button_id_1810571"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "search order" (id 78150) > button "Direction" (id 1810571)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the cSelectedDirection of the owner of me is "descending" then
      set the  cSelectedDirection of the owner of me to "ascending"
   else
      set the  cSelectedDirection of the owner of me to "descending"
   end if
   updateSearchList 0
end mouseUp
