script "stack_revIDEProjectBrowser_button_id_986939"
-- Stack file: ide/Toolset/palettes/project browser/revideprojectbrowser.livecode
-- Object: stack "revIDEProjectBrowser" > card "list" (id 1002) > group "content" (id 155594) > group "objectList" (id 5765) > group "dvListMask" (id 5769) > group "dvList" (id 5770) > group "containerRow" (id 986932) > button "typeIcon" (id 986939)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the icon of me is the id of image "stackContracted" of card "templates" of this stack or the icon of me is the id of image "childContracted" of card "templates" of this stack then
      toggleGroup  the cRowNumber of the owner of me,true
   else if the icon of me is the id of image "stackExpanded" of card "templates" of this stack or the icon of me is the id of image "childExpanded" of card "templates" of this stack then
      toggleGroup  the cRowNumber of the owner of me,false
   end if
end mouseUp
