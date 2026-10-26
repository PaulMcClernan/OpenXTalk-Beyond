script "stack_revPreferencesGUI_card_id_1007"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Files & Memory" (id 1007)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   
   set the hilite of button "absoluteImagePaths" to the cImageFileRelative of stack "revPreferences" is false
   set the hilite of button "add extension" to the cREVExtension of stack "revPreferences"
   
   set the hilite of button "destroyStack" to the cDestroyStack of stack "revPreferences"
   set the hilite of button "remove from memory" to false
   set the hilite of button "ask" to false
   set the hilite of button "don't remove" to false
   
   switch the cASKDestroy of stack "revPreferences"
      case "don't remove"
         set the hilite of button "don't remove" to true
         break
      case "remove"
         set the hilite of button "remove from memory" to true
         break
      case "ask"
         set the hilite of button "ask" to true
         break
   end switch
   
   put the cNumRecent of stack "revPreferences" into field "num recent files"
   set the hilitedButtonName of group "recent files sort" to the cRecentSort of stack "revPreferences"
   
   get the cPreserveStackCreator of stack "revPreferences"
   set the hilite of button "Preserve Stack Creator" to it is true
   set the enabled of button "Preserve Stack Creator" to the platform is "MacOS"
   
   get the cPreserveStackVersion of stack "revPreferences"
   set the hilite of button "Preserve Stack Version" to it is true
   
   get the cShowPresetSizes of stack "revPreferences"
   set the hilite of button "PresetSizes" to it is true
   
   
   -- check if we have close with no warning (tperry) 5-9-24
   if the cCloseNoWarn of stack "revPreferences" is true then
      set the hilite of cd btn "CloseNoWarn" of this card to true
   else
      set the hilite of cd btn "CloseNoWarn" of this card to false
   end if
   
   -- prompt for rename? (tperry 28-12-24)
   if the cAskForNewStackRename of stack "revPreferences" is true then
      set the hilite of cd btn "promptRename" of this card to true
   else
      set the hilite of cd btn "promptRename" of this card to false
   end if
   send "updateCustomizationPath" to group "Files & Memory" of me
   -- date stamp (tperry 29-12-24)
   if the cRenameWithDateStamp of stack "revPreferences" is true then
      set the hilite of cd btn "incDateStamp" of this card to true
   else
      set the hilite of cd btn "incDateStamp" of this card to false
   end if
   if the cRenameWithRandChars of stack "revPreferences" is true then
      set the hilite of cd btn "incRandChars" of this card to true
   else
      set the hilite of cd btn "incRandChars" of this card to false
   end if
   
   -- safety net? (tperry 21-1-25)
   if the cDontUseCaution of stack "revPreferences" is true then
      set the hilite of btn "safetynet" to false
   else
      set the hilite of btn "safetynet" to true
   end if
   
   -- gallery icons for recent files?
   if the cRecentstacksAsGallery of stack "revPreferences" is true then
      set the hilite of btn "useGallery" of this card to true
   else
      set the hilite of btn "useGallery" of this card to false
   end if
   
   -- custom icon, is this possible?
   send checkMacCustIcon to button "ismac"
   
end preOpenCard
