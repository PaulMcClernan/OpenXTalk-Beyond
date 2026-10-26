script "stack_revOnline_group_id_1691"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "search list" (id 1691)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


local sListOffset
local sCurrentList

local sListArray
local sObjectIndex
local sMode
local sCurrentItemNumber
--local sPageLimit
local sPercentage
local sProgressIncrement

command initialize
   clearObjects
   --put calculatePageLimit() into sPageLimit
end initialize

# NUmber of stacks to display on each page
getProp cPageLimit
   if sMode is "list" then
      return revOnlinePrefGet("stacksPerPage")
   else
      return calculateItemCapacity()
   end if
end cPageLimit

# Grid or list mode
setProp cMode pMode
   if pMode is not sMode then
      put pMode into sMode
      clearObjects
   end if
end cMode

getProp cMode
   return sMode
end cMode

# pList is an ordered array
setProp cList pList
   put pList into sListArray
   
   lock screen
   clearObjects
   updateList
   unlock screen
   # Calculate progressbar increment
   if the keys of pList is not empty then
      rvoDrawProgressBar 0, "Performing search ..."
      put 0 into sPercentage
      local tNumberOfRequests
      if revOnlinePrefGet("textOnlyMode") is true then
         put the number of elements of sListArray into tNumberOfRequests
      else
         put (the number of elements of sListArray) * 3 into tNumberOfRequests
         put (the number of elements of sListArray) * 2 into tNumberOfRequests
      end if
      put (100 / tNumberOfRequests) into sProgressIncrement 
   end if     
end cList

getProp cList
   return sListArray
end cList

command updateScrollbar
   local tId
   put the long id of me into tId
   set the cControl of group "search list scrollbar" of stack "revOnline" to tId
   send "update" to group "search list scrollbar" of stack "revOnline"
end updateScrollbar

command resizeMessageCatcher
   --if the number of groups of me is 0 then
   if sObjectIndex is empty then
      set the rect of graphic "message catcher" of me to \
      (the left of me, the top of me, the right of me, the top of me + 10)
   else
      set the rect of graphic "message catcher" of me to \
      (the left of me, the top of me, the right of me, the bottom of (line - 1 of sObjectIndex))
   end if
end resizeMessageCatcher

# Creates new list of preview groups
command updateList
   local tKeys
   put the keys of sListArray into tKeys
   sort tKeys numeric
   repeat for each line tKey in tKeys
      createListItem tKey
   end repeat   
   wrapObjects
   resizeMessageCatcher
   set the vscroll of me to 0
   updateScrollbar   
      
   # Need to fetch text data for each stack preview group
   repeat with x = 1 to (item 2 of line 1 of the extents of sListArray)
      updateListItemText sListArray[x]["id"]
   end repeat
end updateList

command createListItem pKey
   lock screen
   local tTemplateId, tCopyId
   --put the long id of group "template original" of card "templates" into tTemplateId
   put the long id of group "template new 2" of card "templates" into tTemplateId
   copy tTemplateId to me
   put the long id of it into tCopyId
   copy group "rater template" of card "templates" of this stack to tCopyId
   send "setCanRate false" to group "rater template" of tCopyId
   set the loc of group "rater template" of tCopyId to the loc of field "rating" of tCopyId
   set the cantdelete of group "rater template" of tCopyId to "false"
   set the name of tCopyId to "Object" && sListArray[pKey]["id"]
   put tCopyId & return after sObjectIndex   
   # For skinning purposes.  If list item number is even
   if the cMode of me is "list" then
      if (pKey/2) - (pKey div 2) <> 0 then
         set the opaque of tCopyId to true
      end if
   else
      set the opaque of tCopyId to true
   end if
   unlock screen
end createListItem

command clearObjects
   lock screen
   put empty into sObjectIndex
   repeat with x = the number of groups of me down to 1
      delete group x of me
   end repeat
   unlock screen
end clearObjects

command updateListItemText pId
   local tCallback
   put revCallbackCreate(the long id of me, "updateListItemTextCallback") into tCallback
   rvoFetchStackData pId, tCallback  
   rvoRegisterSearchRequest the result 
end updateListItemText

