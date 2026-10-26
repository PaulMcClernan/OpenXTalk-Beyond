script "stack_revResourceCenter_group_id_1034"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Textmenu:populatingwithcontent" (id 82654) > group (id 2127) > group "Tree" (id 1034)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sHilitedBranchId
constant kMargin = 2

local sBranches
local sCurrentDepth
local sLastBranch
local sBranchCount = 0
local sBranchMap
local sThumbPosition

private command branchHilite pBranch
   --if the cLeaf of pBranch is "true" then
   set the cHilite of pBranch to true
   put the cId of pBranch into sHilitedBranchId
   resizeHighlightBranch
   set the loc of image "highlightBranch" to (item 1 of the location of pBranch, item 2 of the location of pBranch + 4)
   set the left of image "highlightBranch" to 0
   --end if
end branchHilite

command resizeHighlightBranch
   local tTreeSplit
   put prefGet("treeSplit") into tTreeSplit
   set the width of image "highlightBranch" to tTreeSplit
end resizeHighlightBranch

private command branchUnhilite pBranch
  set the cHilite of pBranch to false
end branchUnhilite

private function branchTemplate
   return the long id of group "Template Branch" of stack "revResourceCenter"
end branchTemplate

private function linkTemplate
   return the long id of graphic "LinkingLine"
end linkTemplate


setProp cBranches pBranches
   local tProcessedBranches
   repeat for each line tBranch in pBranches
      put urlEncode(branchCreateId(urlDecode(tBranch)) & return & urlDecode(tBranch)) & return after tProcessedBranches
   end repeat
   delete the last char of tProcessedBranches
   
   put tProcessedBranches into sBranches
end cBranches

command resize
   set the rect of field "FilterList" to the left of me, the top of me + 1, the right of me, the bottom of me - 1
   set the width of image "highlightBranch" to the width of me
   set the left of image "highlightBranch" to the left of me
   updateScrollbar
end resize

command updateExpansions
   lock screen
   
   local tHilitedBranchId
   put sHilitedBranchId into tHilitedBranchId
   
   local tPreviousVisibleBranch
   local tLeft, tTop, tVisiblity, tBranch, tId, tExpanded, tBranchVisibility
   repeat for each line tBranchDetail in sBranches
      get urlDecode(tBranchDetail) 
      put line 1 of it into tId
      put line 3 of it into tExpanded
      
      put branchReferenceFromId(tId) into tBranch
      put getBranchLeft(the cDepth of tBranch) into tLeft
      
      if tPreviousVisibleBranch is empty then
         put kMargin + the top of me into tTop
      else
         put the top of tPreviousVisibleBranch + item 2 of branchSize() into tTop
      end if
      
      put getBranchVisibility(tBranch) into tBranchVisibility
      
      set the cExpanded of tBranch to tExpanded
      
      if tBranchVisibility then
         put tBranch into tPreviousVisibleBranch
      else 
         -- LG 2008-08-14
         -- Bug 6882
         put the right of me into tLeft
      end if
      
      
      lock messages
      set the topleft of tBranch to tLeft, tTop
      set the visible of tBranch to tBranchVisibility
      unlock messages
      
--      if tBranchVisibility then
--         put tBranch into tPreviousVisibleBranch
--      end if
   end repeat
   
   local tHilitedBranch
   if tHilitedBranchId is not empty then
      put branchReferenceFromId(tHilitedBranchId) into tHilitedBranch
   end if
   
   if there is a tHilitedBranch and the cParent of tHilitedBranch is not empty and the cExpanded of the cParent of tHilitedBranch is "false" then
      branchHilite the cParent of tHilitedBranch
   else if there is a tHilitedBranch then
      branchHilite tHilitedBranch
   end if
   
   updateScrollbar
   unlock screen
end updateExpansions

