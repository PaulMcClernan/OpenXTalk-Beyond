script "stack_revObjectProperties_button_id_1022"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > substack "revObjectProperties" > card (id 1002) > button "OK" (id 1022)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cName of stack "revSearch" to the hilite of btn "name"
  set the cFieldText of stack "revSearch" to the hilite of btn "field text"
  set the cButtonContents of stack "revSearch" to the hilite of btn "button contents"
  set the cScript of stack "revSearch" to the hilite of btn "script"
  set the cOtherProperties of stack "revSearch" to the hilite of btn "other properties"
  set the cOtherPropertiesSearchType of stack "revSearch" to the hilitedButtonName of grp "other properties"
  set the cSpecificProperty of stack "revSearch" to the label of btn "specific property selector"
  set the cCustomProperties of stack "revSearch" to the hilite of btn "custom properties"
  close this stack
end mouseUp
