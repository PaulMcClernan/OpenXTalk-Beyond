script "stack_revIDEProjectBrowser_group_id_656485"
-- Stack file: ide/Toolset/palettes/project browser/revideprojectbrowser.livecode
-- Object: stack "revIDEProjectBrowser" > card "templates" (id 5773) > group "pbDragIndicator" (id 656485)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on resizeControl
   set the width of me to the width of this stack
   set the width of graphic "indicator" of me to the width of this stack
   set the left of graphic "indicator" of me to 0
end resizeControl

--on PositionDropIndicator pParam, pParam2
--   put "position drop" && pParam && pParam2 & return before msg
--end PositionDropIndicator
