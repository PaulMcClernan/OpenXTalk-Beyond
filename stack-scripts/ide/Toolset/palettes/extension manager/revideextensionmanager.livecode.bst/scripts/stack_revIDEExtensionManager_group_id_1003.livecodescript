script "stack_revIDEExtensionManager_group_id_1003"
-- Stack file: ide/Toolset/palettes/extension manager/revideextensionmanager.livecode
-- Object: stack "revIDEExtensionManager" > card "list" (id 1002) > group "extensionList" (id 1003)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on dragEnter
   set the dragAction to "copy"
end dragEnter

on dragDrop
   installExtension the dragData["files"]
end dragDrop
