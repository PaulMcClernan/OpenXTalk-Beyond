script "stack_revPreferencesGUI_button_id_1147"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Script Editor" (id 1010) > group "Script Editor" (id 1142) > button "Font Size" (id 1147)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   set the cSize of me to labelToSize(the label of me)
   pass menuPick
end menuPick

private function labelToSize pLabel
   if pLabel is "Default" then
      return empty
   else
      return pLabel
   end if
end labelToSize

private function sizeToLabel pFont
   if pFont is empty then
      return "Default"
   else
      return pFont
   end if
end sizeToLabel

setProp cSize pSize
   lock messages
   set the cSize of me to pSize
   unlock messages
   
   set the label of me to "tempLabel"
   set the label of me to sizeToLabel(pSize)
end cSize
