script "stack_revStandaloneSettings_button_id_29836"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "iOS" (id 1641) > button "iOSTabMenu" (id 29836)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on showGroup pGroupName
   if pGroupName is "Requirements" then
      put "Requirement" into pGroupName
   end if
   local tCurrentName
   repeat for each line tItemName in text of me
      if tItemName is "Requirements" then
         put "Requirement" into tCurrentName
      else 
         put tItemName into tCurrentName
      end if 
      if tCurrentName is not pGroupName then
         set the disabled of group tCurrentName to true
         hide group tCurrentName
      else
         set the disabled of group tCurrentName to false
         show group tCurrentName
      end if
   end repeat
end showGroup

on menuPick pItemName
   lock screen
   storeSetting "active menu", pItemName
   showGroup pItemName
   unlock screen
end menuPick
