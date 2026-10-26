script "stack_revNewScriptEditor_1_card_id_1002"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revNewScriptEditor 1" > card "Main" (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

# OK-2008-06-24 : The IDE periodically sends this message to the current card of the script editor,
# so it should be handled to prevent errors.
command revUpdatePalette
   #Did opening a script editor cause datagrids to invoke?
   -- conditional datagrid stacks (tperry 4-13-24)
   if the cDisableDataGrid of stack "revPreferences" is true then send hConditionalDataGrid to stack "revMenubar" in 1 ticks
   
   send pFixupMacElements to stack "revseutilities" in 10 milliseconds
   
end revUpdatePalette
