script "stack_revOnline_button_id_937640"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > group "chooser" (id 937645) > button "Stack" (id 937640)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   --   show group "stack upload" of the owner of me
   --   hide group "code upload" of the owner of me
   --   hide group "external upload" of the owner of me
   set the cContentType of the owner of me to "stack"
end mouseUp
