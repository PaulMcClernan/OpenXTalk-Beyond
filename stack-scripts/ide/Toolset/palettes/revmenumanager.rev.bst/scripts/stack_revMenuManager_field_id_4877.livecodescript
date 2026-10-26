script "stack_revMenuManager_field_id_4877"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Button Menus:" (id 3224) > field "Menu Name" (id 4877)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField
  revChangeMenuName
end closeField

on revChangeMenuName
  global gREVActiveMenuButton
  if the cAnswerDialog of me then exit revChangeMenuName
  
  put the hilitedLine of fld "Menu Buttons" into tHilitedLine
  put the scroll of fld "Menu Buttons" into tScroll
  put the cREVDefaultStack of this stack into tDefaultStack
  
  put false into tUnicode
  put the num of chars in the text of me into tNumChars
  repeat with i = 1 to tNumChars
    if comma is in the effective textFont of char i of me then
      put the effective textFont of char i of me into tTextFont
      put true into tUnicode
      exit repeat
    end if
  end repeat
  if tUnicode then
    lock screen
    put the unicodeText of me into tNewMenu
    set the unicodeText of line tHilitedLine of fld "Menu Buttons" to tNewMenu
    if comma is not in the effective textFont of gREVActiveMenuButton
    then set the text of gREVActiveMenuButton to uniencode(the text of gREVActiveMenuButton)
    set the textFont of gREVActiveMenuButton to tTextFont
    set the textFont of btn "Preview" to tTextFont
  else
     
    put the text of me into tText
    if tHilitedLine is the num of lines in fld "Menu Buttons" \
        and tText is not "Help" then
      set the cAnswerDialog of me to true
      answer warning "On Mac OS the last menu in the Menu Bar has to be the Help menu.  What would you like to do to the name of the last menu button?" \
          with "Change it anyway" or "Leave it as Help"
      if it is "Leave it as Help" then
        put "Help" into tNewMenu
      else
        put tText into tNewMenu
      end if
      set the cBroughtUpAnswerDialog of me to true
      set the cAnswerDialog of me to false
    else put tText into tNewMenu
     
    lock screen
    set the textFont of line tHilitedLine of fld "Menu Buttons" to empty
    put tNewMenu into line tHilitedLine of fld "Menu Buttons"
    set the textFont of gREVActiveMenuButton to empty
    set the textFont of btn "Preview" to empty
    set the name of gREVActiveMenuButton to tNewMenu
  end if
  put char (the mnemonic of gREVActiveMenuButton) of the label of gREVActiveMenuButton \
      into tMnemonic
  set the label of gREVActiveMenuButton to tNewMenu
  put offset(tMnemonic, tNewMenu) into tOffset
  set the mnemonic of gREVActiveMenuButton to tOffset
  if tOffset is not 0 then set the textStyle of char tOffset of line tHilitedLine \
      of fld "Menu Buttons" to "underline"
  set the hilitedLine of fld "Menu Buttons" to tHilitedLine
  set the scroll of fld "Menu Buttons" to tScroll
  revLayoutMenuButtons
  send "mouseUp" to fld "Menu Buttons"
  unlock screen
end revChangeMenuName

on returnInField
  lock screen
  revChangeMenuName
  select the text of me
  unlock screen
end returnInField

on enterInField
  returnInField
end enterInField
