script "stack_App_Browser_button_id_5989"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Cards and Controls" (id 1002) > group "Cards" (id 1583) > button "Refresh" (id 5989)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set cursor to busy
   lock screen
   tTPLinkColours
   -- conditional datagrid stacks (tperry 4-13-24)
   if the cDisableDataGrid of stack "revPreferences" is true then
         send hConditionalDataGrid to stack "revMenubar" in 1 ticks
   end if
   revRefreshTree
   unlock screen
end mouseUp
