script "stack_revPreferencesGUI_button_id_1527"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Files & Memory" (id 1007) > button "customStackIcon" (id 1527)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseenter
   send checkMacCustIcon to button "ismac"
end mouseenter

on mouseup
   if the cMacCustomStackIcon of stack "revPreferences" is true then
      set the hilite of btn "customStackIcon" of this card to false
      set the cMacCustomStackIcon of stack "revPreferences" to false
   else
      set the hilite of btn "customStackIcon" of this card to true
      set the cMacCustomStackIcon of stack "revPreferences" to true
   end if
end mouseup
