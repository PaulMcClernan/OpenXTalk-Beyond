script "stack_revOnline_field_id_35287"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "user" (id 31884) > field "website" (id 35287)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the showBorder of me is false and the text of me is not empty then
      revGoUrl (the text of me)
   end if
end mouseUp


on mouseEnter
   if the showBorder of me is false and the text of me is not empty then
      set the textStyle of me to "underline"
   end if
end mouseEnter

on mouseMove
   if the showBorder of me is false and the text of me is not empty then
      set the textStyle of me to "underline"
   end if
end mouseMove

on mouseLeave
   if the showBorder of me is false then
      set the textStyle of me to empty
   end if
end mouseLeave
