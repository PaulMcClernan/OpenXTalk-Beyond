script "stack_revDataGridLibrary"
-- Stack file: ide/Toolset/palettes/revdatagridlibrary.rev
-- Object: stack "revDataGridLibrary"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on openstack
   if the name of this stack contains "DataGridLibrary" then
      -- are datagrids turned off? - conditional datagrid stacks (tperry 4-13-24)
      if the cDisableDataGrid of stack "revPreferences" is true then send hConditionalDataGrid to stack "revMenubar" in 1 ticks
   end if
   pass openstack
end openstack
