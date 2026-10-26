script "stack_revOnline_group_id_4036476"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "search list" (id 1691) > group "Object 243" (id 4036460) > group "Rater Template" (id 4036476)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

################################################################################
# Public interface
################################################################################

local sRating
local sCanRate = "true"
local sCallback
local sCallbackTarget
local sId

# Parameters
#   pRating : a number between 0 and 5, can be fractional.
# Description
#   Tells the widget to display the specified rating. If this command is not called, the widget will have
#   undefined appearance (i.e. however it was last saved).
command setRating pRating
   put pRating into sRating
   updateRating
end setRating

# Parameters
#   pCanRate : true or false
# Description
#   Tells the widget whether or not to allow ratings. If true, then the widget will handle mouseEnter and mouseLeave
#   to allow the user to rate. The default will be false.
command setCanRate pCanRate
   put pCanRate into sCanRate
end setCanRate

# Parameters
#   pCallback : the name of the command to call when the user tries to rate something
#   pCallbackTarget : where to send the callback to.
# Description
#   Tells the widget what to do when the user rates something. If empty, nothing will happen.
command setRateCallback pCallback, pCallbackTarget
   put pCallback into sCallback
   put pCallbackTarget into sCallbackTarget
end setRateCallback

# Parameters
#   pId : this can be any value you wish to identify the widget by. Its up to the caller to make it unique
# Description
#   The id will be sent with the callback to identify which widget each callback came from.
command setId pId
   put pId into sId
end setId

################################################################################
# Private stuff
################################################################################

private function createStar pSize, pName, pTopLeft, pGroup, pTemplate
   if there is an image pTemplate of me then
      delete image pTemplate of me
   end if
   
   # Change this line to contain a valid reference to the template star, whenever that will be kept.
   # Alternatively, create a perfect five-pointed star dynamically :)
   copy pTemplate to pGroup
   set the name of image (the short name of pTemplate) of me to pName
   
   local tStar
   put the long id of image pName of group (the short name of pGroup) of me into tStar
   set the width of tStar to pSize
   set the height of tStar to pSize
   set the topLeft of tStar to pTopLeft
   set the cStar of tStar to true
   
   return tStar
end createStar

local sUpdateRatingRequest

# This is not designed to be called from outside the widget (although doing so will probably not do any harm...)
command updateRating
   if sUpdateRatingRequest is not empty then
      cancel sUpdateRatingRequest
   end if
   
   lock screen
   purgeStars
   createMessageCatcher
   
   ###createStarGroup the long id of graphic "template blank star" of card "templates" of this stack, "blank stars"
   createStarGroup the long id of image "template blank star" of card "templates" of this stack, "blank stars"
   createStarGroup the long id of image "template star" of card "templates" of this stack, "stars"
   local tLeft
   put the left of group "Stars" of me into tLeft
   
   local tNewWidth
   put round(the width of group "Stars" of me * (sRating / 5)) into tNewWidth
   
   set the width of group "Stars" of me to tNewWidth
   set the left of group "Stars" of me to tLeft
   
   unlock screen
end updateRating

private command createStarGroup pTemplateId, pGroupName
   create group pGroupName in me
   set the margins of group pGroupName of me to 0
   
   local tLeft, tTop
   put the left of me into tLeft
   put the top of me into tTop
   
   local tStarSize
   put starSize() into tStarSize
   
   local tStar
   repeat with x = 1 to 5
      put createStar(tStarSize, "Star " & x, (tLeft, tTop), the long id of group pGroupName of me, pTemplateId) into tStar
      add tStarSize + 2 to tLeft
   end repeat
   
   set the lockLocation of group pGroupName of me to true
end createStarGroup

private command createMessageCatcher
   if there is a graphic "Message Catcher" of me then
      delete graphic "Message Catcher" of me
   end if
   
   reset the templateGraphic
   set the opaque of the templateGraphic to true
   set the lineSize of the templateGraphic to 0
   
   # These two things make the message catcher invisible, while still allowing it to receive messages.
   set the backgroundColor of the templateGraphic to "0,0,0"
   set the ink of the templateGraphic to "srcOr"
   
   set the lockLocation of the templateGraphic to true
   set the rect of the templateGraphic to the rect of me
   create graphic "Message Catcher" in me
   reset the templateGraphic
end createMessageCatcher

private function starSize
   return min(the height of me, the width of me div 5)
end starSize

private command purgeStars
   if there is a group "Stars" of me then
      delete group "Stars" of me
   end if
    if there is a group "blank Stars" of me then
      delete group "blank Stars" of me
   end if
end purgeStars

on mouseMove
   if not sCanRate then
      pass mouseMove
   end if
   
   # This is just to prevent annoying error messages when developing / debugging.
   if there is no group "Stars" of me then
      pass mouseMove
   end if
   
   local tLeft
   put the left of group "Stars" of me into tLeft
   
   local tNewWidth
   put item 1 of the mouseLoc - tLeft into tNewWidth
   if tNewWidth < 0 then
      put 0 into tNewWidth
   end if
   
   # The new width needs to be rounded so that only whole stars can be chosen.
   put roundWidthToNearestWholeStar(tNewWidth) into tNewWidth
   
   set the width of group "Stars" of me to tNewWidth
   set the left of group "Stars" of me to tLeft
end mouseMove

private function roundWidthToNearestWholeStar pWidth
   local tStarCount
   put pWidth / starSize() into tStarCount
   
   return (starSize() + 2) * round(tStarCount)
end roundWidthToNearestWholeStar

on mouseEnter
   if sUpdateRatingRequest is not empty then
      cancel sUpdateRatingRequest
   end if
   pass mouseEnter
end mouseEnter

on mouseLeave
   # This is sent in time because otherwise Revolution crashes, and also to allow the mouse to leave the group.
   # The crash is something to do with the fact that updateRating deletes the group that owns the focusedObject,
   # leaving a dangling focusedObject pointer in the engine.
   if sUpdateRatingRequest is not empty then
      cancel sUpdateRatingRequest
   end if
   
   send "updateRating" to me in 50 milliseconds
   put the result into sUpdateRatingRequest
end mouseLeave

on mouseUp
   if not sCanRate then
      pass mouseUp
   end if
   
   if sUpdateRatingRequest is not empty then
      cancel sUpdateRatingRequest
   end if
   
   # Work out what the new rating should be, and update to it for now,
   # then send the callback. Note that it is left up to the callback target to 
   # decide if the rating is permitted, and if not, to refresh this widget again
   # so that the correct rating is shown.
   local tWidth
   put the width of group "Stars" of me into tWidth
   
   # This should always come out as a whole number...
   local tStarCount
   put tWidth / (starSize() + 2) into tStarCount
   if tStarCount is not an integer then
      breakpoint
   end if
   
   put tStarCount into sRating
   put false into sCanRate
   updateRating
   
   if sCallback is not empty and there is a (sCallbackTarget) then
      try
         send sCallback && sId & comma & tStarCount to sCallbackTarget
      catch tError
         log "Error sending callback: "
         log "--------------------------------"
         log "sCallback: " & sCallback
         log "sCallbackTarget: " & sCallbackTarget
         log "Error: "
         log tError
         log "--------------------------------"
      end try
   end if
end mouseUp

command log pMessage
   put pMessage & return after msg
end log
