script "stack_App_Browser_button_id_1623"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Audioclips" (id 1580) > button "Audioclip tabs popup" (id 1623)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pWhich
  lock screen
  put revSelAudioIDs(the hilitedLines of fld "Audioclips") into tSelAudioIDs
  if pWhich is "Reset Columns" then
    set the caudioclipTabs of grp "audioclip tabs" to 1,2,3,4,5
  else
    put the caudioclipTabs of grp "audioclip tabs" into taudioclipTabs
    put word 2 of the selectedLine of me into tLine
    if tLine < 4 then
      if (tLine + 2) is among the items of taudioclipTabs
      then delete item itemOffset((tLine + 2), taudioclipTabs) of taudioclipTabs
      else put comma & (tLine + 2) after taudioclipTabs
      sort items of taudioclipTabs numeric
      set the caudioclipTabs of grp "audioclip tabs" to taudioclipTabs
    end if
  end if
  revUpdateAudioclips true, revAudioOffsets(tSelAudioIDs)
  put the cLastTab of grp "Audioclip Tabs" into tTab
  set the rect of btn tTab of grp "Audioclip Tabs" to the topLeft of btn tTab of grp "Audioclip Tabs", \
      revLastTabRight(the long id of fld "Audioclips"), \
      the bottom of btn tTab of grp "Audioclip Tabs"
  unlock screen   
end menuPick
