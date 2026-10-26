script "stack_revOnline_group_id_3414548"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "user" (id 31884) > group "edit profile" (id 3414548)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

command showEditControls
   lock screen
   hide field "edit profile" of me
   show button "save" of me
   show field "save" of me
   show button "cancel" of me
   show field "cancel" of me
   unlock screen
end showEditControls

command hideEditControls
   lock screen
   show field "edit profile" of me
   hide button "save" of me
   hide field "save" of me
   hide button "cancel" of me
   hide field "cancel" of me
   unlock screen
end hideEditControls
