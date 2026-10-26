script "stack_revOnline_group_id_31884"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "user" (id 31884)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


local sUserEmail
local sUserId
# Editable/non-editable
local sMode
local sUserImage
local sUserThumbnail

setProp cUser pUserId
   lock screen
   set the cType of group "edit controls" of stack "revonline" to "profile"
   clearContents
   put pUserId into sUserId
   hide button "commit" of me
   hide image "user pencil" of me
   hide button "discard" of me
   hide button "Show Email" of me
   updateUserDetails
   unlock screen
end cUser

getProp cUser
   return sUserId
end cUser

command updateUserDetails
   rvoUpdateTooltip "Retrieving user details ..."
   local tCallback
   put revCallbackCreate(the long id of me, "updateUserDetailsCallback") into tCallback
   set the text of image "user image" of me to empty
   send "resize" to the owner of me
   rvoFetchUserData sUserId, tCallback, true   
end updateUserDetails

command updateUserDetailsCallback pResult
   if pResult["id"] is sUserId then
      lock screen
      # Check if first time editing the profile
      if pResult["id"] is revOnlineId() and pResult["first_name"] is empty then
         set the hilite of button "Show Email" of me to (pResult["show_email"] = 1)
         put revOnlineEmail() into field "email" of me
         if there is an image "image loader" of me then
            delete image "image loader" of me
         end if
         set the cEnabled of group "edit controls" of stack "revonline" to true
         send "showEditControls" to group "edit controls" of stack "revonline"
         editProfile
      else      
         if pResult["id"] is revOnlineId() then
            put empty into sUserImage
            put empty into sUserThumbnail
            --put revOnlineEmail() into field "email" of me
            set the cEnabled of group "edit controls" of stack "revonline" to true
            set the hilite of button "Show Email" of me to (pResult["show_email"] = 1)
         else
            put pResult["email"] into field "email" of me
            set the cEnabled of group "edit controls" of stack "revonline" to empty
         end if         
         ###
         put pResult["email"] into field "email" of me
         
         put pResult["first_name"] && pResult["last_name"] into field "name" of me
         put pResult["first_name"] into field "first name" of me
         put pResult["last_name"] into field "last name" of me      
         put pResult["city"] into field "city" of me
         put pResult["state"] into field "state" of me
         put pResult["country"] into field "country" of me
         
         if pResult["city"] is not empty then
            put pResult["city"] & comma & space after field "location" of me 
         end if
         if pResult["state"] is not empty then
            put pResult["state"] & comma & space after field "location" of me 
         end if
         if pResult["country"] is not empty then
            put pResult["country"] & comma & space after field "location" of me 
         end if
         delete char -2 to -1 of field "location" of me
                  
         put pResult["company"] into field "company" of me
         put pResult["biography"] into field "biography" of me
         put pResult["website"] into field "website" of me
         local tRating
         put pResult["averageRating"] into tRating
         send "setRating tRating" to group "rater template" of me
         populateUploadList pResult["recent_uploads"]
         # Need to check if the user has uploaded a custom image
         if pResult["image_size"] > 0 then
            if there is not an image "image loader" of me then
               copy image "image loader" of card "templates" of this stack to me
               set the loc of image "image loader" of me to the loc of image "user image" of me
            end if
            updateUserImage
         else
            if there is an image "image loader" of me then
               delete image "image loader" of me
            end if
            set the text of image "user image" of me to the cStandardProfileImage of stack "revonline"
            rvoClearTooltip "Retrieving user details ..."
         end if
      end if
   end if
   send "resize" to the owner of me
   unlock screen
end updateUserDetailsCallback

command updateUserImage
   rvoUpdateTooltip "Retrieving user details ..."
   local tCallback
   put revCallbackCreate(the long id of me, "updateUserImageCallback") into tCallback
   rvoFetchUserProperty sUserId, "image", tCallback, true
end updateUserImage

command updateUserImageCallback pResult
   if pResult["user_id"] is sUserId then
      if there is an image "image loader" of me then
         delete image "image loader" of me
      end if
      if pResult["result"]["image"] is not empty then
         set the text of image "user image" of me to pResult["result"]["image"]
      end if
      rvoClearTooltip "Retrieving user details ..."
   end if
