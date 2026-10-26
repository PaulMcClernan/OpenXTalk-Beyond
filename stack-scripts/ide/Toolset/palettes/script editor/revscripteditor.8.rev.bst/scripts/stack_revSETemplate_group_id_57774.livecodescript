script "stack_revSETemplate_group_id_57774"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSETemplate" > card "Templates" (id 2609) > group "Tree Template" (id 57774)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

################################################################################
# Variable Watcher Tree view object.
# This is not the same code as the simple tree view used in the dictionary and resource centre
################################################################################

################################################################################
# Public interface
################################################################################

constant kMargin = 2

local sBranches

local sCurrentDepth
local sLastBranch
local sHilitedBranchId
local sHilitedBranchLabel
local sBranchMap

private function branchTemplate
   return the cTemplateBranch of me
end branchTemplate

setProp cBranches pBranches
   put pBranches into sBranches
end cBranches

getProp cBranches
   return sBranches
end cBranches

local sRenderedBranchCount

getProp cLineCount
   return sRenderedBranchCount
end cLineCount

getProp cMaxLineCount
   local tMaxNumberOfVisibleLines
   put the height of me div (item 2 of branchSize()) into tMaxNumberOfVisibleLines
   return tMaxNumberOfVisibleLines
end cMaxLineCount

getProp cHilitedBranchId
   return sHilitedBranchId
end cHilitedBranchId

local sStartLine = 1

getProp cStartLine
   return sStartLine
end cStartLine

setProp cStartLine pValue
   put pValue into sStartLine
end cStartLine

command resize pDontUpdateBranches
   if there is a button "Vertical Splitter" of me then
      set the left of button "Vertical Splitter" of me to getVerticalSplit()
      set the height of button "Vertical Splitter" of me to the height of me
      set the top of button "Vertical Splitter" of me to the top of me
   end if
   
   local tGroup, tTop
   put the top of me + kMargin into tTop
   
   repeat with x = 1 to the number of groups of me
      put the long name of group x of me into tGroup
      if not the cBranch of tGroup then
         next repeat
      end if
      if pDontUpdateBranches is not "true" then
         set the rect of tGroup to the left of tGroup, tTop, the right of me, the bottom of tGroup
         add the height of tGroup to tTop
         call "resize" to tGroup
      end if
   end repeat
   updateScrollbar
end resize

--command updateExpansions
--   lock screen
   
--   local tHilitedBranchId
--   put sHilitedBranchId into tHilitedBranchId
   
--   local tPreviousVisibleBranch
--   local tLeft, tTop, tVisiblity, tBranch, tId, tExpanded, tBranchVisibility
--   repeat for each line tBranchDetail in sBranches
--      get urlDecode(tBranchDetail) 
--      put line 1 of it into tId
--      put line 3 of it into tExpanded
      
--      put branchReferenceFromId(tId) into tBranch
--      put getBranchLeft(the cDepth of tBranch) into tLeft
      
--      if tPreviousVisibleBranch is empty then
--         put kMargin + the top of me into tTop
--      else
--         put the top of tPreviousVisibleBranch + item 2 of branchSize() into tTop
--      end if
      
--      put getBranchVisibility(tBranch) into tBranchVisibility
      
--      set the cExpanded of tBranch to tExpanded
      
--      lock messages
--      set the topleft of tBranch to tLeft, tTop
--      set the visible of tBranch to tBranchVisibility
--      unlock messages
      
--      if tBranchVisibility then
--         put tBranch into tPreviousVisibleBranch
--      end if
--   end repeat
   
--   local tHilitedBranch
--   if tHilitedBranchId is not empty then
--      put branchReferenceFromId(tHilitedBranchId) into tHilitedBranch
--   end if
   
--   if there is a tHilitedBranch and the cParent of tHilitedBranch is not empty and the cExpanded of the cParent of tHilitedBranch is "false" then
--      branchHilite the cId of the cParent of tHilitedBranch
--   else if there is a tHilitedBranch then
--      branchHilite tHilitedBranchId
--   end if
   
--   updateScrollbar
--   unlock screen
--end updateExpansions

