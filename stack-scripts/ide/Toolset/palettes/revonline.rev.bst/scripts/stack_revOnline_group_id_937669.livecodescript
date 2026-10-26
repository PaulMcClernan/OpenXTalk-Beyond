script "stack_revOnline_group_id_937669"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > group "chooser" (id 937645) > group "external upload" (id 937669)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

command resize
   set the topleft of field "external upload title" to (the left of me + 4, the top of me + 8)
   
   set the rect of group "windows" of me to \
   (the left of me + 4, the bottom of field "external upload title" of me + 4, the right of me - 8, the bottom of field "external upload title" of me + 34)
   send "resize" to group "windows" of me
   
   set the rect of group "os x" of me to \
   (the left of me + 4, the bottom of group "windows" of me + 4, the right of me - 8, the bottom of group "windows" of me + 34)
   send "resize" to group "os x" of me
   
   set the rect of group "linux" of me to \
   (the left of me + 4, the bottom of group "os x" of me + 4, the right of me - 8, the bottom of group "os x" of me + 34)
   send "resize" to group "linux" of me
      
   set the bottomleft of button "ok" of me to (the left of me + 6, the bottom of me - 4)
   set the bottomleft of button "cancel" of me to (the right of button "ok" of me + 6, the bottom of me - 4)
end resize
