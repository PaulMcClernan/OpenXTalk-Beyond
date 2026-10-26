script "stack_revOnline_group_id_31860"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


local sStackId
local sUserId
local sStackImage
local sStackThumbnail
local sStackData
local sStackWidth
local sStackHeight
local sType
local sStackName
local sPaths
local sCode
local sTags
local sRating
local sStackLongId
local sHtml
constant kSpacing = 10

# Need to store tags seperately to deal with reducing the size of the field
getProp cTags
   return sTags
end cTags

setProp cTags pTags
   put pTags into sTags
end cTags

setProp cType pType
   if pType is "normal" then
      set the cType of group "edit controls" of stack "revonline" to "stack"
      put "normal" into sType
      put "Stack" into field "type" of me
      put "Update stack" into field "update" of group "edit stack" of me
      put "Delete stack" into field "delete" of group "edit stack" of me
      put "Permanently remove this stack from revOnline?" into field "confirm" of me
   else if pType is "code snippet" then
      set the cType of group "edit controls" of stack "revonline" to "code snippet"
      put "code snippet" into sType
      put "Code snippet" into field "type" of me
      put "Update code snippet" into field "update" of group "edit stack" of me
      put "Delete code snippet" into field "delete" of group "edit stack" of me
      put "Permanently remove this code snippet from revOnline?" into field "confirm" of me
   else if pType is "external" then
      set the cType of group "edit controls" of stack "revonline" to "external"
      put "external" into sType
      put "External" into field "type" of me
      put "Update external" into field "update" of group "edit stack" of me
      put "Delete external" into field "delete" of group "edit stack" of me
      put "Permanently remove this external from revOnline?" into field "confirm" of me
   end if
end cType

getProp cType
   return sType
end cType


## Temp hack not sure if this is right way to do it
getProp cAuthor
   return sUserId
end cAuthor

setProp cStack pStackId
   clearContents
   if pStackId is "new" then
      --put "new" into sStackId
      put empty into sStackId
      put empty into sStackData
      put empty into sStackWidth
      put empty into sStackHeight     
      showContentChooser
   else
      put pStackId into sStackId
      updateStackDetails
   end if
end cStack

getProp cStack
   return sStackId
end cStack

command updateStackDetails
   rvoUpdateTooltip "Retrieving stack details ..."
   # Need to perform this periodically
   updateWidgetTagsList
   
   local tCallback
   put revCallbackCreate(the long id of me, "updateStackDetailsCallback") into tCallback
   set the text of image "profile image" of me to empty
   set the text of image "stack image" of me to empty
   send "resize" to the owner of me
   # Passing prioritize parameter here
   rvoFetchStackData sStackId, tCallback, true
end updateStackDetails

command updateStackDetailsCallback pResult
   local tId
   put pResult["id"] into tId
   
   
   # OK-2009-02-06 : If tId is empty then it probably means that there was a stack id
   # loaded from the prefs which has now been deleted. In this case, we need to pick a random
   # one to display.
   if tId is empty then
      --put "%" after msg
      local tCallback
      put revCallbackCreate(the long id of stack "revOnline", "updateViewingPane") into tCallback
      revCallbackAddParameter tCallback, "stack"
      revOnlinePickRandomStack tCallback
      exit updateStackDetailsCallback
   end if
   
   # OK-2009-02-06 : Slight simplification
   if tId <> sStackId then
      exit updateStackDetailsCallback
   end if
   
   --lock screen
   set the cType of me to pResult["type_name"]
   put capitaliseChar1(pResult["title"]) into field "name" of me
   put pResult["display_name"] into field "author" of me
   put word 1 of pResult["modified_date"] into field "last updated" of me
   put pResult["downloads"] && "times" into field "downloads" of me
   put pResult["revision"] into field "revision" of me
   put pResult["platform"] into field "platforms" of me
   # Ratings widget
   send "setId tId" to group "rater template" of me  
   local tRating
   put pResult["rating"] into tRating
   send "setRating tRating" to group "rater template" of me  
   # Need to recall origianl rating if a non logged in user attempts to rate a stack
   put tRating into sRating
   
   local tSize, tFormattedSize
   put pResult["size"] into tSize
   
   put round((tSize / 1024),1) into tFormattedSize
   if tFormattedSize > 1000 then
      put "(" & round((tSize / 1048576),1) & "MB)" into field "download" of me    
   else
      put "(" & tFormattedSize & "KB)" into field "download" of me    
   end if   
   --put "(" & round((tSize / 1024),1) & "kb)" into field "download" of me
   
   put pResult["headline"] into field "headline" of me
   put pResult["description"] into field "description" of me
   put pResult["user_id"] into sUserId
   
   # Tags
   local tTags
   put tab & "     " into tTags
   repeat for each line tline in pResult["top_tags"]
      put capitaliseChar1(tLine) & ", " after tTags
   end repeat
   delete char -2 to -1 of tTags
   put tTags into sTags
   
   if sUserId is revOnlineId() then
      ###show group "edit stack" of me
      set the cEnabled of group "edit controls" of stack "revonline" to true
      put empty into sStackImage
      put empty into sStackThumbnail
      local tFalse
      put "false" into tFalse
      send "setCanRate tFalse" to group "rater template" of me
      set the text of field "AddTag" of me to "Add / Delete tags"
   else
      ###hide group "edit stack" of me
      set the cEnabled of group "edit controls" of stack "revonline" to empty
      local tTrue
      put "true" into tTrue
      send "setCanRate tTrue" to group "rater template" of me
      set the text of field "AddTag" of me to "Add tag"
   end if
   show button "tag" of me
   show field "addtag" of me
   show button "download" of me
   show field "name" of me
   
   send "resize" to the owner of me
   
   # If there is no icon data then don't perform query to retrieve icon
   if pResult["icon_size"] > 0 then
      if there is not an image "image loader small" of me and the text of image "stack image" of me is empty then
         copy image "image loader small" of card "templates" of this stack to me
      end if
      if there is an image "image loader small" of me then
         set the loc of image "image loader small" of me to the loc of image "profile image" of me
      end if
      
      if there is not an image "image loader" of me and the text of image "stack image" of me is empty then
         copy image "image loader" of card "templates" of this stack to me
      end if
      if there is an image "image loader" of me then
         set the loc of image "image loader" of me to the loc of image "stack image" of me
      end if
      updateStackImage
   else
      if there is an image "image loader" of me then
         delete image "image loader" of me
      end if
      if sType is "code snippet" then
         set the text of image "stack image" of me to the cStandardCodeSnippetImage of stack "revonline"
      else if sType is "external" then
         set the text of image "stack image" of me to the cStandardExternalImage of stack "revonline"
      else
         set the text of image "stack image" of me to the cStandardStackImage of stack "revonline"
      end if
      
      if there is not an image "image loader small" of me and the text of image "profile image" of me is empty then
         copy image "image loader small" of card "templates" of this stack to me
      end if
      
      if there is an image "image loader small" of me and there is an image "profile image" of me then
         set the loc of image "image loader small" of me to the loc of image "profile image" of me
      end if
      
      updateProfileImage
   end if
   unlock screen
