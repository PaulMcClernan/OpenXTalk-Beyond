script "stack_App_Browser_card_id_1580"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "Audioclips" (id 1580)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

constant kComma="######REVCOMMA#####", kTabs="Num,Audioclip,ID,Script Lines,Size"

on revRefreshAudio pRetainSelection
  global gREVStackName, gREVAudioclips
  lock screen
  if the short name of this cd is not "Audioclips" then exit revRefreshAudio
  if gREVStackName is empty then
    put empty into gREVAudioclips
    put empty into fld "Audioclips"
  else
    put revSelAudioIDs(the hilitedLines of fld "Audioclips") into tSelAudioIDs
    put revAudioclipList(gREVStackName) into gREVAudioclips
    revUpdateAudioclips pRetainSelection,revAudioOffsets(tSelAudioIDs)
  end if
  unlock screen
end revRefreshAudio

on revUpdateAudioclips pRetainSelection, pAudioOffsets
  global gREVAudioclips
  put the hScroll of fld "Audioclips" into tHScroll
  put the vScroll of fld "Audioclips" into tVScroll
  put revAudioclipsField(gREVAudioclips) into tHtml
  revSetHtml the long id of fld "Audioclips", tHtml, \
      kTabs, the long id of grp "Audioclip Tabs", the cAudioclipTabs of stack "revPreferences", \
      the left of btn "Num" of grp "Audioclip Tabs"
  set the hScroll of fld "Audioclips" to tHScroll
  if pRetainSelection then 
    set the hilitedLines of fld "Audioclips" to pAudioOffsets
    set the vScroll of fld "Audioclips" to tVScroll
  end if
end revUpdateAudioclips
  
function revAudioclipList pStack
  put the num of Audioclips in stack pStack into tNumAudioclips
  put empty into tAudioclips
  repeat with i = 1 to tNumAudioclips
    put the short name of Audioclip i of stack pStack into tName
    replace comma with kComma in tName
    try
      put the num of lines in the script of Audioclip i of stack pStack into tScriptLines
    catch tError
      put "unknown" into tScriptLines
    end try
    put i, tName, the id of Audioclip i of stack pStack, tScriptLines, \
        the size of Audioclip i of stack pStack, \
        "#####REVID=", the id of Audioclip i of stack pStack, \
        "=#####REVID" & cr after tAudioclips
  end repeat
  delete last char of tAudioclips
  
  put the cHilitedButton["audioclips"] of stack "revPreferences" into tTabNum
  if tTabNum is 4 or (item tTabNum of tAudioclips is a number and tTabNum is not 2)
  then sort lines of tAudioclips numeric by item tTabNum of each
  else sort lines of tAudioclips text by item tTabNum of each
  
  return tAudioclips
end revAudioclipList

function revAudioclipsField pAudioclips
  global gREVStackName
  put empty into tAudioclips
  put the cAudioclipTabs of stack "revPreferences" into tAudioclipTabs
  repeat for each line l in pAudioclips
    put "<p>" after tAudioclips
    repeat for each item i in tAudioclipTabs
      put item i of l & comma after tAudioclips
    end repeat
    delete last char of tAudioclips
    put "</p>" & cr after tAudioclips
  end repeat
  delete last char of tAudioclips
  replace tab with space&space in tAudioclips
  replace comma with tab in tAudioclips
  replace kComma with comma in tAudioclips
  return tAudioclips
end revAudioclipsField

on resizeStack
  put the hilitedLines of fld "Audioclips" into tHilitedLines
  revUpdateGeometry
  set the hilitedLines of fld "Audioclips" to tHilitedLines
  revSetVScrollbar the long id of fld "Audioclips", the long id of grp "Audioclip Tabs"
  put item (the last item of the cAudioclipTabs of stack "revPreferences") of kTabs into tTab
  set the rect of btn tTab of grp "Audioclip Tabs" to the topLeft of btn tTab of grp "Audioclip Tabs", \
      revLastTabRight(the long id of fld "Audioclips"), the bottom of btn tTab of grp "Audioclip Tabs"
  set the hScroll of grp "Audioclip Tabs" to the hScroll of fld "Audioclips"
  revResizeBrowser
end resizeStack

on revSetAudioclipsLeft
  put the hilitedLine of fld "Audioclips" into tHilitedLine
  set the rect of fld "Audioclips" to the right of btn "Resize", \
      the top of fld "Audioclips", the bottomRight of fld "Audioclips"
  set the hilitedLine of fld "Audioclips" to tHilitedLine
  set the width of grp "Audioclip Tabs" to the width of fld "Audioclips"
  set the left of grp "Audioclip Tabs" to the right of btn "Resize"
  set the left of fld "Audioclip Info" to right of btn "Resize" - 1
end revSetAudioclipsLeft

function revSelAudioClips
  global gREVStackName, gREVAudioclips
  put empty into tAudioclips
  put the hilitedLines of fld "Audioclips" into tLines
  repeat for each item i in tLines
    put item 1 of line i of gREVAudioclips into tNum
    put the long id of audioclip tNum of stack gREVStackName & cr after tAudioclips
  end repeat
  delete last char of tAudioclips
  return tAudioclips
end revSelAudioClips

function revSelAudioIDs pHilitedLines
  global gREVAudioclips
  put empty into tSelAudioIDs
  repeat for each item i in pHilitedLines
    put item 3 of line i of gREVAudioclips & comma after tSelAudioIDs
  end repeat
  delete last char of tSelAudioIDs
  return tSelAudioIDs
end revSelAudioIDs

function revAudioOffsets pIDs
  global gREVAudioclips
  put empty into tAudioOffsets
  repeat for each item i in pIDs
    put "#####REVID=",i,"=#####REVID" into tMatch
    put lineOffset(tMatch,gREVAudioclips) & comma after tAudioOffsets
  end repeat
  delete last char of tAudioOffsets
  return tAudioOffsets
end revAudioOffsets






























































