script "stack_revSEFind_button_id_1032"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSEFind" > card "Main" (id 1002) > button "Replace all" (id 1032)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the label of me is "Cancel" then
      set the label of me to "Cancelling.."
      cancelOperation
      exit mouseUp
   end if
   
   set the label of me to "Cancel"
   lock cursor
   set the cursor to watch
   replaceAll
   unlock cursor
   set the label of me to empty
end mouseUp
