script "stack_revPreferencesGUI_button_id_1508"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Files & Memory" (id 1007) > button "incDateStamp" (id 1508)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
   if the hilite of me is true then
      set the hilite of me to false
   else
      set the hilite of me to true
   end if
   set the cRenameWithDateStamp of stack "revPreferences" to the hilite of me
end mouseup
