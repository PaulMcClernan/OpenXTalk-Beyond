script "stack_updater_button_id_1018"
-- Stack file: ide/Toolset/palettes/updates/updates.livecode
-- Object: stack "updater" > card (id 1002) > button "miniIcon" (id 1018)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

global tRetainTitle

on mousedown
   if the shiftkey is down then
      tUpdEdToggle
   end if
end mousedown

on tUpdEdToggle
   if the tEditorOn of btn "miniIcon" is true then
      set the tEditorOn of btn "miniIcon" to false
      set the cantmodify of this stack to true
   else
      set the tEditorOn of btn "miniIcon" to true
      set the cantmodify of this stack to false
   end if
   tUpdTitle
   send resizeStack to this stack
end tUpdEdToggle


on tUpdTitle
   if the tEditorOn of btn "miniIcon" is true then
      put " (edit mode)" into tEditModeDisplay
   else
      put "" into tEditModeDisplay
   end if
   put the title of stack "revMenubar" & " - " & tRetainTitle into fld "helpTitle"
   --tRetainTitle is in Stack Script if you are wondering
   set the title of this stack to tRetainTitle & tEditModeDisplay
end tUpdTitle
