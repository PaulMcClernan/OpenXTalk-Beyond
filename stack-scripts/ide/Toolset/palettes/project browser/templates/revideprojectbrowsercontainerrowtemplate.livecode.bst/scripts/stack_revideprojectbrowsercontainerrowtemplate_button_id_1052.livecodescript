script "stack_revideprojectbrowsercontainerrowtemplate_button_id_1052"
-- Stack file: ide/Toolset/palettes/project browser/templates/revideprojectbrowsercontainerrowtemplate.livecode
-- Object: stack "revideprojectbrowsercontainerrowtemplate" > card (id 1002) > group "containerRow" (id 1044) > button "typeIcon" (id 1052)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the icon of me is the id of image "stackContracted" of card "templates" of this stack or the icon of me is the id of image "childContracted" of card "templates" of this stack then
      toggleGroup  the cRowNumber of the owner of me,true
   else if the icon of me is the id of image "stackExpanded" of card "templates" of this stack or the icon of me is the id of image "childExpanded" of card "templates" of this stack then
      toggleGroup  the cRowNumber of the owner of me,false
   end if
end mouseUp
