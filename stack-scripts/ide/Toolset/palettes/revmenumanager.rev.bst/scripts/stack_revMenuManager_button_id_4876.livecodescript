script "stack_revMenuManager_button_id_4876"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Button Menus:" (id 3224) > button "Move Menu Down" (id 4876)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  --move selected menu down one in the list
  put the hilitedLine of fld "Menu Buttons" into tHilitedLine
  if tHilitedLine is the num of lines in fld "Menu Buttons" then pass mouseUp
  lock screen
  revCheckNameChanged
  put the htmlText of fld "Menu Buttons" into tHtml
  put the cREVMenuButtonIds of this stack into tMenuButtonIds
  put cr & line tHilitedLine of tHtml after line (tHilitedLine + 1) of tHtml
  put cr & line tHilitedLine of tMenuButtonIds after line (tHilitedLine + 1) of tMenuButtonIds
  delete line tHilitedLine of tHtml
  delete line tHilitedLine of tMenuButtonIds
  set the htmlText of fld "Menu Buttons" to tHtml
  set the cREVMenuButtonIDs of this stack to tMenuButtonIds
  set the hilitedLine of fld "Menu Buttons" to (tHilitedLine + 1)
  if the hilitedLine of fld "Menu Buttons" is the num of lines in fld "Menu Buttons"
  then set the cREVDisabled of me to true
  set the cREVDisabled of btn "Move Menu Up" to false
  revLayoutMenuButtons
  unlock screen
  pass mouseUp
end mouseUp

setProp cREVDisabled pDisabled
  if pDisabled then
    disable me
  else
    enable me
  end if
end cREVDisabled
