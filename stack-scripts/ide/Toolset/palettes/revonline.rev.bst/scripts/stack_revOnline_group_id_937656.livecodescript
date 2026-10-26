script "stack_revOnline_group_id_937656"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > group "chooser" (id 937645) > group "code upload" (id 937656)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

command resize
   set the topleft of field "code upload title" to (the left of me + 4, the top of me + 8)
   set the bottomleft of button "ok" of me to (the left of me + 6, the bottom of me - 4)
   set the bottomleft of button "cancel" of me to (the right of button "ok" of me + 6, the bottom of me - 4)
   set the bottomleft of button "paste" of me to (the right of button "cancel" of me + 6, the bottom of me - 4)
   set the rect of field "code input" of me to \
   (the left of me + 8, the bottom of field "code upload title" of me + 8, the right of me - 8, the top of button "paste" of me - 6)
   
   
end resize
