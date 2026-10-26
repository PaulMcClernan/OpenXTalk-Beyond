script "stack_revPreferencesGUI_card_id_1013"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "App Browser" (id 1013)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   revRefreshABprefs
end preOpenCard

on revRefreshABprefs 
  set the hilitedLine of fld "object type" to 1
  send "selectionChanged" to fld "object type"
  set the hilite of btn "Show audio clips" to the cShowAudioclips of stack "revPreferences"
  set the hilite of btn "Show video clips" to the cShowVideoclips of stack "revPreferences"
end revRefreshABprefs

function revSelObjectType
   local tType
   put line (the hilitedLine of fld "object type") of fld "object type" into tType
   replace space with empty in tType
   return tType
end revSelObjectType