end updateUserImageCallback

command populateUploadList pRecent_Uploads
   local tStackIds, tStackNames, tKeys
   put the keys of pRecent_Uploads into tKeys
   sort lines of tKeys ascending numeric
   put the number of lines in tKeys into field "uploads" of me
   repeat for each line tKey in tKeys
      put pRecent_Uploads[tKey]["id"] & return after tStackIds
      put capitaliseChar1(pRecent_Uploads[tKey]["title"]) & return after tStackNames
   end repeat
   delete char -1 of tStackIds
   delete char -1 of tStackNames
   set the cStackIds of field "upload list" of me to tStackIds
   put tStackNames into field "upload list" of me
end populateUploadList



command editProfile
   set the text of field "name" of me to empty
   show field "first name label" of me
   show field "last name label" of me
   show field "first name" of me
   show field "last name" of me
   show button "Show Email" of me
   show field "change password" of me
   
   
   show image "user pencil" of me
   show field "city label" of me
   show field "city" of me
   show field "state label" of me
   show field "state" of me
   show field "country label" of me
   show field "country" of me
   hide field "location label" of me   
   hide field "location" of me
   hide button "edit" of me
   set the locktext of field "city" of me to false
   set the locktext of field "state" of me to false
   set the locktext of field "country" of me to false
   set the locktext of field "company" of me to false
   set the locktext of field "biography" of me to false
      
   if the text of image "user image" of me is empty then
      set the text of image "user image" of me to the cStandardImage of me
   end if      
   set the locktext of field "website" of me to false
   set the showBorder of field "city" of me to true
   set the showBorder of field "state" of me to true
   set the showBorder of field "country" of me to true
   set the showBorder of field "company" of me to true
   set the showBorder of field "website" of me to true
   set the showBorder of field "biography" of me to true
   set the showBorder of image "user image" of me to true
   set the showBorder of field "first name" of me to true
   set the showBorder of field "last name" of me to true
   send "resize" to the owner of me
end editProfile

command setUserData
   if the text of field "first name" of me is empty or the text of field "last name" of me is empty then
      rvoUpdateTooltip "You must enter a first and last name", true   
      send "showEditControls" to group "edit controls" of stack "revonline"
   else      
      copy field "background blocker" of card "templates" of stack "revonline" to me
      set the rect of it to the rect of me
      
      
      rvoUpdateTooltip "Setting user details ..."   
      local tCallback, tUserData
      put revCallbackCreate(the long id of me, "setUserDataCallback") into tCallback
      put the text of field "first name" of me into tUserData["first_name"]
      put the text of field "last name" of me into tUserData["last_name"]
      put the text of field "company" of this card into tUserData["company"]
      put the text of field "country" of this card into tUserData["country"]
      put the text of field "state" of this card into tUserData["state"]
      put the text of field "city" of this card into tUserData["city"]
      if the text of field "biography" of me is "<Please enter a biography here>" then
         put empty into tUserData["biography"]
      else
         put the text of field "biography" of this card into tUserData["biography"]
      end if
      put the text of field "website" of this card into tUserData["website"]
      
      if the hilite of button "Show Email" of me then
         put 1 into tUserData["show_email"]
      else
         put 0 into tUserData["show_email"]
      end if
      
      if the text of image "user image" of me is the cStandardImage of me then
         put empty into tUserData["image"]
         put empty into tUserData["thumbnail"]
      else
         if sUserImage is not empty then
            put sUserImage into tUserData["image"]
         end if
         if sUserThumbnail is not empty then
            put sUserThumbnail into tUserData["thumbnail"]
         end if
      end if
      
      rvoSetUserData tUserData, tCallBack
   end if
end setUserData

