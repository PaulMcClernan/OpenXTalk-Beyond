script "stack_revOnline_button_id_3264029"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > group "tag item template" (id 3264030) > button "Button" (id 3264029)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local tTag
   put the text of field "name" of the owner of me into tTag
   --send "removeTag tTag" to the owner of me in 0 milliseconds
   send "removeTag tTag" to group "tag template 2" of this card of stack "revonline" in 0 milliseconds
end mouseUp
