script "stack_App_Browser_card_id_1581"
-- Stack file: ide/Plugins/App Browser.livecode
-- Object: stack "App Browser" > card "VideoClips" (id 1581)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

constant kComma="######REVCOMMA#####", kTabs="Num,Videoclip,ID,Script Lines,Size"

on revRefreshvideo pRetainSelection
  global gREVStackName, gREVvideoclips
  lock screen
  if the short name of this cd is not "videoclips" then exit revRefreshvideo
  if gREVStackName is empty then
    put empty into gREVvideoclips
    put empty into fld "videoclips"
  else
    put revSelvideoIDs(the hilitedLines of fld "videoclips") into tSelvideoIDs
    put revvideoclipList(gREVStackName) into gREVvideoclips
    revUpdatevideoclips pRetainSelection,revvideoOffsets(tSelvideoIDs)
  end if
  unlock screen
end revRefreshvideo

on revUpdatevideoclips pRetainSelection, pvideoOffsets
  global gREVvideoclips
  put the hScroll of fld "videoclips" into tHScroll
  put the vScroll of fld "videoclips" into tVScroll
  put revvideoclipsField(gREVvideoclips) into tHtml
  revSetHtml the long id of fld "videoclips", tHtml, \
      kTabs, the long id of grp "videoclip Tabs", the cVideoclipTabs of stack "revPreferences", \
      the left of btn "Num" of grp "videoclip Tabs"
  set the hScroll of fld "videoclips" to tHScroll
  if pRetainSelection then 
    set the hilitedLines of fld "videoclips" to pvideoOffsets
    set the vScroll of fld "videoclips" to tVScroll
  end if
end revUpdatevideoclips
  
function revvideoclipList pStack
  put the num of videoclips in stack pStack into tNumvideoclips
  put empty into tvideoclips
  repeat with i = 1 to tNumvideoclips
    put the short name of videoclip i of stack pStack into tName
    replace comma with kComma in tName
    try
      put the num of lines in the script of videoclip i of stack pStack into tScriptLines
    catch tError
      put "unknown" into tScriptLines
    end try
    put i, tName, the id of videoclip i of stack pStack, tScriptLines, \
        the size of videoclip i of stack pStack, \
        "#####REVID=", the id of videoclip i of stack pStack, \
        "=#####REVID" & cr after tvideoclips
  end repeat
  delete last char of tvideoclips
  
  put the cHilitedButton["videoclips"] of stack "revPreferences" into tTabNum
  if tTabNum is 4 or (item tTabNum of tvideoclips is a number and tTabNum is not 2)
  then sort lines of tvideoclips numeric by item tTabNum of each
  else sort lines of tvideoclips text by item tTabNum of each
  
  return tvideoclips
end revvideoclipList

function revvideoclipsField pvideoclips
  global gREVStackName
  put empty into tvideoclips
  put the cVideoclipTabs of stack "revPreferences" into tvideoclipTabs
  repeat for each line l in pvideoclips
    put "<p>" after tvideoclips
    repeat for each item i in tvideoclipTabs
      put item i of l & comma after tvideoclips
    end repeat
    delete last char of tvideoclips
    put "</p>" & cr after tvideoclips
  end repeat
  delete last char of tvideoclips
  replace tab with space&space in tvideoclips
  replace comma with tab in tvideoclips
  replace kComma with comma in tvideoclips
  return tvideoclips
end revvideoclipsField

on resizeStack
  put the hilitedLines of fld "videoclips" into tHilitedLines
  revUpdateGeometry
  set the hilitedLines of fld "videoclips" to tHilitedLines
  revSetVScrollbar the long id of fld "videoclips", the long id of grp "videoclip Tabs"
  put item (the last item of the cVideoclipTabs of stack "revPreferences") of kTabs into tTab
  set the rect of btn tTab of grp "videoclip Tabs" to the topLeft of btn tTab of grp "videoclip Tabs", \
      revLastTabRight(the long id of fld "videoclips"), the bottom of btn tTab of grp "videoclip Tabs"
  set the hScroll of grp "videoclip Tabs" to the hScroll of fld "videoclips"
  revResizeBrowser
end resizeStack

on revSetvideoclipsLeft
  put the hilitedLine of fld "videoclips" into tHilitedLine
  set the rect of fld "videoclips" to the right of btn "Resize", \
      the top of fld "videoclips", the bottomRight of fld "videoclips"
  set the hilitedLine of fld "videoclips" to tHilitedLine
  set the width of grp "videoclip Tabs" to the width of fld "videoclips"
  set the left of grp "videoclip Tabs" to the right of btn "Resize"
  set the left of fld "videoclip Info" to right of btn "Resize" - 1
end revSetvideoclipsLeft

function revSelvideoClips
  global gREVStackName, gREVvideoclips
  put empty into tvideoclips
  put the hilitedLines of fld "videoclips" into tLines
  repeat for each item i in tLines
    put item 1 of line i of gREVvideoclips into tNum
    put the long id of videoclip tNum of stack gREVStackName & cr after tvideoclips
  end repeat
  delete last char of tvideoclips
  return tvideoclips
end revSelvideoClips

function revSelvideoIDs pHilitedLines
  global gREVvideoclips
  put empty into tSelvideoIDs
  repeat for each item i in pHilitedLines
    put item 3 of line i of gREVvideoclips & comma after tSelvideoIDs
  end repeat
  delete last char of tSelvideoIDs
  return tSelvideoIDs
end revSelvideoIDs

function revvideoOffsets pIDs
  global gREVvideoclips
  put empty into tvideoOffsets
  repeat for each item i in pIDs
    put "#####REVID=",i,"=#####REVID" into tMatch
    put lineOffset(tMatch,gREVvideoclips) & comma after tvideoOffsets
  end repeat
  delete last char of tvideoOffsets
  return tvideoOffsets
end revvideoOffsets
