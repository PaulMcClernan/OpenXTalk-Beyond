script "stack_revNewScriptEditor_1_button_id_1022"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revNewScriptEditor 1" > card "Main" (id 1002) > group "Toolbar" (id 1021) > button "Compile" (id 1022)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  local tCompilationResult
  actionCompile
  put the result into tCompilationResult
  if tCompilationResult is empty then
    disable me
  end if
end mouseUp
