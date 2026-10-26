script "stack_revIDEExtensionManager_group_id_99579"
-- Stack file: ide/Toolset/palettes/extension manager/revideextensionmanager.livecode
-- Object: stack "revIDEExtensionManager" > card "list" (id 1002) > group "extensionList" (id 1003) > group "dvListMask" (id 1007) > group "dvList" (id 1008) > group "extensionRow" (id 99572) > group "installProgress" (id 99579)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on resizeControl
   set the width of scrollbar "installProgressBar" of me to the width of me
   set the width of field "installProgressStatus" of me to the width of me
   
   set the right of scrollbar "installProgressBar" of me to the right of me
   set the right of field "installProgressStatus" of me to the right of me
end resizeControl
