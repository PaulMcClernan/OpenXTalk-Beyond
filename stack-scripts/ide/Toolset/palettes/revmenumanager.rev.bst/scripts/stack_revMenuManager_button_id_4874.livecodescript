script "stack_revMenuManager_button_id_4874"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Button Menus:" (id 3224) > button "New Menu" (id 4874)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the cAnswerDialog of fld "Menu Name" or the cAnswerDialog of fld "Item Name" then exit mouseUp
   lock screen
   revCheckNameChanged
   --new menu
   put the cREVMenuID of this stack into tMenuID
   put the num of lines in fld "Menu Buttons" + 1 into tNum  
   put revNewMenuName(the long id of bg id tMenuID of stack (the cREVDefaultStack of this stack), tNum) into tButtonName
   put tButtonName into fld "Menu Name"
   put the hilitedLine of fld "Menu Buttons" into tHilitedLine
   set the lockLoc of the templateButton to true
   set the showBorder of the templateButton to false
   -- set some properties to make the button behave as a menu
   set the style of the templateButton to "menu"
   set the menuMode of the templateButton to "pulldown"
   set the opaque of the templateButton to true
   set the autoHilite of the templateButton to true
   set the hiliteBorder of the templateButton to true
   set the armBorder of the templateButton to true
   set the traversalOn of the templateButton to false
   set the showBorder of the templateButton to false

   --other properties    
   set the name of the templateButton to tButtonName
   set the label of the templateButton to tButtonName
   set the text of the templateButton to "Item 1"
   set the defaultStack to the cREVDefaultStack of this stack
   create btn in bg id tMenuID
   put the id of it into tButtonId
   reset the templateButton
   set the defaultStack to "revMenuManager"
   put the cREVLine of grp "Menu Insert" into tWidgetLine
   put the cREVMenuButtonIds of this stack into tButtonIds
   
   put the htmltext of fld "Menu Buttons" into tHtml
   if tWidgetLine is empty or tWidgetLine is 0 then
      if tButtonIds is empty then
         put "<p>" & tButtonname & "</p>" into tHtml
         put tButtonID into tButtonIds
      else
         put "<p>" & tButtonname & "</p>" & cr before line 1 of tHtml
         put tButtonID & cr before line 1 of tButtonIds
      end if
   else
      put cr & "<p>" & tButtonname & "</p>" after line tWidgetLine of tHtml
      put cr & tButtonId after line tWidgetLine of tButtonIds
   end if
   set the htmlText of fld "Menu Buttons" to tHtml
   set the cREVMenuButtonIds of this stack to tButtonIds
   set the hilitedLine of fld "Menu Buttons" to (tWidgetLine + 1)
   send "mouseUp" to fld "Menu Buttons"
   revLayoutMenuButtons
   select the text of fld "Menu Name"
   unlock screen
end mouseUp

on mouseDoubleUp
  mouseUp
end mouseDoubleUp
