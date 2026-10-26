script "stack_revOnline_button_id_937659"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > group "chooser" (id 937645) > group "external upload" (id 937669) > group "Windows" (id 937657) > button "Check" (id 937659)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the visible of image "path background" of the owner of me to the hilite of me
   set the enabled of field "Path" of the owner of me to the hilite of me
   set the enabled of button "Browse" of the owner of me to the hilite of me
   set the showborder of field "Path" of the owner of me to not the hilite of me
end mouseUp