command updateListItemTextCallback pResult
   local tObjectName
   if the keys of pResult is not empty then
      put "Object" && pResult["id"] into tObjectName
      if there is a group tObjectName of me then
         lock screen
         ### Need to make sure this is a new object not one being updated due
         ### to a user setting the stack details in the viewing pane etc.
         if field "title" of group tObjectName of me is empty then
            # Put in a standard image depending on type 
            if pResult["type_name"] is "code snippet" then
               set the text of image "thumbnail" of group tObjectName to the cStandardCodeSnippetThumb of stack "revonline"
               set the text of image "type" of group tObjectName to the cStandardCodeSnippetIcon of stack "revonline"
            else if pResult["type_name"] is "external" then
               set the text of image "thumbnail" of group tObjectName to the cStandardExternalThumb of stack "revonline"
               set the text of image "type" of group tObjectName to the cStandardExternalIcon of stack "revonline"
            else
               set the text of image "type" of group tObjectName to the cStandardStackIcon of stack "revonline"
            end if
            add sProgressIncrement to sPercentage
            rvoDrawProgressBar sPercentage, "Performing search ..."
            # Check for text only mode preference
            if revOnlinePrefGet("textOnlyMode") is false then
               # If the icon data is not empty ie. user has uploaded a stack image
               if pResult["icon_size"] > 0 then
                  updateListItemThumbnail pResult["id"]
               else
                  add sProgressIncrement to sPercentage
                  rvoDrawProgressBar sPercentage, "Performing search ..."
               end if
            end if
         end if  
         put capitaliseChar1(pResult["title"]) into field "title" of group tObjectName of me
         set the cUserDisplayName of group tObjectName of me to pResult["display_name"]
         put pResult["display_name"] into field "author" of group tObjectName of me
         if the formattedwidth of field "author" of group tObjectName of me > the width of field "author" of group tObjectName of me then
            repeat until the formattedwidth of field "author" of group tObjectName of me < the width of field "author" of group tObjectName of me - 5
               delete char -1 of field "author" of group tObjectName of me 
            end repeat
            put "..." after field "author" of group tObjectName of me 
         end if
         local tSize
         put round((pResult["size"] / 1024),1) into tSize
         if tSize > 1000 then
            put "(" & round((pResult["size"] / 1048576),1) & "MB)" into field "size" of group tObjectName of me
         else
            put "(" & tSize & "KB)" into field "size" of group tObjectName of me
         end if
         put pResult["downloads"] into field "downloads" of group tObjectName of me
         local tRating
         put pResult["rating"] into tRating
         send "setRating tRating" to group "rater template" of group tObjectName of me
         # Tags
         put tab && space && space & space into field "tags" of group tObjectName of me
         repeat for each line tLine in pResult["top_tags"]
            put capitaliseChar1(tLine) after field "tags" of group tObjectName of me
            if (the formattedheight of field "tags" of group tObjectName of me - 5) > the height of field "tags" of group tObjectName of me then
               delete item -1 of field "tags" of group tObjectName of me
               put ", ..." after field "tags" of group tObjectName of me
               # Need to make sure the ... hasn't increased the formattedheight
               if (the formattedheight of field "tags" of group tObjectName of me - 5) > the height of field "tags" of group tObjectName of me then
                  delete item -1 of field "tags" of group tObjectName of me
                  delete item -1 of field "tags" of group tObjectName of me
                  put ", ..." after field "tags" of group tObjectName of me
               end if
               exit repeat
            end if
            put ", " after field "tags" of group tObjectName of me
         end repeat
         if char -1 of field "tags" of group tObjectName of me is not "." then
            delete char -2 to -1 of field "tags" of group tObjectName of me
         end if
         set the cStackId of group tObjectName of me to pResult["id"]
         set the cUserId of group tObjectName of me to pResult["user_id"]
         unlock screen
      end if
   end if
end updateListItemTextCallback

command updateListItemThumbnail pId
   local tCallback
   put revCallbackCreate(the long id of me, "updateListItemThumbnailCallback") into tCallback
   rvoFetchStackProperty pId, "thumbnail", tCallback
   rvoRegisterSearchRequest the result 
end updateListItemThumbnail


command updateListItemThumbnailCallback pResult
   local tStackId, tImageData
   put "object" && pResult["stack_id"] into tStackId
   if there is a group tStackId of me then
      put pResult["result"]["thumbnail"] into tImageData
      if tImageData is not empty then
         set the text of image "thumbnail" of group tStackId of me to tImageData
      end if
      add sProgressIncrement to sPercentage
      rvoDrawProgressBar sPercentage, "Performing search ..."
   end if   
end updateListItemThumbnailCallback

constant kSpacing = 0
constant kHSpacing = 16

