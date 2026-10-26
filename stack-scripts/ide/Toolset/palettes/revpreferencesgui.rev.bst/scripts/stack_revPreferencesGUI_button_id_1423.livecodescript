script "stack_revPreferencesGUI_button_id_1423"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Extras" (id 1402) > button "tidyUpStacks" (id 1423)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cTidyUpStacks of stack "revPreferences" to the hilite of me
   if the hilite of me is true then
      send tTidyUpStacks to stack "revMenubar" in 3 ticks
   end if
   revUpdateAB
end mouseUp
