script "stack_revSETemplate_button_id_14915"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSETemplate" > card "Main" (id 1002) > group "Editor" (id 1046) > group "Interactive Find" (id 14913) > button "Close" (id 14915)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  findFinalize
  hideInteractiveFind
end mouseUp