command update
   local tHilitedBranchId
   put sHilitedBranchId into tHilitedBranchId
   
   local tHilitedBranchLabel
   put sHilitedBranchLabel into tHilitedBranchLabel
   
   lock screen
   clearBranches
   delete variable sBranchMap
   
   local tFirstBranch
   put empty into tFirstBranch
   
   put 0 into sRenderedBranchCount
      
   local tHilitedBranch, tResult
   local tDepth, tExpanded, tLabel, tIcon, tId, tInfo, tLeaf
   
   local tMaxNumberOfVisibleLines
   put the height of me div (item 2 of branchSize()) into tMaxNumberOfVisibleLines
   
   local tLastVisibleLine
   put the cStartLine of me + tMaxNumberOfVisibleLines into tLastVisibleLine
   
   repeat with x = the cStartLine of me to tLastVisibleLine
      get fetchNode(x)
      if it is empty then
         exit repeat
      end if
      put line 1 of it into tId
      put line 2 of it into tDepth
      put line 3 of it into tExpanded
      put line 4 of it into tLabel
      put line 5 of it into tIcon
      put line 6 of it into tLeaf
      put line 7 to -1 of it into tInfo
      addBranch tId, tDepth, tLabel, tIcon, tExpanded, tInfo, tLeaf
      put the result into tResult
      if tFirstBranch is empty then
         put tResult into tFirstBranch
      end if
      
      if tId is tHilitedBranchId and tLabel is tHilitedBranchLabel and tResult is not empty then
         put the long id of tResult into tHilitedBranch
      end if
   end repeat
   
   # OK-2008-07-22 : Bug 6713
   # Must lock messages here, because this command is triggered by the Debugger, and if messages
   # are not locked, the newButton message will be handled in revBackscript, which does a send in time,
   # this results in the default stack changing and user code not working the same in the debugger.
   lock messages
   if there is a button "Vertical Splitter" of me then
      delete button "Vertical Splitter" of me
   end if
   copy button "Vertical Splitter" of card "Templates" of stack "revSETemplate" to me
   unlock messages
   
   set the height of button "Vertical Splitter" of me to the height of me
   set the top of button "Vertical Splitter" of me to the top of me
   set the left of button "Vertical Splitter" of me to getVerticalSplit()
   
   unlock screen
   
   if there is a tHilitedBranch and the cParent of tHilitedBranch is not empty and the cExpanded of the cParent of tHilitedBranch is "false" then
      branchHilite the cId of the cParent of tHilitedBranch
   else if there is a tHilitedBranch then
      branchHilite the cId of tHilitedBranch
   end if
   
   if tFirstBranch is not empty then
      set the cInitial of tFirstBranch to true
   end if
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
   set the vScrollbar of me to false
end updateScrollbar

private function getBranchLeft pDepth
   return kMargin + the left of me + (pDepth * branchIndent())
end getBranchLeft

--private function getBranchVisibility pBranch
--   local tParent, tParentContracted
--   put false into tParentContracted
--   put the cParent of pBranch into tParent

--   repeat until tParent is empty
--      if the cExpanded of tParent is not true then
--         put true into tParentContracted
--         exit repeat
--      end if
--      put the cParent of tParent into tParent
--   end repeat

--   return (not tParentContracted)
--end getBranchVisibility

--private function getBranchVisibilityFromId pBranchId
--   local tParentDetails, tParentContracted
--   put false into tParentContracted

--   put branchGetParentDetails(pBranchId) into tParentDetails

--   repeat until tParentDetails is empty
--      if line 3 of tParentDetails is not "true" then
--         put true into tParentContracted
--         exit repeat
--      end if
--      put branchGetParentDetails(line 1 of tParentDetails) into tParentDetails
--   end repeat

--   return (not tParentContracted)
--end getBranchVisibilityFromId

--private function branchGetParentDetails pBranchId
--   local tLineNumber
--   put lineOffset(urlEncode(pBranchId), sBranches) into tLineNumber

--   local tBranchDepth
--   get urlDecode(line tLineNumber of sBranches)
--   put line 2 of it into tBranchDepth

--   # If the branch is the first in the tree (or doesnt appear at all) it can't have a parent.
--   if tLineNumber < 2 then
--      return empty
--   end if

--   local tHigherBranches
--   put line 1 to (tLineNumber - 1) of sBranches into tHigherBranches

--   local tParentDepth, tId
--   repeat with x = the number of lines of tHigherBranches down to 1
--      get urlDecode(line x of tHigherBranches)
--      put line 2 of it into tParentDepth
--      put line 1 of it into tId
--      if tParentDepth < tBranchDepth then
--         return it
--      end if
--   end repeat

