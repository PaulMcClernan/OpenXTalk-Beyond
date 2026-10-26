script "stack_revPreferencesGUI_button_id_1169"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Script Editor" (id 1010) > group "Script Editor" (id 1142) > button "Use Tabs" (id 1169)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

getProp cLabel
   if the label of me is "New tab" then
      return true
   else
      return false
   end if
end cLabel

setProp cLabel pValue
   set the label of me to "tempLabel"
   if pValue then
      set the label of me to "New tab"
   else
      set the label of me to "New window"
   end if
end cLabel
