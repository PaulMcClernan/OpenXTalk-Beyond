script "stack_revMenuManager_button_id_4875"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Button Menus:" (id 3224) > button "Move Menu Up" (id 4875)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  lock screen
  revCheckNameChanged
  --move selected menu button one up the list
  put the htmlText of fld "Menu Buttons" into tHtml
  put the cREVMenuButtonIds of this stack into tMenuButtonIds
  put the hilitedLine of fld "Menu Buttons" into tHilitedLine
  put line tHilitedLine of tHtml & cr before line (tHilitedLine - 1) of tHtml
  put line tHilitedLine of tMenuButtonIds & cr before line (tHilitedLine - 1) of tMenuButtonIds
  delete line (tHilitedLine + 1) of tHtml
  delete line (tHilitedLine + 1) of tMenuButtonIds
  set the htmlText of fld "Menu Buttons" to tHtml
  set the cREVMenuButtonIDs of this stack to tMenuButtonIds
  set the hilitedLine of fld "Menu Buttons" to (tHilitedLine - 1)
  if the hilitedLine of fld "Menu Buttons" is 1 then set the cREVDisabled of me to true
  set the cREVDisabled of btn "Move Menu Down" to false
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
