script "stack_revideprojectbrowsercontrolrowtemplate_button_id_1013"
-- Stack file: ide/Toolset/palettes/project browser/templates/revideprojectbrowsercontrolrowtemplate.livecode
-- Object: stack "revideprojectbrowsercontrolrowtemplate" > card (id 1002) > group "controlRow" (id 1003) > button "controlIcon" (id 1013)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the icon of me is the id of image "stackContracted" of card "templates" of this stack or the icon of me is the id of image "childContracted" of card "templates" of this stack then
      toggleGroup  the cRowNumber of the owner of me,true
   else if the icon of me is the id of image "stackExpanded" of card "templates" of this stack or the icon of me is the id of image "childExpanded" of card "templates" of this stack then
      toggleGroup  the cRowNumber of the owner of me,false
   end if
end mouseUp