command update
   local tHilitedBranchId
   put sHilitedBranchId into tHilitedBranchId
   
   lock screen
   
   clearBranches
   
   local tFirstBranch
   put empty into tFirstBranch
   
   local tHilitedBranch, tResult
   local tDepth, tExpanded, tLabel, tIcon, tId, tInfo
   repeat for each line tBranch in sBranches
      get urlDecode(tBranch)
      put line 1 of it into tId
      put line 2 of it into tDepth
      put line 3 of it into tExpanded
      put line 4 of it into tLabel
      put line 5 of it into tIcon
      put line 6 of it into tInfo
      addBranch tId, tDepth, tLabel, tIcon, tExpanded, tInfo
      put the result into tResult
      if tFirstBranch is empty then
         put tResult into tFirstBranch
      end if
      if tId is tHilitedBranchId then
         put the long id of tResult into tHilitedBranch
      end if
   end repeat
   unlock screen
   
   if there is a tHilitedBranch and the cParent of tHilitedBranch is not empty and the cExpanded of the cParent of tHilitedBranch is "false" then
      branchHilite the cParent of tHilitedBranch
   else if there is a tHilitedBranch then
      branchHilite tHilitedBranch
   else
      -- LG 2008-07-11
      local tBranchDetails, tBranchLongID
      put urldecode(line 1 of sBranches) into tBranchDetails
      put branchReferenceFromId(line 1 of tBranchDetails) into tBranchLongID
      branchHilite tBranchLongID
      
   end if
   
   if tFirstBranch is not empty then
      set the cInitial of tFirstBranch to true
   end if
   
   linksUpdate
   
   updateScrollbar
end update

command branchFromTarget pTarget
   local tControl
   put the long id of pTarget into tControl
   repeat until the cBranch of tControl is true or the long id of tControl is the long id of me or word 1 of the name of tControl is "card"
      put the owner of tControl into tControl
   end repeat
   
   if the cBranch of tControl then
      return the long id of tControl
   else
      return empty
   end if
end branchFromTarget

private command updateScrollbar
   set the vScrollbar of me to (the formattedHeight of me > the height of me)
   if ((the vScrollbar of me is true) and (sThumbPosition is not empty)) then
      set the vScroll of me to sThumbPosition
   end if
end updateScrollbar

private function getBranchLeft pDepth
   return kMargin + the left of me + (pDepth * branchIndent())
end getBranchLeft

private function getBranchVisibility pBranch
   local tParent, tParentContracted
   put false into tParentContracted
   put the cParent of pBranch into tParent
   
   repeat until tParent is empty
      if the cExpanded of tParent is not true then
         put true into tParentContracted
         exit repeat
      end if
      put the cParent of tParent into tParent
   end repeat
   
   return (not tParentContracted)
end getBranchVisibility

private command addBranch pId, pDepth, pLabel, pIcon, pExpanded, pInfo
   if (pDepth > sCurrentDepth + 1) and sCurrentDepth <> 0 then
      error "Invalid depth"
   end if
   
   local tBranchSize
   put branchSize() into tBranchSize
   
   local tLeft, tTop
   put getBranchLeft(pDepth) into tLeft
   
   if there is a sLastBranch then
      put the top of sLastBranch + item 2 of tBranchSize into tTop
   else
      put kMargin + the top of me into tTop
   end if
   
   if there is a sLastBranch and pDepth > sCurrentDepth then
      set the cLeaf of sLastBranch to false
   end if
   
   if there is a sLastBranch and the cDepth of sLastBranch = pDepth then
      set the cFinal of sLastBranch to false
   end if
   
   local tBranch
   put branchCreate(branchCreateName(), tLeft, tTop, pLabel, pIcon) into tBranch
   set the cLeaf of tBranch to true
   set the cExpanded of tBranch to pExpanded
   set the cFinal of tBranch to true
   set the cDepth of tBranch to pDepth
   set the cId of tBranch to pId
   set the cParent of tBranch to branchComputeParent(tBranch, pDepth)
   set the cInfo of tBranch to pInfo
   put the long id of tBranch into sBranchMap[pId]
   
   if not getBranchVisibility(tBranch) then
      set the visible of tBranch to false
      put sLastBranch into sLastBranch
      put sCurrentDepth into sCurrentDepth
   else
      put tBranch into sLastBranch
      put pDepth into sCurrentDepth
   end if
   
   if the cParent of tBranch is not empty then
      set the cLeaf of the cParent of tBranch to false
   end if
   
   add 1 to sBranchCount
   
   return the long id of tBranch
