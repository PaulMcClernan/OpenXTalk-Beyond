script "stack_revSETemplate_button_id_1018"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSETemplate" > card "Main" (id 1002) > group "Toolbar" (id 1021) > button "Undo" (id 1018)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   actionUndo
   # Performing an undo may enable the redo button
   update
end mouseUp
