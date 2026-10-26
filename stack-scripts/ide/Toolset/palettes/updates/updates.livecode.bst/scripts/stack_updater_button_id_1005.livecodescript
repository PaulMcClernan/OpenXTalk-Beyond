script "stack_updater_button_id_1005"
-- Stack file: ide/Toolset/palettes/updates/updates.livecode
-- Object: stack "updater" > card (id 1002) > button "tBtnDo" (id 1005)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local tLongCommandFileName

on mousedown
   if the shiftkey is down then
      opencard -- refresh everything
   else
      if the label of me is "close" then
         close this wd
      else
         -- run the update
         send tRunUpd to me in 1 millisecond
      end if
   end if
end mousedown

on tBtnInit
   --set the loc of me to the width of this wd /2, the height of this wd -the height of me -20
   if cd fld "status" contains "error" or cd fld "status" contains "no updates" then
      set the label of me to "Close"
   else
      set the label of me to "Update"
   end if
end tBtnInit


on tRunUpd
   -- get desktop folder & name of script to execute
   put specialFolderPath("desktop") into tDesktopFolder
   if not (the last char of tDesktopFolder is slash) then
      put tDesktopFolder & slash into tDesktopFolder
   end if
   if the platform contains "linux" then put "sh" into tTermScF
   if the platform contains "win" then put "bat" into tTermScF
   --
   put ("xTalk_IDE_update." & tTermScF) into tTermShortFile
   put (tDesktopFolder & tTermShortFile) into tLongCommandFileName -- this is our update script
   --
   put "Process complete. Relaunching in 5 seconds..." into cd fld "status"
   tCloseIDE
end tRunUpd


on tCloseIDE
   --
   set the itemdelimiter to ","
   put 0 into tcount
   put "false" into tUpdError
   hide cd btn "whatschanged"
   send tCountdownQuit to me in 1 second
end tCloseIDE

on tCountdownQuit
   put word 5 of cd fld "status" into tNumber
   if not(isNumber(tNumber)) then
      put "5" into tNumber
      put tNumber into word 5 of cd fld "status"
   else
      subtract 1 from tNumber
      put tNumber into word 5 of cd fld "status"
   end if
   if tNumber is "0" then
      if there is a file (tLongCommandFileName) then delete file (tLongCommandFileName) -- cleanup
      tRepringTest
   else
      send tCountdownQuit to me in 1 second
   end if
end tCountdownQuit


on tCountdownClose
   put word 5 of line 2 of cd fld "status" into tNumber
   if not(isNumber(tNumber)) then
      -- we are not in a countdown, so exit
      put "" into line 2 of cd field "status"
      exit tCountdownClose
   else
      subtract 1 from tNumber
      put tNumber into word 5 of line 2 of cd fld "status"
   end if
   if tNumber is "0" then
      if the shiftkey is down then exit tCountdownClose
      close this stack
   else
      send tCountdownClose to me in 1 second
   end if
end tCountdownClose


------------------------------------------------------------------------
-- this is all about respringing the IDE on various platforms --
-- as of 11-02-2026, this is handled in-engine (tperry) --
------------------------------------------------------------------------

on tRepringTest
   -- we have a respring implemented.
   _internal respring
end tRepringTest


