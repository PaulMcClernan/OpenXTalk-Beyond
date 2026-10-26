script "stack_revIDEExtensionManager_widget_id_25881"
-- Stack file: ide/Toolset/palettes/extension manager/revideextensionmanager.livecode
-- Object: stack "revIDEExtensionManager" > card "list" (id 1002) > group "background" (id 25432) > widget "header_background" (id 25881)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--on actionSelected pItemName
--   put "actionSelected " & pItemName
--   pass actionSelected
--end actionSelected

--on menuPick pPick
--   put "menuPick " & pPick
--end menuPick

--on navChanged pParam
--   put "navChanged " & pParam
--end navChanged

--on navSelected pItemName
--   -- put "navSelected " & pItemName & cr
--   if pItemName is "Repo" then
--      -- put pItemName
--      -- set the goSection of this stack to "Repo"
--      send "showExtensionStore" to this stack -- in 1 millisecs
--      send ("doXTscriptInWidget "& quote &"go last"&quote) to this stack in 1 milliseconds
--      exit navSelected
--   end if
--   if pItemName is "Playground" then
--      -- set the goSection of this stack to "Playground"
--      send "showWebPlaygound" to this stack -- in 1 millisecs
--      send ("doXTscriptInWidget "& quote &"go first"&quote) to this stack in 1 milliseconds
--      exit navSelected
--   end if
--   pass navSelected
--end navSelected


