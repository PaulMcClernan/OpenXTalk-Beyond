script "stack_revOnline_button_id_43033"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > button "Tag" (id 43033)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   tagContent
end mouseUp

on mousemove
   set the textStyle of field "addtag" of the owner of me to "underline"
end mousemove

on mouseleave
   set the textStyle of field "addtag" of the owner of me to empty
end mouseleave
