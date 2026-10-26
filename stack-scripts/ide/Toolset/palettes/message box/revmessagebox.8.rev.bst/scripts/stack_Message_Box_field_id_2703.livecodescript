script "stack_Message_Box_field_id_2703"
-- Stack file: ide/Toolset/palettes/message box/revmessagebox.8.rev
-- Object: stack "Message Box" > card "Global Variables" (id 2526) > group "controls" (id 2704) > field "contents" (id 2703)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField
   local tSelectedText, tDoString
   put line (the hilitedLine of field "type") of field "type" into tSelectedText
    if tSelectedText is not empty then
      put "global" && tSelectedText & cr & "put field" && quote & "contents" & quote && "into" && tSelectedText into tDoString
      do tDoString
   end if
   pass closeField
end closeField

on enterInField
   send "closeField" to me
   select the text of me
end enterInField