end updateStackDetailsCallback

command updateStackImage
   rvoUpdateTooltip "Retrieving stack details ..."
   local tCallback
   put revCallbackCreate(the long id of me, "updateStackImageCallback") into tCallback
   rvoFetchStackProperty sStackId, "icon", tCallback, true
end updateStackImage

command updateStackImageCallback pResult pStackId
   # prevents problem with quick successive browsing, also reduces unecessary
   # calls to cgi script to fetch data no longer relevant
   if pResult["stack_id"] is sStackId then
      if there is an image "image loader" of me then
         delete image "image loader" of me
      end if
      set the text of image "stack image" of me to pResult["result"]["icon"]
      updateProfileImage
   end if
end updateStackImageCallback

command updateProfileImage
   rvoUpdateTooltip "Retrieving stack details ..."
   local tCallback
   put revCallbackCreate(the long id of me, "updateProfileImageCallback") into tCallback
   rvoFetchUserProperty sUserId, "thumbnail", tCallback, true
end updateProfileImage

command updateProfileImageCallback pResult
   if pResult["user_id"] is sUserId then
      if there is an image "image loader small" of me then
         delete image "image loader small" of me
      end if
      if pResult["result"]["thumbnail"] is not empty then
         set the text of image "profile image" of me to pResult["result"]["thumbnail"]
      else
         set the text of image "profile image" of me to the cStandardProfileThumb of stack "revOnline"
      end if
      rvoClearTooltip "Retrieving stack details ..."
   end if
end updateProfileImageCallback

command rateStack pStackId pRating
   if revOnlineSession() is empty then
      rvoUpdateTooltip "You must be logged in to rate content", true
      --send "setCanRate true" to group "rater template" of me
      send "setRating sRating" to group "rater template" of me  
   else
      local tRevision, tCallback   
      put revCallbackCreate(the long id of me, "rateStackCallback") into tCallback
      put the text of field "revision" of me into tRevision
      rvoRateStack pStackId, pRating, tRevision, tCallBack
   end if
end rateStack

command rateStackCallback pResult
   # will be either true or false
   if pResult is "true" then
      # Stack has been updated so must clear cache of its text details
      local tArray, tKey
      put "fetchStackData" into tArray["action"]
      put sStackId into tArray["parameters"]["id"]
      put revOnlineEncodeArray(tArray) into tKey      
      revOnlineCacheRemove tKey
      # Need to remove all searches that could potentially contain this stack
      revOnlineCacheRemoveAction "searchStacks"
      # Need to update the searchlist
      --updateSearchList
      updateSearchListPreview
      rvoUpdateTooltip "you rated the stack", true
   else if pResult is "false" then
      updateStackDetails
      rvoUpdateTooltip "you have already rated this stack", empty, true
   else
      updateStackDetails
      rvoUpdateTooltip pResult, true
   end if
end rateStackCallback

command editDetails  
   if sType is "external" then
      if the text of field "headline" of me is empty then
         put "<Place a headline for your external here>" into field "headline" of me
      end if
      if the text of field "description" of me is empty then
         put "<Place a description of your external here>" into field "description" of me
      end if
   else if sType is "code snippet" then
      set the locktext of field "name" of me to false
      set the showBorder of field "name" of me to true
      if the text of field "headline" of me is empty then
         put "<Place a headline for your code snippet here>" into field "headline" of me
      end if
      if the text of field "description" of me is empty then
         put "<Place a description of your code snippet here>" into field "description" of me
      end if
   else
      set the locktext of field "name" of me to false
      set the showBorder of field "name" of me to true
      if the text of field "headline" of me is empty then
         put "<Place a headline for your stack here>" into field "headline" of me
      end if
      if the text of field "description" of me is empty then
         put "<Place a description of your stack here>" into field "description" of me
      end if
   end if
   show image "stack pencil" of me
   set the locktext of field "headline" of me to false
   set the locktext of field "description" of me to false
   set the showBorder of field "headline" of me to true
   set the showBorder of field "description" of me to true
   set the showBorder of image "stack image" of me to true
   put empty into sStackImage
   put empty into sStackThumbnail
end editDetails

