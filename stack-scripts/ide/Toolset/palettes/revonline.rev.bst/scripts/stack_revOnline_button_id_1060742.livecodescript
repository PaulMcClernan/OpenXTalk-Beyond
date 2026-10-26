script "stack_revOnline_button_id_1060742"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > group "chooser" (id 937645) > group "code upload" (id 937656) > button "ok" (id 1060742)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the text of field "code input" of the owner of me is not empty then
      local tCode
      put the text of field "code input" of the owner of me into tCode
      if the cMode of group "chooser" of group "stack" of group "viewing pane" of stack "revonline" is "update" then
         newCodeFileUpdate tCode
      else
         newCodeFile tCode
      end if
   else
      rvoUpdateTooltip "You must enter your code in the field above", true
   end if
end mouseUp
