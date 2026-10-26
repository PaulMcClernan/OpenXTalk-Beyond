script "stack_revPreferencesGUI_button_id_1145"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Script Editor" (id 1010) > group "Script Editor" (id 1142) > button "Font" (id 1145)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   set the cFont of me to labelToFont(the label of me)
   pass menuPick
end menuPick

private function labelToFont pLabel
   if pLabel is "Default" then
      return empty
   else
      return pLabel
   end if
end labelToFont

private function fontToLabel pFont
   if pFont is empty then
      return "Default"
   else
      return pFont
   end if
end fontToLabel

setProp cFont pFont
   lock messages
   set the cFont of me to pFont
   unlock messages
   
   set the label of me to "tempLabel"
   set the label of me to fontToLabel(pFont)
end cFont