--   return empty
--end branchGetParentDetails

private command addBranch pId, pDepth, pLabel, pIcon, pExpanded, pInfo, pLeaf   
   local tBranchSize
   put branchSize() into tBranchSize
   
   local tLeft, tTop
   put getBranchLeft(pDepth) into tLeft
   
   if there is a sLastBranch then
      put the top of sLastBranch + item 2 of tBranchSize into tTop
   else
      put kMargin + the top of me into tTop
   end if
   
   local tBranch
   put branchCreate(branchCreateName(), tLeft, tTop, pLabel, pIcon) into tBranch
   set the cLeaf of tBranch to true
   set the cExpanded of tBranch to pExpanded
   set the cFinal of tBranch to true
   set the cDepth of tBranch to pDepth
   set the cId of tBranch to pId
   set the cLeaf of tBranch to pLeaf
   if the cLeaf of tBranch then
      set the cValue of tBranch to pInfo
   end if
   
   set the cInfo of tBranch to pInfo
   call "resize" to tBranch
   
   put the long id of tBranch into sBranchMap[pId]
   put tBranch into sLastBranch
   put pDepth into sCurrentDepth
   
   add 1 to sRenderedBranchCount
   return the long id of tBranch
end addBranch

--private function branchComputeParent pBranch, pDepth
--   local tBranches
--   put sBranches into tBranches
   
--   local tLineNumber
--   put lineOffset(urlEncode(the cId of pBranch), tBranches) into tLineNumber
   
--   if tLineNumber < 2 then
--      return empty
--   end if
   
--   put line 1 to (tLineNumber - 1) of tBranches into tBranches
   
--   local tDepth, tId
--   repeat with x = the number of lines of tBranches down to 1
--      get urlDecode(line x of tBranches)
--      put line 2 of it into tDepth
--      put line 1 of it into tId
--      if tDepth < pDepth then
--         return branchReferenceFromId(tId)
--      end if
--   end repeat
   
--   return empty
--end branchComputeParent

private function branchReferenceFromId pId
   return sBranchMap[pId]
   --  repeat with x = 1 to the number of groups of me
   --    if the cId of group x of me is pId then
   --      return the long id of group x of me
   --    end if
   --  end repeat
end branchReferenceFromId

--private function linkCreate pLeft, pTop, pBottom
--   local tLink
--   copy linkTemplate() to me
--   put the long id of it into tLink
--   set the cLinkLine of tLink to true
--   set the name of tLink to "Link"
--   set the height of tLink to (pBottom - pTop)
--   set the top of tlink to pTop
--   set the left of tLink to pLeft
--   return the long id of tLink
--end linkCreate

private command clearBranches
   lock messages
   repeat with x = the number of groups of me down to 1
      if the cBranch of group x of me then
         delete group x of me
      end if
   end repeat
   unlock messages
   
   put empty into sLastBranch
   put empty into sCurrentDepth
   put empty into sHilitedBranchId
   put empty into  sHilitedBranchLabel
end clearBranches

private function branchSize
   return the width of branchTemplate() & comma & the height of branchTemplate()
end branchSize

private function branchIndent
   return 20
end branchIndent

private function branchCreateName
   local tName
   repeat 32
      put any char of "abcdefghijklmnopqrstuvwxyz01234567890" after tName
   end repeat
   return tName
end branchCreateName

private function branchCreateId pBranchDetails
   # The branch id is created from its depth, label, icon and info. The combination of these things must be unique
   # or the tree will not work as expected.
   return base64Encode(md5digest(line 1 of pBranchDetails & line 3 of pBranchDetails & line 4 of pBranchDetails & line 5 of pBranchDetails))
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
   
   set the rect of tBranch to pLeft, pTop, the right of me, pTop + the height of tBranch
   set the cantDelete of tBranch to false
   
   return tBranch
end branchCreate

private command branchUpdateExpansion pBranch, pValue
   if pValue is not among the items of "true,false" then
      error "Invalid expansion valid, expected Boolean, got: " & pValue
   end if
   
   local tId
   put the cId of pBranch into tId
   
--   local tEncodedId
--   put urlEncode(tId) into tEncodedId
   
