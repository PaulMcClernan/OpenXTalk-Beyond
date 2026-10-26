script "stack_revSETemplate_button_id_14919"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSETemplate" > card "Main" (id 1002) > group "Editor" (id 1046) > group "Interactive Find" (id 14913) > button "Case" (id 14919)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   # OK-2009-03-10 : Bug 7070 - The match case check box should set the current preference value,
   # as it does in the find and replace dialog.
   sePrefSet "find,casesensitive", the hilite of me
   pass mouseUp
end mouseUp
