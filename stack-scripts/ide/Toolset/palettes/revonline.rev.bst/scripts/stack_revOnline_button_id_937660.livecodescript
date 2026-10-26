script "stack_revOnline_button_id_937660"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > group "chooser" (id 937645) > group "external upload" (id 937669) > group "Windows" (id 937657) > button "Browse" (id 937660)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   answer file "Please select external" with filter "*.dll"
   if it is not empty then
      put it into field "Path" of the owner of me
   end if
end mouseUp