command setUserDataCallback pResult
   if pResult is "true" then
      # user has been updated so must clear cache
      # fetch user data request
      local tArray, tKey
      put "fetchUserData" into tArray["action"]
      put sUserId into tArray["parameters"]["id"]
      put revOnlineEncodeArray(tArray) into tKey      
      revOnlineCacheRemove tKey      
      # fetch user image
      put empty into tArray
      put "fetchUserProperty" into tArray["action"]
      put sUserId into tArray["parameters"]["id"]
      put "image" into tArray["parameters"]["propertyName"]
      put revOnlineEncodeArray(tArray) into tKey
      revOnlineCacheRemove tKey
      # fetch user thumbnail
      put empty into tArray
      put "fetchUserProperty" into tArray["action"]
      put sUserId into tArray["parameters"]["id"]
      put "thumbnail" into tArray["parameters"]["propertyName"]
      put revOnlineEncodeArray(tArray) into tKey
      revOnlineCacheRemove tKey
      
      # Update any instances of the users details in the searchlist group
      --send "updateListUserThumbnails sUserId" to group "search list" of this stack
      send "updateListUserDetails sUserId" to group "search list" of this stack
      
      rvoUpdateTooltip "Profile updated", empty, true        
   else if pResult is "false" then
      rvoUpdateTooltip "Profile not updated", empty, true
   else
      rvoUpdateTooltip pResult, true
   end if
   set the cUser of me to sUserId
   
end setUserDataCallback

command discardChanges
   --lock screen
   if the text of field "first name" of me is empty then
      # This case deals with a user who has pressed cancel upon first
      # editing their profile but has not entered a username
      
      updateView "list","stack"
   else
      set the cUser of me to sUserId
   end if
   --unlock screen
end discardChanges

command takeSnapshot
   if there is a group "image importer" of me then
      # Main stack image
      export snapshot from rect( \
             (the left of group "user crop box" of group "image importer" of me + 1, \
             the top of group "user crop box" of group "image importer" of me + 1, \
             the right of group "user crop box" of group "image importer" of me - 1, \
             the bottom of group "user crop box" of group "image importer" of me - 1)) \
             of window(the windowid of stack "revonline") to sUserImage as jpeg
      set the text of image "user image" of me to sUserImage
      # Stack thumbnail
      set the text of image "user image thumbnail" of group "image importer" of me to sUserImage
      export snapshot from image "user image thumbnail" of group "image importer" of me to sUserThumbnail as jpeg
      ###hide group "image importer" of me
      hidePalette
   end if
end takeSnapshot

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
      hide group "stack crop box" of group "image importer" of me
      unlock screen
      
      # Need to store original image dimensions
      lock screen
      local tOriginalHeight, tOriginalWidth
      set the text of image "user image import" of me to tImageData
      put the height of image "user image import" of me into tOriginalHeight
      put the width of image "user image import" of me into tOriginalWidth
      
      local tAspectRatio, tRequiredAspectRatio, tScaleFactor
      put (the width of group "user crop box" of me / the height of group "user crop box" of me) into tRequiredAspectRatio
      put (the width of image "user image import" of me / the height of image "user image import" of me) into tAspectRatio
      
      # Imported image has wider aspect ratio
      if tAspectRatio >= tRequiredAspectRatio then
         put (the height of group "user crop box" of me / the height of image "user image import" of me) into tScaleFactor
      end if
      
      # Imported image has taller aspect ratio
      if tAspectRatio < tRequiredAspectRatio then
         put (the width of group "user crop box" of me / the width of image "user image import" of me) into tScaleFactor
      end if
      
      # Resize the image to fit in the required space
      set the width of image "user image import" of me to the width of image "user image import" of me * tScaleFactor
      set the height of image "user image import" of me to the height of image "user image import" of me * tScaleFactor     
      
      # This reduces speed issues considerably but lowers quality of image
      local tTempImageData
      export snapshot from image "user image import" of me to tTempImageData as jpeg
      set the text of image "user image import" of me to tTempImageData
      
      set the loc of image "user image import" of me to the loc of group "user crop box" of me
      show image "user image import" of me
      put empty into field "importing" of group "image importer" of me
      unlock screen
      # To speed up subsequent resizing
      --      if tOriginalWidth > (2 * the width of group "user crop box" of me) or \
             --             tOriginalHeight > (2 * the height of group "user crop box" of me) then
      --         set the resizeQuality of image "user image import" of me to "good"
      --      else
      --         set the resizeQuality of image "user image import" of me to "best"
      --      end if     
      
   end if
end importImage


