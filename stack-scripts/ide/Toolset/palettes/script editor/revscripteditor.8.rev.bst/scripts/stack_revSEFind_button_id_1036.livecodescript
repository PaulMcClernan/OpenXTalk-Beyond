script "stack_revSEFind_button_id_1036"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSEFind" > card "Main" (id 1002) > group "Options" (id 1041) > button "Case sensitive search" (id 1036)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   sePrefSet "find,casesensitive", the hilite of me
end mouseUp