# Aligns objects in best fit for the enclosing group size
command wrapObjects
   local tTop, tLeft
   if the vscroll of me is 0 then
      if the cMode of me is "list" then
         put the top of me into tTop
      else
         put the top of me + 6 into tTop
      end if
   else
      put the top of me - the vscroll of me into tTop
   end if
   if the cMode of me is "list" then
      put the left of me into tLeft
   else
      put the left of me + 16 into tLeft
   end if
   
   repeat for each line tObject in sObjectIndex
      set the visible of tObject to false
      if tLeft + (the width of tObject) < (the right of me) then
         set the topLeft of tObject to (tLeft,tTop)
      else
         if the cMode of me is "list" then
            put the left of me into tLeft
         else
            put the left of me + 16 into tLeft
         end if
         add the height of tObject + kSpacing to tTop
         set the topLeft of tObject to (tLeft,tTop)
      end if
      add the width of tObject + kHSpacing to tLeft
      if the bottom of tObject < the bottom of me and the cMode of me is "grid" then
         set the visible of tObject to true
      else if the cMode of me is "list" then
         set the visible of tObject to true
      end if
   end repeat   
end wrapObjects

local sPendingRequests

private command cancelPendingThumbnailRequests
   repeat for each line tRequest in sPendingRequests
      revOnlineQueueCancel tRequest
   end repeat
   put empty into sPendingRequests
end cancelPendingThumbnailRequests
local sUpdateListRequest

local sLastCapacity

command resize pUpdate
   wrapObjects
   if the cMode of me is "grid" then
      set the vScroll of me to 0
   end if      
   updateScrollbar
   # Only perform another search if in grid mode   
   if sMode is "grid" and pUpdate then
      if sUpdateListRequest is not empty then
         cancel sUpdateListRequest
      end if
      send "updateSearchListWrapper" to me in 10 milliseconds  
      put the result into sUpdateListRequest
   end if
   resizeMessageCatcher
end resize

# Wrapper to reduce number of unecessary updates, checks if capacity has changed
# since last update,
command updateSearchListWrapper
   local tCapacity
   put calculateItemCapacity() into tCapacity
   if tCapacity <> sLastCapacity then
      put tCapacity into sLastCapacity
      updateSearchList
   end if
end updateSearchListWrapper

--command calculatePageLimit
private function calculateItemCapacity
   local tWidth, tHeight
   put the width of me into tWidth
   put the height of me into tHeight
   
   local tObjWidth, tObjHeight
   put the width of group "template original" of card "templates" of stack "revOnline" + kHSpacing into tObjWidth
   put the height of group "template original" of card "templates" of stack "revOnline" into tObjHeight
   
   local tHLimit, tVLimit
   put trunc(tWidth / tObjWidth) into tHLimit 
   --put trunc(tHeight / tObjHeight) into tVLimit
   put trunc((tHeight - 16) / tObjHeight) into tVLimit
   
   local tPageLimit
   put tHLimit * tVLimit into tPageLimit
   return tPageLimit
end calculateItemCapacity

# Used to replace multiple instances of a users name ie when a user 
# updates their profile in the viewing pane
command updateListUserDetails pUser
   local tGroupId, tStackId, tArray, tKey
   repeat with x = 1 to the number of groups of me
      put the long id of group x of me into tGroupId
      if the cUserId of tGroupId is pUser then
         # Stack has been updated so must clear cache of its details
         put empty into tArray
         put the cStackId of tGroupId into tStackId
         put "fetchStackData" into tArray["action"]
         put tStackId into tArray["parameters"]["id"]
         put revOnlineEncodeArray(tArray) into tKey      
         revOnlineCacheRemove tKey
         updateListItemText tStackId
      end if      
   end repeat   
end updateListUserDetails

on rawkeydown pKey
   if pKey is 65308 then
      scrollUp
   else if pKey is 65309 then
      scrollDown
   else
      pass rawkeydown
   end if
end rawkeydown


command scrollUp
   local tScrollValue
   lock screen
   put round(the formattedheight of me / 20) into tScrollValue
   set the vScroll of me to (the vScroll of me + tScrollValue)
   updateScrollbar
   unlock screen
end scrollUp

command scrollDown
   local tScrollValue
   lock screen
   put round(the formattedheight of me / 20) into tScrollValue
   set the vScroll of me to (the vScroll of me - tScrollValue)
   updateScrollbar
   unlock screen
end scrollDown


