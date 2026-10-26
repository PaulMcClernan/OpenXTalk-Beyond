script "stack_revOnline_button_id_937653"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > group "chooser" (id 937645) > group "code upload" (id 937656) > button "paste" (id 937653)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the clipboard is "text" then
      put the clipboarddata into field "code input" of the owner of me
   end if
end mouseUp
