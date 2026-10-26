script "stack_revOnline_button_id_3021073"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > group "template new 2" (id 3021066) > button "Download" (id 3021073)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   rvoLaunchStack (the cStackId of the owner of me)
end mouseUp

on mouseEnter
   set the backgroundColor of me to "124,193,222"
end mouseEnter

on mouseLeave
   set the backgroundColor of me to "214,214,214"
end mouseLeave