command setStackDetails   
   if the cType of me is "code snippet" then
      if the text of field "name" of me is "<Place a title for your code snippet here>" or field "name" of me is empty then
         rvoUpdateTooltip "You must enter a title for your code snippet", empty, true
         return false
      end if
   end if
   copy field "background blocker" of card "templates" of stack "revonline" to me
   set the rect of it to the rect of me
   rvoUpdateTooltip "Uploading ..."   
   local tCallback, tStackData
   put revCallbackCreate(the long id of me, "setStackDetailsCallback") into tCallback   
   put the text of field "name" of me into tStackData["title"]
   
   if the text of field "headline" of me is "<Place a headline for your stack here>" or \
          the text of field "headline" of me is "<Place a headline for your code snippet here>" or \
          the text of field "headline" of me is "<Place a headline for your external here>" then
      put empty into tStackData["headline"]
   else
      put the text of field "headline" of me into tStackData["headline"]
   end if
   
   if the text of field "description" of me is "<Place a description of your code snippet here>" or \
          the text of field "description" of me is "<Place a description of your stack here>" or \
          the text of field "description" of me is "<Place a description of your external here>" then
      put empty into tStackData["description"]
   else
      put the text of field "description" of me into tStackData["description"]
   end if
   
   if the text of image "stack image" of me is the cStandardImage of me then
      if the cType of me is "normal" then
         put empty into tStackData["icon"]
         put empty into tStackData["thumbnail"]
      else if the cType of me is "external" then
         put empty into tStackData["icon"]
         put empty into tStackData["thumbnail"]
      else if the cType of me is "code snippet" then
         put empty into tStackData["icon"]
         put empty into tStackData["thumbnail"]
      end if
   else
      if sStackImage is not empty then
         put sStackImage into tStackData["icon"]
      end if
      if sStackThumbnail is not empty then
         put sStackThumbnail into tStackData["thumbnail"]
      end if
   end if 
   
   # need to generate installers
   local tInstaller, tDescription, tName, tAuthor, tImageData, tTempFileName, tNewInstallerName
   put the text of field "name" of me into tName
   put the text of field "author" of me into tAuthor
   put tStackData["icon"] into tImageData
   put tStackData["description"] into tDescription
   
   if the cType of me is "external" then
      if tImageData is empty then
         put the cStandardExternalImage of stack "revonline" into tImageData
      end if
      put the text of field "platforms" of me into tStackData["platform"]
      send "createInstaller sPaths, tDescription, tName, tAuthor, tImageData" to stack "revOnlineExternalInstaller"
      put the result into tInstaller
      # Check the installer stack has been successfully created
      if there is a tInstaller then
         lock messages
         close tInstaller
         unlock messages
         set the visible of tInstaller to true
         put "External installer :" && tName into tNewInstallerName
         set the name of tInstaller to tNewInstallerName
         put the long id of stack tNewInstallerName into tInstaller
         # setup its image and text fields etc.
         put the tempName into tTempFileName
         save tInstaller as tTempFileName         
         put url ("binfile:" & tTempFileName) into sStackData
         put the width of stack tTempFileName into sStackWidth
         put the height of stack tTempFileName into sStackHeight
         delete stack tTempFilename         
      else
         put tInstaller
      end if   
   else if the cType of me is "code snippet" then
      if tImageData is empty then
         put the cStandardCodeSnippetImage of stack "revonline" into tImageData
      end if
      send "createCodeInstaller sCode, tDescription, tName, tAuthor, tImageData" to stack "revOnlineExternalInstaller"
      put the result into tInstaller 
      
      if there is a tInstaller then
         lock messages
         close tInstaller
         unlock messages
         set the visible of tInstaller to true
         put "Code snippet :" && tName into tNewInstallerName
         set the name of tInstaller to tNewInstallerName
         put the long id of stack tNewInstallerName into tInstaller
         put the tempName into tTempFileName
         save tInstaller as tTempFileName 
         put url ("binfile:" & tTempFileName) into sStackData         
         delete stack tTempFileName
      else
         put tInstaller
      end if
   end if
   
   # Check if stack data is provided
   if sStackData is not empty then
      put sStackData into tStackData["data"]
      put sStackWidth into tStackData["width"]
      put sStackHeight into tStackData["height"]
      put the cType of me into tStackData["type_name"]
   end if
   ###
   --   if sStackId is "new" then
   --      put empty into sStackId
   --   end if
   
   rvoSetStackData tStackData, sStackId, tCallBack
   return true
end setStackDetails

command discardChanges
   if the cMode of group "chooser" of me is "update" then
      hideContentChooser
   else
      set the cStack of me to (revOnlinePrefGet("stack id"))
   end if
end discardChanges

command setStackDetailsCallback pResult
     
   # Need to save the returned revonline stack id
   # if its a stack thats been uploaded for the first time
   if pResult is a number then
      if there is a stack sStackName then
         set the cRevOnline["id"] of stack sStackName to pResult
      end if
      rvoUpdateTooltip "Content uploaded", empty, true
      # Need to remove all searches that could potentially contain this stack
      revOnlineCacheRemoveAction "searchStacks"
      # Don't want to unecessarily refresh the search
      if the cSelectedUser of group "search filter" of stack "revonline" is empty or \
             the cSelectedUser of group "search filter" of stack "revonline" is revOnlineId() then
         updateSearchList
      end if
      set the cStack of me to pResult
   else if pResult is true then
      # stack has been updated so must clear cache of its details
      local tArray, tKey
      put "fetchStackData" into tArray["action"]
      put sStackId into tArray["parameters"]["id"]
      put revOnlineEncodeArray(tArray) into tKey      
      revOnlineCacheRemove tKey
      # request to stack image
      put empty into tArray
      put "fetchStackProperty" into tArray["action"]
      put sStackId into tArray["parameters"]["id"]
      put "icon" into tArray["parameters"]["propertyName"]
      put revOnlineEncodeArray(tArray) into tKey
      revOnlineCacheRemove tKey      
      # request to stack thumb
      put empty into tArray
      put "fetchStackProperty" into tArray["action"]
      put sStackId into tArray["parameters"]["id"]
      put "thumbnail" into tArray["parameters"]["propertyName"]
      put revOnlineEncodeArray(tArray) into tKey
      revOnlineCacheRemove tKey
      # Need to remove all searches that could potentially contain this stack
      revOnlineCacheRemoveAction "searchStacks"
      
      # Update the searchlist group
      updateSearchListPreview
      # Update the thumbnail of the relevant group in the searchlist
      send "updateListItemThumbnail sStackId" to group "search list" of this stack
      
      rvoUpdateTooltip "Content updated", empty, true
      set the cStack of me to sStackId
   else
      updateView
      rvoUpdateTooltip "Failed to update stack",  empty, true
   end if
