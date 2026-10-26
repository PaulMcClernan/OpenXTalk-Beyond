script "stack_revMenuManager_group_id_4839"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menu Items:" (id 3226) > group "Foldout Triangles" (id 4839)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  global gREVMMMenuItems, gREVTextHeight, gREVActiveMenuButton
  
  put the long id of the target into tTarget
  if the owner of tTarget is not me or the cAnswerDialog of fld "Menu Name" \
      or the cAnswerDialog of fld "Item Name" then exit mouseUp
  
  revCheckNameChanged
  
  set the hilite of tTarget to (not the hilite of tTarget)
  put the scroll of fld "Menu Items" into tScroll
  put the hilitedLines of fld "Menu Items" into tHilitedLines
  put empty into tNewHilitedLines
  put round(tScroll/gREVTextHeight) into tLine
  put the layer of tTarget - the layer of me into tButtonNum
  put tButtonNum + tLine into tLine
  put item 3 of line tLine of gREVMMMenuItems into tButtonContentsLine
  put the text of gREVActiveMenuButton into tText
  if comma is in the effective textFont of gREVActiveMenuButton then
    put true into tUnicode
    put uniEncode(cr) into tCr
  else put cr into tCr
  replace tCr with cr in tText
  replace comma with "#####REVCOMMA#####" in tText
  if the hilite of tTarget then
    --fold out triangles
    put true into item 1 of line tLine of gREVMMMenuItems
    put empty into tSubmenuItemDetails
    --find next menu item which isn't a submenu item
    repeat
      add 1 to tButtonContentsLine
      put line tButtonContentsLine of tText into tMenuItem
      if tab is not in tMenuItem then exit repeat
      else put (empty, tMenuItem, tButtonContentsLine & cr) after tSubmenuItemDetails
    end repeat
    put tSubmenuItemDetails before line (tLine + 1) of gREVMMMenuItems
    if the last char of gREVMMMenuItems is cr then delete the last char of gREVMMMenuItems
    --updated hilitedLines
    put the num of lines in tSubmenuItemDetails into tNumLines
    repeat for each item i in tHilitedLines
      if i > tLine then put (i + tNumLines) & comma after tNewHilitedLines
      else put i & comma after tNewHilitedLines
    end repeat
    delete last char of tNewHilitedLines
  else
    --fold in triangles
    put false into item 1 of line tLine of gREVMMMenuItems
    put empty into tSubmenuItemDetails
    put the num of lines in gREVMMMenuItems into tNumLines
    add 1 to tLine
    put tLine into tFinishLine
    put line tLine to tNumLines of gREVMMMenuItems into tMenuItems
    put empty into tCounter
    --find next menu item which isn't a submenu item
    repeat for each line l in tMenuItems
      if tab is not in l then exit repeat
      else add 1 to tFinishLine
    end repeat
    delete line tLine to (tFinishLine -1) of gREVMMMenuItems
    --update hilitedLines
    put tFinishLine - tLine into tNumLines
    repeat for each item i in tHilitedLines
      --if one of the submenus to be folded in was hilited then don't update hilitedLines for it
      if i >= tLine and i < tFinishLine then next repeat
      if i > tLine then
        put (i - tNumLines) & comma after tNewHilitedLines
      else put i & comma after tNewHilitedLines
    end repeat
    delete last char of tNewHilitedLines
  end if
   
  lock screen
  revUpdateField tUnicode
   
  set the hilitedLines of fld "Menu Items" to tNewHilitedLines
  set the scroll of fld "Menu Items" to tScroll
  put the num of lines in fld "Menu Items" into tNumLines
  if the cREVLine of grp "Item Insert" > tNumLines then    
    set the cREVLine of grp "Item Insert" to tNumLines
    set the top of grp "Item Insert" to the formattedTop of line tNumLines of fld "Menu Items" + 7
  end if
  revResetTriangles
  revUpdateScrollbar
  if tNewHilitedLines is empty 
  then revInitialiseForNoItemSelection
  else
    send "revSetEnabled" to fld "Menu Items"
    send "revSetHilite" to fld "Menu Items"
  end if
  unlock screen
end mouseUp