command clearContents
   --lock screen
   if there is a group "image importer" of me then
      delete group "image importer" of me
   end if
   if there is a field "background blocker" of me then
      delete field "background blocker" of me
   end if
   
   hide group "edit profile" of me
   hide field "change password" of me
   hide field "first name label" of me
   hide field "last name label" of me
   hide field "first name" of me
   put empty into field "first name" of me
   hide field "last name" of me
   put empty into field "last name" of me
   
   hide field "city label" of me
   hide field "city" of me
   hide field "state label" of me
   hide field "state" of me
   hide field "country label" of me
   hide field "country" of me
   show field "location label" of me
   show field "location" of me         
   put empty into field "name" of me
   put empty into field "email" of me
   put empty into field "city" of me
   put empty into field "state" of me
   put empty into field "country" of me   
   put empty into field "uploads" of me
   put empty into field "company" of me
   put empty into field "biography" of me
   put empty into field "upload list" of me
   put empty into field "website" of me
   put empty into field "location" of me
   
   # Rating widget
   if there is a group "rater template" of me then
      set the cantdelete of group "rater template" of me to false
      delete group "rater template" of me
   end if
   copy group "rater template" of card "templates" of this stack to me
   set the cantdelete of group "rater template" of me to false
   local tLongId
   put the long id of me into tLongId
   send "setCanRate false" to group "rater template" of me
   
   set the text of image "user image" of me to empty
   set the text of image "user thumbnail" of me to empty
   
   set the showBorder of field "city" of me to false
   set the showBorder of field "state" of me to false
   set the showBorder of field "country" of me to false
   set the showBorder of field "company" of me to false
   set the showBorder of field "website" of me to false
   set the showBorder of field "biography" of me to false
   set the showBorder of image "user image" of me to false
   set the locktext of field "city" of me to true
   set the locktext of field "state" of me to true
   set the locktext of field "country" of me to true
   set the locktext of field "company" of me to true
   set the locktext of field "biography" of me to true
   set the locktext of field "website" of me to true
   --unlock screen
end clearContents

constant kSpacing = 10