end setStackDetailsCallback

command importImage
   local tPath, tImageData
   
   put revAnswerFiles("image","select picture to upload") into tPath
   if tPath is not empty then
      put url ("binfile:" & tPath) into tImageData
      
      lock screen
      copy field "background blocker" of card "templates" of stack "revonline" to me
      set the rect of it to the rect of me
      
      # Copy image import group onto this card
      if there is a group "image importer" of me then
         delete group "image importer" of me
      end if
      copy group "image importer" of card "templates" of stack "revonline" to me
      set the loc of group "image importer" of me to the loc of the owner of me
      hide group "user crop box" of group "image importer" of me
      unlock screen
      
      
      # Need to store original image dimensions
      lock screen
      local tOriginalHeight, tOriginalWidth
      set the text of image "stack image import" of me to tImageData
      put the height of image "stack image import" of me into tOriginalHeight
      put the width of image "stack image import" of me into tOriginalWidth
      
      local tAspectRatio, tRequiredAspectRatio, tScaleFactor
      put (the width of group "stack crop box" of me / the height of group "stack crop box" of me) into tRequiredAspectRatio
      put (the width of image "stack image import" of me / the height of image "stack image import" of me) into tAspectRatio
      
      # Imported image has wider aspect ratio
      if tAspectRatio >= tRequiredAspectRatio then
         put (the height of group "stack crop box" of me / the height of image "stack image import" of me) into tScaleFactor
      end if
      
      # Imported image has taller aspect ratio
      if tAspectRatio < tRequiredAspectRatio then
         put (the width of group "stack crop box" of me / the width of image "stack image import" of me) into tScaleFactor
      end if
      
      # Resize the image to fit in the required space
      set the width of image "stack image import" of me to the width of image "stack image import" of me * tScaleFactor
      set the height of image "stack image import" of me to the height of image "stack image import" of me * tScaleFactor      
      
      # This reduces speed issues considerably but lowers quality of image
      local tTempImageData
      export snapshot from image "stack image import" of me to tTempImageData as jpeg
      set the text of image "stack image import" of me to tTempImageData
      
      set the loc of image "stack image import" of me to the loc of group "stack crop box" of me
      show image "stack image import" of me
      put empty into field "importing" of group "image importer" of me
      unlock screen
      # To speed up subsequent resizing
      --      if tOriginalWidth > (2 * the width of group "stack crop box" of me) or \
             --             tOriginalHeight > (2 * the height of group "stack crop box" of me) then
      --         set the resizeQuality of image "stack image import" of me to "good"
      --      else
      --         set the resizeQuality of image "stack image import" of me to "best"
      --      end if     
      
   end if
end importImage

command takeSnapshot
   if there is a group "image importer" of me then
      # Main stack image
      export snapshot from rect( \
             (the left of group "stack crop box" of group "image importer" of me + 1, \
             the top of group "stack crop box" of group "image importer" of me + 1, \
             the right of group "stack crop box" of group "image importer" of me - 1, \
             the bottom of group "stack crop box" of group "image importer" of me - 1)) \
             of window(the windowid of stack "revonline") to sStackImage as jpeg
      set the text of image "stack image" of me to sStackImage
      # Stack thumbnail
      set the text of image "stack image thumbnail" of group "image importer" of me to sStackImage
      export snapshot from image "stack image thumbnail" of group "image importer" of me to sStackThumbnail as jpeg
      ###hide group "image importer" of me
      hidePalette
   end if
end takeSnapshot

command clearContents
   lock screen
   
   if there is a group "image importer" of me then
      delete group "image importer" of me
   end if
   hide group "edit stack" of me
   send "hideAll" to group "edit stack" of me
   hide group "chooser" of me
   put empty into sStackData
   put empty into sStackName
   show graphic "stack divider" of me
   hide image "stack pencil" of me
   
   set the text of image "stack image" of me to empty
   set the text of image "profile image" of me to empty
   
   put empty into field "size" of me
   hide field "size" of me
   hide field "size label" of me
   hide field "platforms label" of me
   hide field "platforms" of me
   put empty into field "platforms" of me
   
   show image "stack image" of me
   show image "profile image" of me
   show field "author label" of me
   show field "last updated label" of me
   show field "revision label" of me
   show field "tags label" of me
   show field "downloads label" of me
   show field "rating label" of me
   show field "download label" of me
   show field "author" of me
   show field "last updated" of me
   show field "revision" of me
   show field "tags" of me
   show field "downloads" of me
   show field "download" of me
   show field "headline" of me
   show field "description" of me
   show field "type label" of me
   --hide field "please select" of me
   show field "type" of me
   show button "download" of me
   
   # Rating widget
   if there is a group "rater template" of me then
      set the cantdelete of group "rater template" of me to false
      delete group "rater template" of me
   end if
   copy group "rater template" of card "templates" of this stack to me
   set the cantdelete of group "rater template" of me to false
   local tLongId
   put the long id of me into tLongId
   send "setRateCallback rateStack, tLongId" to group "rater template" of me
   send "setId sStackId" to group "rater template" of me
   send "setCanRate false" to group "rater template" of me
   
   if there is a group "tag template" of me then
      delete group "tag template" of me
   end if
   if there is a group "tag template 2" of me then
      delete group "tag template 2" of me
   end if
   --set the text of field "AddTag" of me to "Add tag"
   
   set the locktext of field "name" of me to true
   --set the traversalOn of field "name" of me to false
   set the locktext of field "headline" of me to true
   --set the traversalOn of field "headline" of me to false
   set the locktext of field "description" of me to true
   --set the traversalOn of field "description" of me to false  
   
   put empty into field "name" of me
   put empty into field "author" of me
   put empty into field "last updated" of me
   put empty into field "downloads" of me
   put empty into field "revision" of me
   put empty into field "download" of me
   put empty into field "headline" of me
   put empty into field "description" of me
   put empty into field "tags" of me
   put empty into field "type" of me
   put empty into sTags
   set the text of image "stack image" of me to empty
   set the text of image "stack thumbnail" of me to empty
   set the text of image "profile image" of me to empty
   set the showBorder of field "name" of me to false
   set the showBorder of field "headline" of me to false
   set the showBorder of field "description" of me to false
   set the showBorder of image "stack image" of me to false
   if there is a field "background blocker" of me then
      delete field "background blocker" of me
   end if
   
   unlock screen
