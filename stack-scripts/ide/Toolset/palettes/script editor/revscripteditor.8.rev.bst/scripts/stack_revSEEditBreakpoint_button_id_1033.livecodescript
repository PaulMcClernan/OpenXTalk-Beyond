script "stack_revSEEditBreakpoint_button_id_1033"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSEEditBreakpoint" > card (id 1002) > group "Watch" (id 1026) > button "Handler" (id 1033)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   set the cHandler of this stack to pItemName
   updateWatch
end menuPick
