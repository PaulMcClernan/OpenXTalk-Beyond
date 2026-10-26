script "stack_App_Browser_button_id_1198"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Cards and Controls" (id 1002) > button "Control tabs popup" (id 1198)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

constant kTabs="Type,Visible,Selectable,Layer,Control,ID,Script Lines"

on menuPick pWhich
  lock screen
  if pWhich is "Reset Columns" then
    set the cControlTabs of grp "control tabs" to 1,2,3,4,5,7
  else
    put the cControlTabs of grp "control tabs" into tControlTabs
    put itemOffset(pWhich,kTabs) into tOffset
    if tOffset is not 0 then
      put itemOffset(tOffset,tControlTabs) into tItemOffset
      if tItemOffset is not 0
      then delete item tItemOffset of tControlTabs
      else put comma & tOffset after tControlTabs
    end if
    sort items of tControlTabs numeric
    set the cControlTabs of grp "control tabs" to tControlTabs
  end if
  revUpdateControlsField true
  put the cLastTab of grp "Control Tabs" into tTab
  set the rect of btn tTab of grp "Control Tabs" to the topLeft of btn tTab of grp "Control Tabs", \
      revLastTabRight(the long id of fld "Controls"), \
      the bottom of btn tTab of grp "Control Tabs"
  unlock screen   
end menuPick
