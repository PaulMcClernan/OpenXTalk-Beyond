script "stack_revMessageWatcher_card_id_1002"
-- Stack file: ide/Toolset/palettes/revmessagewatcher.rev
-- Object: stack "revMessageWatcher" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

constant maxmess = 100
local mlist, lMilliseconds

local bSuppressAll = 0
on suppressRecording n
  put n into bSuppressAll
end suppressRecording

on recordMessage t, m, o, h
   if bSuppressAll = 1 then 
      exit recordMessage
   end if
   
   if not the hilite of button "Active" of card 1 of me then
      exit recordMessage
   end if
   
   --
   global gREVDevelopment
   
   local tTime
   if lMilliseconds is empty then
      put 0 into tTime
   else 
      put the milliseconds - lMilliseconds into tTime
   end if
   
   # OK-2008-10-21 : Bug 7170 - Better suppression of IDE messages. Using revOkTarget instead of revFilterStacksList (which assumed that 
   # no IDE stacks would have a mode of 1).
   local ns
   if m is among the lines of the suppressedMessages of stack "revPreferences" \
   or t is among the lines of the suppressedTypes of stack "revPreferences" \
   or h is among the lines of the suppressedActions of stack "revPreferences" \
   or the suppressIDE of stack "revPreferences" \
   and revOKTarget(o) is true then
      exit recordMessage
   end if
   
   get the hilitedLines of field "Messages"
   if the number of lines in mlist > maxmess then
      delete line 1 of mlist
      delete line 1 of field "Messages"
      subtract 1 from it
   end if
   put char 1 to (the number of lines in the executionContexts) - 2 of "              " into ns
   if field "Messages" is empty then
      put t,o after mlist
      put ns & m && the long time && "(" & tTime & ")" after field "Messages"
   else
      put cr & t,o after mlist
      put cr & ns & m && the long time && "(" & tTime & ")" after field "Messages"
   end if
   --if it < 1 then
   put empty into field "Object Name"
   put empty into field "Message Type"
   set the scroll of field "Messages" to 10000000
   put the milliseconds into lMilliseconds
   --end if
   --else set the hilitedLines of field "Messages" to it
end recordMessage

on selectMessage which
  put item 1 of line which of mlist into field "Message Type"
  put item 2 of line which of mlist into field "Object Name"
end selectMessage

on openCard
  clearMessages
  set the messageMessages to true
end openCard

on preOpenStack
  if the cMessageWatcherRect of stack "revPreferences" is not empty then
    set the rect of this stack to the cMessageWatcherRect of stack "revPreferences"
  end if
  
  # OK-2008-03-05 : Bug 6010. The message watcher should be enabled by default.
  set the hilite of button "Active" of me to true
  
  revInternal__ConstrainStack the short name of the owner of me
  resizeStack
end preOpenStack

on closeCard
  set the messageMessages to false
  clearMessages
  set the cMessageWatcherRect of stack "revPreferences" to the rect of this stack
end closeCard

on clearMessages
  put empty into field "Messages"
  put empty into field "Object Name"
  put empty into field "Message Type"
  put empty into mlist
end clearMessages

on resizeStack
  set the width of field "Messages" to the width of me - 8
  set the height of field "Messages" to the height of this card - 105
  set the top of field "Object Label" to the bottom of field "Messages" + 8
  set the top of field "Object Name" to the bottom of field "Messages" + 8
  set the width of field "Object Name" to the width of me - the right of field "Object Label" - 8
  set the width of field "Message Type" of me to the width of me - the right of field "Type Label" of me - 8
  
  set the right of fld "object name" to the right of me - 8
  set the top of field "Type Label" to the bottom of field "Messages" + 40
  set the top of field "Message Type" to the bottom of field "Messages" + 40
  set the right of field "Message Type" of me to the right of me - 8
  
  # OK-2008-03-14 : Bug 6064
  set the topLeft of button "Active" of me to (the left of me + 8), (the bottom of field "Message Type" of me + 8)
  set the topLeft of button "Clear" of me to (the right of button "Active" of me + 8), (the bottom of field "Message Type" of me + 8)
  set the topLeft of button "Suppress..." of me to (the right of button "Clear" of me + 8), (the bottom of field "Message Type" of me + 8)
  
  
  --  set the top of button "Active" to the top of field "Message Type"
  --  set the top of button "Clear" to the bottom of field "Messages" + 40
  --  set the top of button "Suppress..." to the bottom of field "Messages" + 40
  --  set the right of button "Suppress..." to the right of this card - 12
  --  set the right of button "Clear" to the left of button "Suppress..." - 8
  set the cMessageWatcherRect of stack "revPreferences" to the rect of this stack
end resizeStack

on suspendStack
  revSEShowPalettes
end suspendStack