end addBranch

private function branchComputeParent pBranch, pDepth
   local tBranches
   put sBranches into tBranches
   
   local tLineNumber
   put lineOffset(urlEncode(the cId of pBranch), tBranches) into tLineNumber
   
   if tLineNumber < 2 then
      return empty
   end if
   
   put line 1 to (tLineNumber - 1) of tBranches into tBranches
   
   local tDepth, tId
   repeat with x = the number of lines of tBranches down to 1
      get urlDecode(line x of tBranches)
      put line 2 of it into tDepth
      put line 1 of it into tId
      if tDepth < pDepth then
         return branchReferenceFromId(tId)
      end if
   end repeat
   
   return empty
end branchComputeParent

private function branchReferenceFromId pId
   return sBranchMap[pId]
end branchReferenceFromId

private command linksUpdate
   lock screen
   
   linksClear
   
   local tBranch
   repeat with tGroupNumber = 1 to the number of groups of me
      put the long id of group tGroupNumber of me into tBranch
      if not the cBranch of tBranch then
         next repeat
      end if
      
      if (the cExpanded of tBranch) and (not the cLeaf of tBranch) then
         local tConnectingBranch
         repeat with tConnectingGroupNumber = tGroupNumber + 1 to the number of groups of me
            put the long id of group tConnectingGroupNumber of me into tConnectingBranch
            if not the cBranch of tConnectingBranch then
               next repeat
            end if
            if the cDepth of tConnectingBranch = the cDepth of tBranch then
               get linkCreate(the cAxis of tBranch, the bottom of tBranch, the top of tConnectingBranch)
            end if
         end repeat
      end if
   end repeat
   
   unlock screen
end linksUpdate

private command linksClear
   repeat with x = the number of graphics of me down to 1
      if the cLinkLine of graphic x of me then
         delete graphic x of me
      end if
   end repeat
end linksClear

private function linkCreate pLeft, pTop, pBottom
   local tLink
   copy linkTemplate() to me
   put the long id of it into tLink
   set the cLinkLine of tLink to true
   set the name of tLink to "Link"
   set the height of tLink to (pBottom - pTop)
   set the top of tlink to pTop
   set the left of tLink to pLeft
   return the long id of tLink
end linkCreate

private command clearBranches
   repeat with x = the number of groups of me down to 1
      if the cBranch of group x of me then
         delete group x of me
      end if
   end repeat
   put empty into sLastBranch
   put empty into sCurrentDepth
   put empty into sBranchCount
   put empty into sHilitedBranchId
end clearBranches

private function branchSize
   return the width of branchTemplate() & comma & the height of branchTemplate()
end branchSize

private function branchIndent
   return 4
end branchIndent

private function branchCreateName
   local tName
   repeat 32
      put any char of "abcdefghijklmnopqrstuvwxyz01234567890" after tName
   end repeat
   return tName
end branchCreateName

private function branchCreateId pBranchDetails
   return base64Encode(md5digest(line 3 of pBranchDetails & line 4 of pBranchDetails & line 5 of pBranchDetails))
end branchCreateId

private function branchCreate pName, pLeft, pTop, pLabel, pIcon
   lock messages
   copy branchTemplate() to me
   set the name of it to pName
   unlock messages
   local tBranch
   put the long id of control pName of me into tBranch
   
   set the cBranch of tBranch to true
   set the cLabel of tBranch to pLabel
   set the cIcon of tBranch to pIcon
   set the left of tBranch to pLeft
   set the top of tBranch to pTop
   set the cantDelete of tBranch to false
   
   
   return tBranch
end branchCreate

