script "stack_revOnline_button_id_3021058"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > group "template new 1" (id 3021051) > button "Download" (id 3021058)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   rvoLaunchStack (the cStackId of the owner of me)
end mouseUp
