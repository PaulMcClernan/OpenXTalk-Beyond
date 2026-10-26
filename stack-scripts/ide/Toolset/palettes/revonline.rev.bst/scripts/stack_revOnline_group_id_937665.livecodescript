script "stack_revOnline_group_id_937665"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > group "chooser" (id 937645) > group "external upload" (id 937669) > group "Linux" (id 937665)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

command resize
   set the left of button "check" of me to the left of me + 4
   set the right of button "browse" of me to the right of me - 4
   set the rect of field "path" of me to \
          (the right of button "check" of me + 4, the top of me + 5, the left of button "browse" of me - 8, the bottom of me - 4)
   set the rect of image "path background" of me to \
          (the right of button "check" of me + 4, the top of me + 5, the left of button "browse" of me - 8, the bottom of me - 4)
end resize
