script "stack_revOnline_button_id_14749"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "search filter" (id 1007) > button "Go" (id 14749)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   updateSearch
end mouseUp

on mouseEnter
   set the backgroundColor of me to rvoHiliteColor()
end mouseEnter

on mouseLeave
   set the backgroundColor of me to "214,214,214"
end mouseLeave
