script "stack_revPreferencesGUI_group_id_1024"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "General" (id 1002) > group "General" (id 1016) > group "Options in Properties palettes are labeled with:" (id 1024)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp  
  if the owner of the target is not me then pass mouseUp
  revUpdateLanguageNamePref
end mouseUp

on revUpdateLanguageNamePref
  global gREVLanguageNames
  if the hilite of btn "Language names on properties" of cd "general" is true then
    put true into gREVLanguageNames
  else
    put false into gREVLanguageNames
  end if
  set the cLanguageNames of cd 1 of stack "revPreferences" to gREVLanguageNames
  send "selectedObjectChanged" to stack "revBackScriptLibrary"
  ideCorePropertyInspectorRefreshPropertyLabels
end revUpdateLanguageNamePref