private command branchUpdateExpansion pBranch, pValue
   if pValue is empty then
      put false into pValue
   end if
   
   if pValue is not among the items of "true,false" then
      error "Invalid expansion valid, expected Boolean, got: " & pValue
   end if
   
   local tId
   put the cId of pBranch into tId
   
   local tEncodedId
   put urlEncode(tId) into tEncodedId
   
   local tLineNumber
   put lineOffset(tEncodedId, sBranches) into tLineNumber
   if tLineNumber is 0 then
      error "Can't locate branch id : " & tId
   end if
   
   local tBranchDetails
   put urlDecode(line tLineNumber of sBranches) into tBranchDetails
   put pValue into line 3 of tBranchDetails
   put urlEncode(tBranchDetails) into line tLineNumber of sBranches
   updateExpansions
end branchUpdateExpansion

private command branchExpand pBranch
   branchUpdateExpansion pBranch, true
end branchExpand

private command branchContract pBranch
   branchUpdateExpansion pBranch, false
end branchContract

private command branchUnhiliteAll
   local tBranch
   repeat with x = 1 to the number of groups of me
      if the cBranch of group x of me then
         put the long id of group x of me into tBranch
         if the visible of tBranch then
            branchUnhilite tBranch
         else
            send "branchUnhilite tBranch" to me in 0 milliseconds
         end if
      end if
   end repeat
end branchUnhiliteAll

private command branchUpdateHilite pBranch, pValue
   if pValue is not among the items of "true,false" then
      error "Invalid hilite value, expected Boolean, got: " & pValue
   end if
   
   if pValue then
      branchHilite pBranch
   else
      branchUnhilite pBranch
   end if
end branchUpdateHilite


on mouseUp
   lock screen
   put the vScroll of me into sThumbPosition
   
   local tBranch
   branchFromTarget the long id of the target
   put the result into tBranch
   
   if the short name of the target is "Expander" and the cExpanded of tBranch then
      branchContract tBranch
   else if the short name of the target is "Expander" and not the cExpanded of tBranch then
      branchExpand tBranch
   end if
   
   branchUnhiliteAll
   branchHilite tBranch
   
   local tCurrentTree
   getTreeState
   put the result into tCurrentTree
   if tCurrentTree is not empty then
      prefSet "resourceTree", tCurrentTree
      prefSave
   end if
   
   
   unlock screen
   pass mouseUp
end mouseUp

on emptyQuickSearch
   --LG 2008-06-17
   put empty into field "Search Text" of group "Search"
end emptyQuickSearch

on mouseDoubleUp
   local tBranch
   branchFromTarget the long id of the target
   put the result into tBranch
   
   if the short name of the target is not "Expander" and the cExpanded of tBranch then
      branchContract tBranch
      pass mouseDoubleUp
   end if
   
   if the short name of the target is not "Expander" and not the cExpanded of tBranch then
      branchExpand tBranch
      pass mouseDoubleUp
   end if
end mouseDoubleUp

command getTreeState
   local tState
   if sHilitedBranchId is not empty then
      put sHilitedBranchId into tState
   else
      put empty into tState
   end if
   put return after tState
   
   
   repeat with x = 1 to the number of controls of me
      if not the cBranch of control x of me then
         next repeat
      end if
      
      put the cId of control x of me & tab & the cExpanded of control x of me & return after tState
   end repeat
   delete the last char of tState
   return tState
end getTreeState

command setTreeState pState
   local tStateArray
   put pState into tStateArray
   split tStateArray with return and tab
   
   local tBranch
   repeat with x = 1 to the number of controls of me
      if not the cBranch of control x of me then 
         next repeat
      end if
      put the long id of control x of me into tBranch
      if the cExpanded of tBranch is not tStateArray[the cId of tBranch] then
         branchUpdateExpansion tBranch, tStateArray[the cId of tBranch]
      end if
   end repeat
   
   local tHighlightBranch
   if line 1 of pState is not empty then
      put branchReferenceFromId (line 1 of pState) into tHighlightBranch
      branchHilite tHighlightBranch
   end if
end setTreeState
