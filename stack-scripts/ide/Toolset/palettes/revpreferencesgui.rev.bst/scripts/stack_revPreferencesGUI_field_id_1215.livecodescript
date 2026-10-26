script "stack_revPreferencesGUI_field_id_1215"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "App Browser" (id 1013) > field "object type" (id 1215)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on selectionChanged
  put revSelObjectType() into tType
  switch tType
  case "Stacks"
    put "Toplevel" into tMenuItem
    break
  case "Cards"
    put "Go" into tMenuItem
    break
  case "Controls"
    put empty into tMenuItem
    break
  default
    put "play" into tMenuItem
    break
  end switch
  repeat with i = 1 to the num of btns in grp "double-click"
    put tMenuItem into line 3 of btn i of grp "double-click"
  end repeat
  set the label of btn "double-click" to the cABDoubleClick[tType] of stack "revPreferences"
  set the label of btn "command double-click" to the cABCommandDoubleClick[tType] of stack "revPreferences"
  set the label of btn "option double-click" to the cABOptionDoubleClick[tType] of stack "revPreferences"
end selectionChanged
