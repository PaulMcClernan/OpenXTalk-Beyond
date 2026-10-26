script "stack_Message_Box_field_id_2702"
-- Stack file: ide/Toolset/palettes/message box/revmessagebox.8.rev
-- Object: stack "Message Box" > card "Global Variables" (id 2526) > group "controls" (id 2704) > field "type" (id 2702)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

command revDisplayGlobals
   local tSelectedText, tDoString
   
   put line (the hilitedLine of me) of me into tSelectedText
   if tSelectedText is not empty then
      put "global" && tSelectedText & return & "put" && tSelectedText && "into field " & quote & "contents" & quote into tDoString
      do tDoString              
   end if
   if the hilitedLine of me is empty then disableFrameItem "removeSelected"
end revDisplayGlobals

on arrowKey
  send "revDisplayGlobals" to me in 10 milliseconds
  pass arrowKey
end arrowKey

on mouseUp
   if the hilitedLine of field "type" is empty 
   then disableFrameItem "removeSelected"
   else enableFrameItem "removeSelected"
  revDisplayGlobals
  pass mouseUp
end mouseUp