command resize pContainerRect
   set the rect of group "edit profile" of me to (item 1 of pContainerRect, the top of me, item 3 of pContainerRect, the top of me + 22)
   set the loc of field "edit profile" of group "edit profile" of me to (item 1 of the loc of group "edit profile" of me, the top of group "edit profile" of me + 10)
   set the topright of field "cancel" of me to the topright of group "edit profile" of me
   set the topright of button "cancel" of me to (the left of field "cancel" of me + 10, the top of me)
   set the topright of field "save" of me to the topleft of button "cancel" of me
   set the topright of button "save" of me to (the left of field "save" of me + 10, the top of me)
   
   if the visible of group "edit profile" of me then
      set the topleft of field "name" of me to (item 1 of pContainerRect, the bottom of group "edit profile" of me + 2)
      set the topleft of field "first name label" of me to (item 1 of pContainerRect + kSpacing, the bottom of group "edit profile" of me + 4)
   else
      set the topleft of field "name" of me to (item 1 of pContainerRect, the top of me)
      set the topleft of field "first name label" of me to (item 1 of pContainerRect + kSpacing, the top of me + 2)
   end if
   set the topleft of field "last name label" of me to (item 1 of pContainerRect + kSpacing, the bottom of field "first name label" of me + 2)   
   set the topleft of field "email label" of me to (item 1 of pContainerRect + kSpacing, the bottom of field "name" of me + kSpacing)
   set the topleft of field "location label" of me to (item 1 of pContainerRect + kSpacing, the bottom of field "email label" of me + 1)
   set the topleft of field "city label" of me to (item 1 of pContainerRect + kSpacing, the bottom of field "email label" of me + 1)
   set the topleft of field "state label" of me to (item 1 of pContainerRect + kSpacing, the bottom of field "city label" of me + 1)
   set the topleft of field "country label" of me to (item 1 of pContainerRect + kSpacing, the bottom of field "state label" of me + 1)
   
   set the rect of field "first name" of me to \
          (the right of field "first name label" of me, the top of field "first name label" of me, \
          min(item 3 of pContainerRect,the right of field "email label" of me + 365), the bottom of field "first name label" of me)  
   set the rect of field "last name" of me to \
          (the right of field "last name label" of me, the top of field "last name label" of me, the right field "first name" of me, the bottom of field "last name label" of me)
   set the topleft of field "email" of me to (the left of field "first name" of me, the top of field "email label" of me)
   set the topleft of field "city" of me to (the left of field "first name" of me, the top of field "city label" of me)
   set the topleft of field "state" of me to (the left of field "first name" of me, the top of field "state label" of me)
   set the topleft of field "country" of me to (the left of field "first name" of me, the top of field "country label" of me)
   set the topleft of field "state" of me to (the left of field "first name" of me, the top of field "state label" of me)
   set the rect of field "location" of me to \
          (the left of field "first name" of me, the top of field "location label" of me, the right of field "city" of me, the bottom of field "city" of me)
   set the height of field "location" of me to the formattedheight of field "location" of me
   
   if the visible of field "location" of me then
      set the topleft of field "company label" of me to (item 1 of pContainerRect + kSpacing, the bottom of field "location" of me - 8)
   else
      set the topleft of field "company label" of me to (item 1 of pContainerRect + kSpacing, the bottom of field "country label" of me + 1)
   end if
   set the topleft of field "website label" of me to (item 1 of pContainerRect + kSpacing, the bottom of field "company label" of me + 1)
   set the topleft of field "uploads label" of me to (item 1 of pContainerRect + kSpacing, the bottom of field "website label" of me + 1)
   set the topleft of field "average upload rating label" of me to (item 1 of pContainerRect + kSpacing, the bottom of field "uploads label" of me + 1)
   
   set the topright of image "user image" of me to (the right of field "first name" of me, the top of field "email label" of me)
   
   set the topleft of field "company" of me to (the left of field "first name" of me, the top of field "company label" of me)
   set the topleft of field "website" of me to (the left of field "first name" of me, the top of field "website label" of me)
   set the topleft of field "uploads" of me to (the left of field "first name" of me, the top of field "uploads label" of me)
      
   set the topleft of image "user thumbnail" of me to the topleft of image "user image" of me
   set the bottomright of image "user pencil" of me to (the right of image "user image" of me - 6, the bottom of image "user image" of me - 6)
   if there is a group"rater template" of me then
      set the topleft of group "rater template" of me to (the right of field "average upload rating label" of me +  kSpacing, the top of field "average upload rating label" of me + 4)
   end if
   set the topleft of field "change password" of me to (the left of image "user image" of me - 7, the top of field "uploads" of me)
   set the topleft of button "show email" of me to (the left of image "user image" of me, the top of field "average upload rating label")
   
   
   set the points of graphic "user divider" of me to \
          (item 1 of pContainerRect + 18, the bottom of field "average upload rating label" of me + 20) & return & \
          (item 3 of pContainerRect - 18, the bottom of field "average upload rating label" of me + 20)
   
   set the topright of field "recent uploads label" of me to (item 3 of pContainerRect - kSpacing - 20, the bottom of graphic "user divider" of me + 10)
   set the rect of field "upload list" of me to \
          (min(item 3 of pContainerRect - the formattedwidth of field "upload list" of me - 2, the left of field "recent uploads label" of me), \
          the bottom of field "recent uploads label" of me, item 3 of pContainerRect - kSpacing - 20, \
          the bottom of field "recent uploads label" of me + the formattedheight of field "upload list" of me + 5)
   set the rect of field "biography" of me to \
          (item 1 of pContainerRect + kSpacing, the bottom of graphic "user divider" of me + 10, the left of field "upload list" of me - 10, \
          max(the top of field "biography" of me + the formattedheight of field "biography" of me + 5, item 4 of pContainerRect - 10))
   set the topright of button "edit" of me to (item 3 of pContainerRect, the top of me + 1)
   set the topright of button "discard" of me to (item 3 of pContainerRect, the top of me + 1)
   set the topright of button "commit" of me to (the left of button "discard" of me - 2, the top of me + 1)
end resize


command hidePalette
   lock screen
   if there is a field "background blocker" of me then
      delete field "background blocker" of me
   end if
   if there is a group "image importer" of me then
      delete group "image importer" of me
   end if
   unlock screen
end hidePalette


command showHideEmail
   if the text of field "email" of me is revOnlineEmail() then
      put "(hidden)" into field "email" of me
   else
      put revOnlineEmail() into field "email" of me
   end if
end showHideEmail