end clearContents



command resize pContainerRect
   lock screen
   set the rect of group "edit stack" of me to (item 1 of pContainerRect, the top of me, item 3 of pContainerRect, the top of me + 25)
   send "resize" to group "edit stack" of me
   if the visible of group "edit stack" of me then
      set the rect of field "name" of me to (item 1 of pContainerRect, the bottom of group "edit stack" of me, item 3 of pContainerRect, the bottom of group "edit stack" of me + 36)
   else
      set the rect of field "name" of me to (item 1 of pContainerRect, the top of me, item 3 of pContainerRect, the top of me + 32)
   end if
   
   set the rect of group "chooser" of me to \
          (item 1 of pContainerRect, item 2 of pContainerRect, item 3 of pContainerRect, item 4 of pContainerRect - 10)
   send "resize" to group "chooser" of me
   
   set the topleft of field "author label" of me to (item 1 of pContainerRect + kSpacing, the bottom of field "name" of me)
   set the topleft of image "stack image" of me to (the left of field "author label" of me + 7, the bottom of field "author label" of me - 4)
   set the topleft of image "stack thumbnail" of me to the topleft of image "stack image" of me
   set the bottomright of image "stack pencil" of me to (the right of image "stack image" of me - 6, the bottom of image "stack image" of me - 6)
   
   set the topleft of field "rating label" of me to (the right of image "stack image" of me + 1, the top of image "stack image" of me - 4)
   set the topleft of field "type label" of me to (the left of field "rating label" of me, the bottom of field "rating label" of me + 1)
   set the topleft of field "revision label" of me to (the left of field "type label" of me, the bottom of field "type label" of me + 1)
   set the topleft of field "platforms label" of me to (the left of field "revision label" of me, the bottom of field "revision label" of me + 1)
   if the cType of me is "external" and the visible of group "chooser" of me is false then
      set the topleft of field "tags label" of me to (the left of field "platforms label" of me, the bottom of field "platforms label" of me)
      show field "platforms" of me
      show field "platforms label" of me
   else
      set the topleft of field "tags label" of me to (the left of field "revision label" of me, the bottom of field "revision label" of me + 1)
      hide field "platforms" of me
      hide field "platforms label" of me
   end if
   
   set the topleft of field "last updated label" of me to (the left of field "author label" of me, the bottom of image "stack image" of me + 4)
   set the topright of field "downloads label" of me to (the right of image "stack image" of me, the bottom of image "stack image" of me + 4)
   
   set the topleft of field "author" of me to (the right of field "author label" of me - 12, the top of field "author label" of me)
   if there is a group"rater template" of me then
      set the topleft of group "rater template" of me to (the right of field "rating label" of me + 5, the top of field "rating label" of me + 3)
   end if
   set the topright of image "profile image" of me to \
          (min(item 3 of pContainerRect, the right of field "rating label" of me + the width of image "profile image" of me + 120),the top of image "stack image" of me)
   
   set the topleft of field "type" of me to the topright of field "type label" of me
   set the topleft of field "revision" of me to the topright of field "revision label" of me
   set the topleft of field "platforms" of me to the topright of field "platforms label" of me
   set the topleft of field "downloads" of me to (the left of field "downloads label" of me, the bottom of field "downloads label" of me - 4)
   set the topleft of field "last updated" of me to (the left of field "last updated label" of me, the bottom of field "last updated label" of me - 4)
   
   set the rect of button "download" of me to \
          (the right of image "stack image" of me + 6, the bottom of field "last updated" of me - 16, \
          min(the right of image "profile image" of me - 1, item 3 of pContainerRect), the bottom of field "last updated" of me + 1)
   set the bottomright of field "download label" of me to (item 1 of the loc of button "download" of me, the bottom of button "download" of me)
   set the topleft of field "download" of me to the topright of field "download label" of me
   
   set the topleft of field "size label" of me to the bottomleft of field "tags label" of me
   set the topleft of field "size" of me to (the right of field "size label" of me - 6, the top of field "size label" of me)
   
   
   set the rect of field "headline" of me to \
          (the left of field "author label" of me, the bottom of field "downloads" of me + 10, item 3 of pContainerRect - kSpacing, the bottom of field "downloads" of me + the formattedheight of field "headline" of me + 6)
   set the points of graphic "stack divider" of me to \
          (item 1 of pContainerRect + 18, the bottom of field "headline" of me + 10) & return & \
          (item 3 of pContainerRect - 18, the bottom of field "headline" of me + 10)
   set the rect of field "description" of me to \
          (the left of field "author label" of me, the bottom of graphic "stack divider" of me + 10, item 3 of pContainerRect - kSpacing-25, \
          max(item 4 of pContainerRect - 10, the top of field "description" of me + the formattedheight of field "description" of me + 5))
   
   # Have to ajust number of items in the tags field
   put sTags into field "tags" of me
   
   # Need to get around issue of calculating formatted height when simultaneously setting width, instead set width first
   set the rect of field "tags" of me to \
          (the left of field "tags label" of me, the top of field "tags label" of me, the right of image "profile image" of me, the top of field "tags label" of me + 10)
   set the rect of field "tags" of me to \
          (the left of field "tags label" of me, the top of field "tags label" of me, the right of image "profile image" of me, \
          min(the top of field "tags label" of me + the formattedheight of field "tags" of me, the top of field "download label" of me - 6))
   
   if the (formattedheight of field "tags" of me - 2) > the height of field "tags" of me then
      repeat until (the formattedheight of field "tags" of me - 2) < the height of field "tags" of me
         delete item -1 of field "tags" of me
      end repeat
      delete item -1 of field "tags" of me
      put ", ..." after field "tags" of me
   end if   
   set the topleft of button "tag" of me to (the left of field "tags" of me + 5, the bottom of field "tags" of me - 12)
   set the topleft of field "addtag" of me to (the right of button "tag" of me - 8, the top of button "tag" of me - 1)
   
   if there is a group "tag template" of me then
      set the topright of group "tag template" of me to the topright of button "tag" of me
   end if
   unlock screen
