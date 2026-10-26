script "stack_revPreferencesGUI_card_id_1320"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Project Browser" (id 1320)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   revIDEUpdatePBPreferences
   
   ## Object Type Indicator
   set the hilitedButtonName of group "objectType" to revIDEGetPreference("pb_indicator")
   
   ## Sections to show
   local tSelectedSections, tSections
   put revIDEGetPreference("pb_sections") into tSelectedSections
   put "Front scripts,Stacks,Back scripts,Stacks in use" into tSections
   repeat for each item tSection in tSections
      set the hilite of button tSection of me to (tSection is among the items of tSelectedSections)
   end repeat
   
   local tStackType, tCardType, tControlType
   local tStackOrder, tCardOrder, tControlOrder
   revIDEGetPBSortPreferences "pb_stackSort", tStackType, tStackOrder
   revIDEGetPBSortPreferences "pb_cardSort", tCardType, tCardOrder
   revIDEGetPBSortPreferences "pb_controlSort", tControlType, tControlOrder
   
   ## Sorting
   set the label of button "stackSortType" of me to tStackType
   set the label of button "cardSortType" of me to tCardType
   set the label of button "controlSortType" of me to tControlType
   
   put toupper(char 1 of tStackOrder) into char 1 of tStackOrder
   put toupper(char 1 of tCardOrder) into char 1 of tCardOrder
   put toupper(char 1 of tControlOrder) into char 1 of tControlOrder
   
   set the label of button "stackSortOrder" of me to tStackOrder
   set the label of button "cardSortOrder" of me to tCardOrder
   set the label of button "controlSortOrder" of me to tControlOrder
   
   local tTextSize
   put revIDEGetPreference("pb_textSize") into tTextSize
   set the label of button "textSize" of me to tTextSize
end preOpenCard

command updatePreference pName, pValue
   revIDESetPreference pName, pValue
end updatePreference
