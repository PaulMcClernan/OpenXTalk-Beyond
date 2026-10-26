script "stack_revMenuManager_button_id_4878"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Button Menus:" (id 3224) > button "Delete Menu" (id 4878)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  global gREVTextHeight
  if the cAnswerDialog of fld "Menu Name" or the cAnswerDialog of fld "Item Name" then exit mouseUp
  
  --delete button menu
  put the hilitedLine of fld "Menu Buttons" into tHilitedLine
  put the scroll of fld "Menu Buttons" into tScroll
  put the cREVMenuButtonIDs of this stack into tMenuButtonIDs
   
  answer warning "Are you sure you want to delete" && revMenuDescription() & "?" with "No" or "Yes"
  if it is not "Yes" then
    revCheckNameChanged
    pass mouseUp
  end if
  
  lock screen
  --delete menu button from menu group
  delete line tHilitedLine of fld "Menu Buttons"
  delete btn id (line tHilitedLine of tMenuButtonIDs) of bg id (the cREVMenuID of this stack) of stack (the cREVDefaultStack of this stack)
  delete line tHilitedLine of tMenuButtonIDs
  set the cREVMenuButtonIDs of this stack to tMenuButtonIDs
  if the num of lines in fld "Menu Buttons" >= tHilitedLine then
    set the hilitedLine of fld "Menu Buttons" to tHilitedLine
  else set the hilitedLine of fld "Menu Buttons" to (tHilitedLine -1)
  set the scroll of fld "Menu Buttons" to tScroll
  put the cREVLine of grp "Menu Insert" into tWidgetLine
  if tHilitedLine > tWidgetLine then
    set the cREVLine of grp "Menu Insert" to tWidgetLine - 1
    put the top of grp "Menu Insert" - gREVTextHeight into tNewTop
    if tNewTop > the top of fld "Menu Buttons" then set the top of grp "Menu Insert" to tNewTop
  end if
  revLayoutMenuButtons
  send "mouseUp" to fld "Menu Buttons"
  unlock screen
end mouseUp
