script "stack_revPreferencesGUI_button_id_1232"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "RevOnline" (id 1014) > group "revOnline" (id 1223) > group "Cache options" (id 1229) > button "Clear" (id 1232)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   revOnlineCacheClear
   update
end mouseUp
