script "stack_revMenuManager_button_id_4898"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menubar" (id 3260) > button "Delete" (id 4898)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if the cAnswerDialog of fld "Menu Name" or the cAnswerDialog of fld "Item Name" then exit mouseUp
  revCheckNameChanged
  beep
  answer warning "Are you sure you want to permanently delete Menu Bar" \
      &&quote& the cREVMenuBar of this stack &quote& "?" with "No" or "Yes"
  if it is not "Yes" 
  then exit mouseUp
  put the cREVDefaultStack of this stack into tStack
  delete bg id (the cREVMenuID of this stack) of stack tStack
  put the number of controls in stack tStack into tNumControls
  if tNumControls is not 0
  then answer question "Do you want to move the remaining" && tNumControls \
      && "objects up and reduce the stack height?" with "No" or "Yes"
else answer question "Do you want to reduce the stack height?" with "No" or "Yes"
if it is "Yes" then
  lock screen
  set the defaultStack to tStack
  if tNumControls is not 0 then
    repeat with i = 1 to tNumControls
      if word 1 of the owner of control i is not "group"
      then set the top of control i to the top of control i - 22
    end repeat
  end if
  put the rect of this stack into tRect
  set the rect of this stack to item 1 to 3 of tRect,item 4 of tRect - 22
  unlock screen
  modeless "revMenuManager"
end if
end mouseUp
