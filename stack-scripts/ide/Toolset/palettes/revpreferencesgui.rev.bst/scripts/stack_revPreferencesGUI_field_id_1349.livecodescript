script "stack_revPreferencesGUI_field_id_1349"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "General" (id 1002) > group "Navigation" (id 1003) > field "Menu" (id 1349)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown   
  sectionChange
end mouseDown  

on selectionChanged
  sectionChange
end selectionChanged

on sectionChange
   go card word 1 to -1 of line (the hilitedLine of me) of me
   focus on me
   updPrefPath
end sectionChange


on updPrefPath
   -- tperry 11-02-2026
   -- show where the prefs are being stored
   put the long name of stack "revPreferences" into myPrefsLoc
   if word 1 of myPrefsLoc is "stack" then delete word 1 of myPrefsLoc
   if char 1 of myPrefsLoc is QUOTE then delete char 1 of myPrefsLoc
   if last char of myPrefsLoc is QUOTE then delete last char of myPrefsLoc
   put "preferences are saved in:" & return & myPrefsLoc into field "prefloc" of group "Navigation" of stack "revPreferencesGUI"
   
end updPrefPath
