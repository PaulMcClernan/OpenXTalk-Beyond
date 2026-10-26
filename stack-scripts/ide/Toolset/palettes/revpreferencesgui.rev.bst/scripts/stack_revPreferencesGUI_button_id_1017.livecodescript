script "stack_revPreferencesGUI_button_id_1017"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "General" (id 1002) > group "General" (id 1016) > button "Show Revolution Stacks" (id 1017)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  revToggleShowStacks
  if the mode of stack "revPreferences" is not 0
  then modeless "revPreferences"
end mouseUp

on revToggleShowStacks
  global gREVShowStacks
  put the hilite of me into gREVShowStacks
  set the cShowRevolutionStacks of stack "revPreferences" to the hilite of me
  revIDEMessageSend "idePreferenceChanged:cShowRevolutionStacks"
  lock screen
  if the mode of stack "revSearch" is not 0 
  then send "revFeedback" to stack "revSearch"
  revUpdateAB
  put revPalettesList() into tPalettes
  repeat for each line l in tPalettes
    send "revUpdatePalette" to this cd of stack l
  end repeat
  unlock screen
end revToggleShowStacks
