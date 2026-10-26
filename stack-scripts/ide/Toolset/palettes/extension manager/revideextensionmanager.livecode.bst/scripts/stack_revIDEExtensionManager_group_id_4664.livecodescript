script "stack_revIDEExtensionManager_group_id_4664"
-- Stack file: ide/Toolset/palettes/extension manager/revideextensionmanager.livecode
-- Object: stack "revIDEExtensionManager" > card "templates" (id 1011) > group "extensionRow" (id 1013) > group "installProgress" (id 4664)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on resizeControl
   set the width of scrollbar "installProgressBar" of me to the width of me
   set the width of field "installProgressStatus" of me to the width of me
   
   set the right of scrollbar "installProgressBar" of me to the right of me
   set the right of field "installProgressStatus" of me to the right of me
end resizeControl