end resize

# Called when a stack is explicitly updated
command newStackFileUpdate tPath
   --send "showEditControls" to group "edit stack" of me
   set the cRevOnline["id"] of stack tPath to sStackId
   getStackData tPath
   hideContentChooser
end newStackFileUpdate


# tPath, path to newly opened stack
command newStackFile tPath
   hideContentChooser
   set the cType of me to "normal"
   
   getStackData tPath
   
   show image "stack pencil" of me
   # Need to check if stack has been uploaded previously
   if the cRevOnline["id"] of stack tPath is empty then
      put the short name of stack tPath into sStackName
      if the title of stack tPath is empty then
         put the short name of stack tPath into field "name" of me
      else
         put the title of stack tPath into field "name" of me
      end if
      put "<Place a headline for your stack here>" into field "headline" of me
      put "<Place a description of your stack here>" into field "description" of me
      put the date into field "last updated" of me
      put "1" into field "revision" of me
      set the text of image "stack image" of me to the cStandardImage of me
      set the text of image "stack thumbnail" of me to the cStandardThumb of me
      hide field "tags" of me
      hide field "addtag" of me
      hide button "tag" of me
      hide button "download" of me
      hide field "download label" of me
      hide field "download" of me
      show field "size" of me   
      show field "size label" of me
      put revOnlineDisplayName() into field "author" of me
      put revOnlineId() into sUserId
      updateProfileImage
      
      set the locktext of field "name" of me to false
      set the locktext of field "headline" of me to false
      set the locktext of field "description" of me to false
      set the showBorder of field "name" of me to true
      set the showBorder of field "headline" of me to true
      set the showBorder of field "description" of me to true
      set the showBorder of image "stack image" of me to true      
      
   else
      put the cRevOnline["id"] of stack tPath into sStackId
      rvoUpdateTooltip "This stack has already been uploaded to revOnline", empty, true
      updateStackDetails
   end if  
   
   
   
   send "resize" to the owner of me
end newStackFile

command getStackData pPath
   local tStackData, tSize, tFormattedSize
   put url ("binfile:" & pPath) into tStackData
   put the length of tStackData into tSize
   put round((tSize / 1024),1) into tFormattedSize
   if tFormattedSize > 1000 then
      put round((tSize / 1048576),1) & "MB" into field "download" of me    
      put round((tSize / 1048576),1) & "MB" into field "size" of me
   else
      put tFormattedSize & "KB" into field "download" of me    
      put tFormattedSize & "KB" into field "size" of me
   end if
   put tStackData into sStackData
   put the width of stack pPath into sStackWidth
   put the height of stack pPath into sStackHeight     
end getStackData

command newExternalFile pPaths, pPlatforms
   hideContentChooser
   local tInstaller, tImageData
   put pPaths into sPaths
   put the cStandardExternalImage of me into tImageData
   send "createInstaller pPaths, empty, empty, empty, tImageData" to stack "revOnlineExternalInstaller"
   put the result into tInstaller
   
   # Check the installer stack has been successfully created
   if there is a tInstaller then      
      # Save the stack to obtain its size, dimensions etc.
      local tTempFileName
      put the tempName into tTempFileName
      save tInstaller as tTempFileName 
      getStackData tTempFileName    
      
      show field "size" of me   
      show field "size label" of me
      lock messages
      delete stack tTempFilename
      unlock messages
      
      set the cType of me to "external"
      local tFilename
      # Need to select a name that matches one of the external files
      put getFileName(pPaths[(line 1 of the keys of pPaths)]) into tFilename
      
      put tFilename into sStackName
      put tFilename into field "name" of me   
      put "<Place a headline for your external here>" into field "headline" of me
      put "<Place a description of your external here>" into field "description" of me
      put the date into field "last updated" of me
      put "1" into field "revision" of me
      set the text of image "stack image" of me to the cStandardImage of me
      set the text of image "stack thumbnail" of me to the cStandardThumb of me
      hide field "tags" of me
      hide field "addtag" of me
      hide button "tag" of me
      hide button "download" of me
      hide field "download label" of me
      hide field "download" of me
      
      put revOnlineDisplayName() into field "author" of me
      ### need to check this is right
      put revOnlineId() into sUserId
      updateProfileImage
      
      show image "stack pencil" of me          
      set the locktext of field "headline" of me to false
      set the locktext of field "description" of me to false
      set the showBorder of field "headline" of me to true
      set the showBorder of field "description" of me to true
      put pPlatforms into field "platforms" of me
   end if   
   
   
   
   send "resize" to the owner of me
end newExternalFile

command newExternalFileUpdate pPaths, pPlatforms
   send "showEditControls" to group "edit stack" of me
   local tInstaller, tImageData
   put pPaths into sPaths
   put the cStandardExternalImage of me into tImageData
   send "createInstaller pPaths, empty, empty, empty, tImageData" to stack "revOnlineExternalInstaller"
   put the result into tInstaller
   if there is a tInstaller then      
      local tTempFileName
      put the tempName into tTempFileName
      save tInstaller as tTempFileName 
      getStackData tTempFileName          
      lock messages
      delete stack tTempFilename
      unlock messages
      # Need to select a name that matches one of the external files
      local tFileName
      put getFileName(pPaths[(line 1 of the keys of pPaths)]) into tFilename
      put tFilename into sStackName
      put tFilename into field "name" of me   
      put pPlatforms into field "platforms" of me
   end if
   hideContentChooser   
end newExternalFileUpdate

