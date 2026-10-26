script "stack_revPreferencesGUI_button_id_1178"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Script Editor" (id 1010) > group "Script Editor" (id 1142) > button "Indentation" (id 1178)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   set the cValue of me to labelToValue(the label of me)
   pass menuPick
end menuPick

private function labelToValue pLabel
      return pLabel
end labelToValue

private function valueToLabel pValue
   return pValue
end valueToLabel

setProp cValue pValue
   lock messages
   set the cValue of me to pValue
   unlock messages
   
   set the label of me to "tempLabel"
   set the label of me to valueToLabel(pValue)
end cValue
