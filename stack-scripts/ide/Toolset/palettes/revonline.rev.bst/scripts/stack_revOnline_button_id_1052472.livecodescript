script "stack_revOnline_button_id_1052472"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > group "chooser" (id 937645) > group "stack upload" (id 937651) > button "ok" (id 1052472)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the text of field "stack path" is not empty then
      local tPath
      put the text of field "stack path" of the owner of me into tPath
      if the cMode of group "chooser" of group "stack" of group "viewing pane" of stack "revonline" is "update" then
         newStackFileUpdate tPath
      else
         newStackFile tPath
      end if
   else
      rvoUpdateTooltip "You must select a stack to upload", true
   end if
end mouseUp

on mouseEnter
   set the backgroundColor of me to "124,193,222"
end mouseEnter

on mouseLeave
   set the backgroundColor of me to "214,214,214"
end mouseLeave