command newCodeFile pCode
   hideContentChooser
   put pCode into sCode
   set the cType of me to "code snippet"
   
   local tInstaller, tImageData
   put the cStandardCodeSnippetImage of me into tImageData
   send "createCodeInstaller sCode, empty, empty, empty, tImageData" to stack "revOnlineExternalInstaller"
   put the result into tInstaller 
   
   if there is a tInstaller then      
      local tTempFileName
      put the tempName into tTempFileName
      save tInstaller as tTempFileName 
      getStackData tTempFileName
      show field "size" of me   
      show field "size label" of me
      lock messages
      delete stack tTempFileName
      unlock messages
   end if
   
   
   put "<Place a title for your code snippet here>" into field "name" of me   
   put "<Place a headline for your code snippet here>" into field "headline" of me
   put "<Place a description of your code snippet here>" into field "description" of me
   put the date into field "last updated" of me
   put "1" into field "revision" of me
   set the text of image "stack image" of me to the cStandardImage of me
   set the text of image "stack thumbnail" of me to the cStandardThumb of me
   hide field "tags" of me
   hide field "addtag" of me
   hide button "tag" of me
   
   hide button "download" of me
   hide field "download label" of me
   hide field "download" of me
   put revOnlineDisplayName() into field "author" of me
   put revOnlineId() into sUserId
   updateProfileImage
      
   show image "stack pencil" of me
   set the locktext of field "name" of me to false
   set the locktext of field "headline" of me to false
   set the locktext of field "description" of me to false
   set the showBorder of field "name" of me to true
   set the showBorder of field "headline" of me to true
   set the showBorder of field "description" of me to true      
   --resize (the rect of the owner of me)   
   
   
   
   send "resize" to the owner of me
end newCodeFile

command newCodeFileUpdate pCode
   send "showEditControls" to group "edit stack" of me
   local tInstaller, tImageData
   put the cStandardCodeSnippetImage of me into tImageData
   put pCode into sCode
   send "createCodeInstaller sCode, empty, empty, empty, tImageData" to stack "revOnlineExternalInstaller"
   put the result into tInstaller 
   if there is a tInstaller then      
      local tTempFileName
      put the tempName into tTempFileName
      save tInstaller as tTempFileName 
      getStackData tTempFileName
      lock messages
      delete stack tTempFileName
      unlock messages
   end if
   hideContentChooser
end newCodeFileUpdate


on mouseUp
   if the short name of the target is "download" then
      rvoLaunchStack sStackId
   end if
end mouseUp

command tagContent
   lock screen
   if there is a group "tag template" of me then
      delete group "tag template" of me
   end if
   if there is a group "tag template 2" of me then
      delete group "tag template 2" of me
   end if
   
   copy field "background blocker" of card "templates" of stack "revonline" to me
   set the rect of it to the rect of me
   
   if the text of field "addtag" is "add / delete tags" then
      # Stack belongs to user so use different tagging tool
      copy group "tag template 2" of card "templates" of stack "revonline" to me
      set the cantdelete of group "tag template 2" of me to false
      set the loc of group "tag template 2" of me to the loc of the owner of me
      put empty into field "input" of group "tag template 2" of me
      put empty into field "auto" of group "tag template 2" of me
      hide field "auto" of group "tag template 2" of me
      local tTags
      put sTags into tTags
      repeat until char 1 of tTags is not tab and char 1 of tTags is not space
         delete char 1 of tTags
      end repeat
      send "displayTags tTags" to group "tag template 2" of me
      
      show group "tag template 2" of me
      --focus on field "input" of group "tag template 2" of me
   else
      # Standard case, used for just adding tags
      copy group "tag template" of card "templates" of stack "revonline" to me
      set the cantdelete of group "tag template" of me to false
      set the loc of group "tag template" of me to the loc of the owner of me
      put empty into field "input" of group "tag template" of me
      put empty into field "auto" of group "tag template" of me
      hide field "auto" of group "tag template" of me
      show group "tag template" of me
      focus on field "input" of group "tag template" of me
   end if
   unlock screen
end tagContent

command deleteStack
   local tCallback
   put revCallbackCreate(the long id of me, "deleteStackCallback") into tCallback   
   rvoDeleteStack sStackId, tCallback
end deleteStack

command deleteStackCallback tResult
   if tResult is true then
      rvoUpdateTooltip "Content was successfully deleted", empty, true
      # Need to remove all searches that could potentially contain this stack
      revOnlineCacheRemoveAction "searchStacks"
      # stack has been updated so must clear cache of its details
      local tArray, tKey
      put "fetchStackData" into tArray["action"]
      put sStackId into tArray["parameters"]["id"]
      put revOnlineEncodeArray(tArray) into tKey      
      revOnlineCacheRemove tKey
      updateSearchList 0
      updateView "list", "User", revOnlineId()
   else
      rvoUpdateTooltip "Failed to delete content", empty, true
   end if
end deleteStackCallback

command submitTag pTag
   if revOnlineSession() is empty then
      rvoUpdateTooltip "You must be logged in to tag content", empty, true
      ###hide group "tag template" of me
      hidePalette
   else
      rvoUpdateTooltip "Submitting tag ..."
      local tCallback
      put revCallbackCreate(the long id of me, "submitTagCallback") into tCallback   
      rvoTagStack sStackId, pTag, tCallback
   end if
end submitTag

command submitTags pTags
   if revOnlineSession() is empty then
      rvoUpdateTooltip "You must be logged in to tag content", empty, true
      ###hide group "tag template 2" of me
      hidePalette      
   else
      rvoUpdateTooltip "Submitting tags ..."
      local tCallback
      put revCallbackCreate(the long id of me, "submitTagCallback") into tCallback   
      rvoEditTags sStackId, pTags, tCallback
   end if
end submitTags

