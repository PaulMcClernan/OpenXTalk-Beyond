script "stack_revSEFind"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSEFind"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

command getSearchString
   return the label of button "Find" of this card of me
end getSearchString
