script "stack_revideprojectbrowsersectionrowtemplate_button_id_1048"
-- Stack file: ide/Toolset/palettes/project browser/templates/revideprojectbrowsersectionrowtemplate.livecode
-- Object: stack "revideprojectbrowsersectionrowtemplate" > card (id 1002) > group "sectionRow" (id 1044) > button "typeIcon" (id 1048)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the icon of me is the id of image "contracted" of card "templates" of this stack then
      set the icon of me to the id of image "expanded" of card "templates" of this stack
      --set the hoverIcon of me to the id of image "expanded_hover" of card "templates" of this stack
      toggleGroup  the cRowNumber of the owner of me,true
   else if the icon of me is the id of image "expanded" of card "templates" of this stack then
      set the icon of me to the id of image "contracted" of card "templates" of this stack
      --set the hoverIcon of me to the id of image "contracted_hover" of card "templates" of this stack
      toggleGroup  the cRowNumber of the owner of me,false
   end if
end mouseUp
