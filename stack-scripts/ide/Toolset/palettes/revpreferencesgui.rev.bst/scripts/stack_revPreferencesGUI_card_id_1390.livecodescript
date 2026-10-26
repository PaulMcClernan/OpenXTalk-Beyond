script "stack_revPreferencesGUI_card_id_1390"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Dictionary" (id 1390)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   revRefreshABprefs
   
   -- check if scripts pre-populated is turned on (tperry 09-11-2023)
   if the cPrePopulateScripts of stack "revPreferences" is true then
      set the hilite of btn "prePopulateScripts" of card "Dictionary" of stack "revPreferencesGUI" to true
   else
      set the hilite of btn "prePopulateScripts" of card "Dictionary" of stack "revPreferencesGUI" to false
   end if
   ---------------
   set the hilite of btn "useQuickDict" to the cQuickDictionary of stack "revPreferences" -- quick dictionary check (tperry 17-4-24)
end preOpenCard

on revRefreshABprefs 
   --set the hilitedLine of fld "object type" to 1
   --send "selectionChanged" to fld "object type"
   set the hilite of btn "inExtBrowser" to the cDictionaryDisplayMethod of stack "revPreferences"
   
end revRefreshABprefs

function revSelObjectType
   local tType
   put line (the hilitedLine of fld "object type") of fld "object type" into tType
   replace space with empty in tType
   return tType
end revSelObjectType
