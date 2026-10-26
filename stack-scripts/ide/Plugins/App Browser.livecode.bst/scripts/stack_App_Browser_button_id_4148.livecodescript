script "stack_App_Browser_button_id_4148"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "VideoClips" (id 1581) > button "Videoclip tabs popup" (id 4148)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pWhich
  lock screen
  put revSelvideoIDs(the hilitedLines of fld "videoclips") into tSelvideoIDs
  if pWhich is "Reset Columns" then
    set the cvideoclipTabs of grp "videoclip tabs" to 1,2,3,4,5
  else
    put the cvideoclipTabs of grp "videoclip tabs" into tvideoclipTabs
    put word 2 of the selectedLine of me into tLine
    if tLine < 4 then
      if (tLine + 2) is among the items of tvideoclipTabs
      then delete item itemOffset((tLine + 2), tvideoclipTabs) of tvideoclipTabs
      else put comma & (tLine + 2) after tvideoclipTabs
      sort items of tvideoclipTabs numeric
      set the cvideoclipTabs of grp "videoclip tabs" to tvideoclipTabs
    end if
  end if
  
  revUpdatevideoclips true, revvideoOffsets(tSelvideoIDs)  
  put the cLastTab of grp "Videoclip Tabs" into tTab
  set the rect of btn tTab of grp "Videoclip Tabs" to the topLeft of btn tTab of grp "Videoclip Tabs", \
      revLastTabRight(the long id of fld "videoclips"), \
      the bottom of btn tTab of grp "videoclip Tabs"
  unlock screen   
end menuPick
