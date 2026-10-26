script "stack_CustomScriptCol"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > substack "CustomScriptCol"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on openstack
   send mousedown to button "update" of stack "CustomScriptCol"
end openstack