command submitTagCallback pResult
   if pResult is "cgierror,not_logged_in" then
      rvoUpdateTooltip "not logged in"
   else
      rvoUpdateTooltip "Tags updated", empty, true
      # Should remove all listTag requests
      revOnlineCacheRemoveAction "listTags"
      # Need to remove request to get current stack data
      local tArray, tKey
      put "fetchStackData" into tArray["action"]
      put sStackId into tArray["parameters"]["id"]
      put revOnlineEncodeArray(tArray) into tKey      
      revOnlineCacheRemove tKey
      # Update tags list in search filter group
      send "listTags" to group "search filter" of this card
      # Update relevant stack preview in the searchlist
      updateSearchListPreview
      # Update tag widget list     
      updateWidgetTagsList
      # Update current stack view
      --updateStackDetails
      set the cStack of me to sStackId
   end if
   hidePalette
end submitTagCallback

# for autocomplete field in tagging widget
command updateWidgetTagsList
   local tCallback
   put revCallbackCreate(the long id of me, "updateWidgetTagsListCallback") into tCallback
   rvoListTags empty, "alphabetical", 0, 1000, tCallback, empty, empty
end updateWidgetTagsList

command updateWidgetTagsListCallback pResult
   set the cAllTags of group "tag template" of card "templates" of stack "revonline" to pResult
   set the cAllTags of group "tag template 2" of card "templates" of stack "revonline" to pResult
end updateWidgetTagsListCallback

command updateSearchListPreview
   send "updatelistItemText sStackId" to group "search list" of this stack
end updateSearchListPreview

private function getFilename pPath
   local tLeaf
   set the itemDelimiter to slash
   put item -1 of pPath into tLeaf
   set the itemDelimiter to "."
   return item 1 to -2 of tLeaf
end getFilename

command hidePalette
   lock screen
   if there is a field "background blocker" of me then
      delete field "background blocker" of me
   end if
   if there is a group "image importer" of me then
      delete group "image importer" of me
   end if
   if there is a group "tag template" of me then
      delete group "tag template" of me
   end if
   if there is a group "tag template 2" of me then
      delete group "tag template 2" of me
   end if
   unlock screen
end hidePalette

command showContentChooser pMode
   lock screen
   --send "showCancelControl" to group "edit stack" of me
   
   
   if pMode is "update" then
      --send "showCancelControl" to group "edit stack" of me
      ###hide group "edit stack" of me
      set the cMode of group "chooser" of me to "update"
   else
      set the cMode of group "chooser" of me to empty
      ###hide group "edit stack" of me
   end if
   
   if there is an image "image loader" of me then
      delete image "image loader" of me
   end if
   if there is an image "image loader small" of me then
      delete image "image loader small" of me
   end if
      
   # must empty appropriate fields in chooser
   put empty into field "code input" of group "chooser" of me
   put empty into field "stack path" of group "chooser" of me
   
   put empty into field "path" of group "windows" of group "chooser" of me
   set the showBorder of field "path" of group "windows" of group "chooser" of me to true
   disable field "path" of group "windows" of group "chooser" of me
   disable button "browse" of group "windows" of group "chooser" of me
   hide image "path background" of group "windows" of group "chooser" of me
   set the hilite of button "check" of group "windows" of group "chooser" of me to false
   
   put empty into field "path" of group "os x" of group "chooser" of me
   set the showBorder of field "path" of group "os x" of group "chooser" of me to true
   disable field "path" of group "os x" of group "chooser" of me
   disable button "browse" of group "os x" of group "chooser" of me
   hide image "path background" of group "os x" of group "chooser" of me
   set the hilite of button "check" of group "os x" of group "chooser" of me to false
   
   put empty into field "path" of group "linux" of group "chooser" of me
   set the showBorder of field "path" of group "linux" of group "chooser" of me to true
   disable field "path" of group "linux" of group "chooser" of me
   disable button "browse" of group "linux" of group "chooser" of me
   hide image "path background" of group "linux" of group "chooser" of me
   set the hilite of button "check" of group "linux" of group "chooser" of me to false     
   
   hide graphic "stack divider" of me
   hide image "stack image" of me
   hide image "profile image" of me
   hide field "author label" of me
   hide field "last updated label" of me
   hide field "revision label" of me
   hide field "tags label" of me
   hide field "downloads label" of me
   hide field "rating label" of me
   hide field "download label" of me
   hide field "author" of me
   hide field "last updated" of me
   hide field "revision" of me
   hide field "tags" of me
   hide field "downloads" of me
   hide field "download" of me
   hide field "headline" of me
   hide field "description" of me
   hide button "download" of me   
   hide button "tag" of me
   hide field "addtag" of me
   hide field "type" of me
   hide field "type label" of me
   hide field "name" of me
   hide field "platforms" of me
   hide field "platforms label" of me
   
   --enable button "browse" of the owner of me
   if there is a group "rater template" of me then
      hide group "rater template" of me
   end if
   
   --updateRecentStacks
   
   if the cContentType of group "chooser" of me is empty then
      set the cContentType of group "chooser" of me to "stack"
   end if
   set the cContentType of group "chooser" of the owner of me to sType
   
   show group "chooser" of me
   unlock screen
end showContentChooser

command hideContentChooser
   if the cMode of group "chooser" of me is "update" then
      send "showEditControls" to group "edit controls" of stack "revonline"
      set the cMode of group "chooser" of me to empty
   else
      send "showNewStackControls" to group "edit controls" of stack "revonline"
      ###send "showSaveCancelControls" to group "edit stack" of me
   end if
   ###show group "edit stack" of me
   
   show graphic "stack divider" of me
   show image "stack image" of me
   show image "profile image" of me
   show field "author label" of me
   show field "last updated label" of me
   show field "revision label" of me
   show field "tags label" of me
   show field "downloads label" of me
   show field "rating label" of me
   show field "download label" of me
   show field "author" of me
   show field "last updated" of me
   show field "revision" of me
   show field "tags" of me
   show field "downloads" of me
   show field "download" of me
   show field "headline" of me
   show field "description" of me
   show button "download" of me   
   show button "tag" of me
   show field "addtag" of me
   show field "type" of me
   show field "type label" of me
   show field "name" of me
   --enable button "browse" of the owner of me
   if there is a group "rater template" of me then
      show group "rater template" of me
   end if   
   hide group "chooser" of me
   send "resize" to the owner of me
end hideContentChooser








