script "stack_App_Browser_button_id_1197"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Cards and Controls" (id 1002) > group "common menus" (id 1606) > button "Card Tabs Popup" (id 1197)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pWhich
  global gREVObjectTree
  lock screen
  put revSelLineID() into tLineID
  if pWhich is "Reset Columns" then
    set the cCardTabs of grp "Card tabs" to 6,7,9
  else
    put the cCardTabs of grp "Card tabs" into tCardTabs
    put word 2 of the selectedLine of me into tLine
    if tLine < 5 then
      if (tLine + 7) is among the items of tCardTabs
      then delete item itemOffset((tLine + 7), tCardTabs) of tCardTabs
      else put comma&(tLine + 7) after tCardTabs
      sort items of tCardTabs numeric
      set the cCardTabs of grp "Card tabs" to tCardTabs
    end if
  end if
  revUpdateTree revTreeHtml(gREVObjectTree), tLineID
  put the cLastTab of grp "Card Tabs" into tTab
  set the rect of btn tTab of grp "Card Tabs" to the topLeft of btn tTab of grp "Card Tabs", \
      revLastTabRight(the long id of fld "Cards" of grp "Cards"), the bottom of btn tTab of grp "Card Tabs"
  unlock screen   
end menuPick
