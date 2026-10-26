script "stack_revOnline_button_id_937664"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > group "chooser" (id 937645) > group "external upload" (id 937669) > group "OS X" (id 937661) > button "Browse" (id 937664)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the platform is "MacOS" then
      answer file "Please select external" with type "Bundles|bundle|APPL"
   else
      answer folder "Please select external"
   end if
   if it is not empty and char -7 to -1 of it is ".bundle" then
      put it into field "Path" of the owner of me
   end if
end mouseUp
