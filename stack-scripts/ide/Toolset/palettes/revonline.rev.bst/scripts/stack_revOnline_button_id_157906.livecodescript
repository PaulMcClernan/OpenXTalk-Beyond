script "stack_revOnline_button_id_157906"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > group "template original" (id 157898) > button "Download" (id 157906)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   rvoLaunchStack (the cStackId of the owner of me)
end mouseUp
