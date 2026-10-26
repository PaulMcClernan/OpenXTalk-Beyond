script "stack_revSEFind_group_id_1047"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSEFind" > card "Main" (id 1002) > group "Options" (id 1041) > group "searchType" (id 1047)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   sePrefSet "find,regularexpressions", the hilite of button "regEx" of me
   sePrefSet "find,wildcards", the hilite of button "wildcards" of me
   sePrefSet "find,plaintext", the hilite of button "plaintext" of me
end mouseUp