--   local tLineNumber
--   put lineOffset(tEncodedId, sBranches) into tLineNumber
--   if tLineNumber is 0 then
--      error "Can't locate branch id : " & tId
--   end if
   
   --   local tBranchDetails
   --   put urlDecode(line tLineNumber of sBranches) into tBranchDetails
   --   put pValue into line 3 of tBranchDetails
   --   put urlEncode(tBranchDetails) into line tLineNumber of sBranches
   --   updateExpansions
   
   # In the variable watcher, nodes whose parent is contracted are not rendered, their details are not in sBranches,
   # so in order to expand a node, we need to rebuild the tree completely.
   if pValue then
      nodeExpand tId
   else
      nodeContract tId
   end if
end branchUpdateExpansion

private command branchExpand pBranch
   branchUpdateExpansion pBranch, true
end branchExpand

private command branchContract pBranch
   branchUpdateExpansion pBranch, false
end branchContract

command branchUnhiliteAll
   local tBranch
   repeat with x = 1 to the number of groups of me
      if the cBranch of group x of me then
         put the long id of group x of me into tBranch
         if the visible of tBranch then
            branchUnhilite the cId of tBranch
         else
            send "branchUnhilite tBranch" to me in 0 milliseconds
         end if
      end if
   end repeat
end branchUnhiliteAll

command branchHilite pBranchId
   local tBranch
   put branchReferenceFromId(pBranchId) into tBranch
   set the cHilite of tBranch to true
   put pBranchId into sHilitedBranchId
   put the cLabel of tBranch into sHilitedBranchLabel
end branchHilite

private command branchUnhilite pBranchId
   local tBranch
   put branchReferenceFromId(pBranchId) into tBranch
   set the cHilite of tBranch to false
end branchUnhilite

--private command branchUpdateHilite pBranch, pValue
--   if pValue is not among the items of "true,false" then
--      error "Invalid hilite value, expected Boolean, got: " & pValue
--   end if
   
--   if pValue then
--      branchHilite the cId of pBranch
--   else
--      branchUnhilite the cId of pBranch
--   end if
--end branchUpdateHilite

private command branchVisualize pBranchId
   nodeVisualize pBranchId
end branchVisualize

on mouseUp
   local tBranch
   branchFromTarget the long id of the target
   put the result into tBranch
   
   if the short name of the target is "Visualize" then
      branchVisualize the cId of tBranch
      exit mouseUp
   end if
   
   local tId
   put the cId of tBranch into tId
   
   # Don't pass mouseUp if the user clicked on an expander, because expanding
   # and contracting nodes deletes the object that was clicked on, meaning that 
   # parent objects cannot access the target of the mouse click.
   if the short name of the target is "Expander" and the cExpanded of tBranch then
      branchContract tBranch
      exit mouseUp
   else if the short name of the target is "Expander" and not the cExpanded of tBranch then
      branchExpand tBranch
      exit mouseUp
   end if
   
   branchUnhiliteAll
   branchHilite tId
   
   pass mouseUp
end mouseUp

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

--command getTreeState
--   -- returns current state of the tree
--   local tState
--   if sHilitedBranchId is not empty then
--      put sHilitedBranchId into tState
--   else
--      put empty into tState
--   end if
--   put return after tState
   
   
--   repeat with x = 1 to the number of controls of me
--      if not the cBranch of control x of me then
--         next repeat
--      end if
      
--      put the cId of control x of me & tab & the cExpanded of control x of me & return after tState
--   end repeat
--   delete the last char of tState
--   return tState
--end getTreeState

--command setTreeState pState
--   local tStateArray
--   put pState into tStateArray
--   split tStateArray with return and tab
   
--   local tBranch
--   repeat with x = 1 to the number of controls of me
--      if not the cBranch of control x of me then 
--         next repeat
--      end if
--      put the long id of control x of me into tBranch
--      if the cExpanded of tBranch is not tStateArray[the cId of tBranch] then
--         branchUpdateExpansion tBranch, tStateArray[the cId of tBranch]
--      end if
--   end repeat
   
--   local tHighlightBranch
--   if line 1 of pState is not empty then
--      --put branchReferenceFromId (line 1 of pState) into tHighlightBranch
--      branchHilite line 1 of pState
--      setFilter (the cInfo of tHighlightBranch)
--   end if
--end setTreeState
