script "stack_revOnline_button_id_1325692"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > button "Scrollbar" (id 1325692)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

# OK-2009-01-17: Simplifed code and reduced the size of the control's interface by removing
# extra calls / custom props. Also got rid of code for horizontal scrolling to make it easier to read.

# New interface.
# set the cControl of tBar to <long id of field or group to scroll>
# send "update" to tBar
#
# Additional update methods should typically be sent in these situations:
# 1. The target is made bigger (specifically, its height changes)
# 2. The target's formattedHeight changes (i.e it gains or loses content)
# 3. The target's vscroll is changed by something other than this scrollbar (e.g. mouse wheel)


local sControl -- reference to control to act on
local sThumbPosition -- the thumbposition
local sStartValue -- start value of scrollbar (same as scrollbar object in Rev)
local sEndValue -- end value of scrollbar (same as scrollbar object in Rev)
local sThumbSize -- Size of the slider. This must be between the start and end value
local sUpdateLock -- whether or not update is locked. Use this to make multiple changes
local sLineInc -- amount the scrollbar moves when the arrows are clicked
local sPageInc -- how far the scrollbar moves when the user clicks on the background
local sDisabled -- whether the scrollbar is disabled

-- Private state variables
local sDrag = "false" -- Whether the user is dragging the slider
local sMousedown = "false" -- whether the mouse button is down
local sDifference = "" -- Used to store distance between mouseLoc and edge of slider
local sMouseState -- Array storing controls the mouse is over, eg sMouseState["slider"] = over when mouse is over it
local sImageOrientation = "vertical" -- the orientation of the slider images.

-- Constants
constant kButtonSize = 23 -- The size of the two end buttons
constant kScrollRate = 25 -- In milliseconds

setProp cControl pControl
   put the long id of pControl into sControl
end cControl

getProp cControl
   return sControl
end cControl

setProp cDisabled pValue
   if pValue is not among the items of "true,false" then
      error "invalid disabled parameter, expected Boolean, got " & pValue
   end if
   set the disabled of button "end1" of me to pValue
   set the disabled of button "end2" of me to pValue
   set the visible of group "slider" of me to not pValue
   put pValue into sDisabled
end cDisabled

getProp cDisabled
   return sDisabled
end cDisabled

command update
   local tMaxScroll
   put controlMaxScroll(sControl) into tMaxScroll
   
   set the rect of me to the right of sControl, the top of sControl, the right of sControl + 19, the bottom of sControl
   
   local tHeight, tFormattedHeight
   put the height of sControl into tHeight
   put the formattedHeight of sControl into tFormattedHeight
   
   put the vScroll of sControl into sThumbPosition
   put 20 into sLineInc
   put tHeight into sPageInc
   put 0 into sStartValue
   put tFormattedHeight into sEndValue
   put tHeight into sThumbSize
   
   if the formattedHeight sControl >= the height of sControl then
      set the cDisabled of me to false
   else
      set the cDisabled of me to true
   end if
   updateDo
end update

private command updateDo
   local tResult
   put updateCheckParams() into tResult
   if tResult is not empty then
      error tResult
   end if
   
   updateLayout
   updateControl
end updateDo

-- Returns empty if all ok, otherwise returns an error description
private function updateCheckParams
   -- Check none are empty
   if sControl is empty then
      return "sControl is empty"
   end if
   
   if sThumbPosition is empty then
      return "sThumbPosition is empty"
   end if
   
   if sStartValue is empty then
      return "sStartValue is empty"
   end if
   
   if sEndValue is empty then
      return "sEndValue is empty"
   end if
   
   if sThumbSize is empty then
      return "sThumbSize is empty"
   end if
   
   if sLineInc is empty then
      return "sLineInc is empty"
   end if
   
   if sPageInc is empty then
      return "sPageInc is empty"
   end if
   
   -- Apply constraints
   if sStartValue >= sEndValue then
      return "start value must be less than end value"
   end if
   
   if sThumbPosition < sStartValue then
      put sStartValue into sThumbPosition
      --return "thumb position must be greater than or equal to start value"
   end if
   
   if sThumbPosition > sEndValue - sThumbSize then
      put sEndValue - sThumbSize into sThumbPosition
      --return "thumb position must be less than or equal to end value"
   end if
   
   if the cDisabled of me is not true then
      if sThumbSize > (sEndValue - sStartValue) then
         return "thumb size must be less than difference between end value and start value"
      end if
   end if
   
   return empty
end updateCheckParams

-- Layout the scrollbar elements
private command updateLayout
   local tRatio, tSliderLength
   
   put scrollbarRatio() into tRatio
   
   set the top of button "end1" of me to the top of me
   set the loc of button "end1" of me to (item 1 of the loc of me), (item 2 of the loc of button "end1" of me)
   
   set the bottom of button "end2" of me to the bottom of me
   set the loc of button "end2" of me to (item 1 of the loc of me), (item 2 of the loc of button "end2" of me)
   
   set the height of image "background" of me to the top of button "end2" of me - the bottom of button "end1" of me
   set the top of image "Background" of me to the bottom of button "end1" of me
   set the loc of image "Background" of me to (item 1 of the loc of me), (item 2 of the loc of image "Background" of me)
   
   if not sDisabled then
      set the height of group "Slider" of me to (the bottom of button "end1" of me + (tRatio * (sThumbPosition + sThumbSize))) - (the bottom of button "end1" of me + (sThumbPosition * tRatio))
      set the top of group "Slider" of me to (the bottom of button "end1" of me + (sThumbPosition * tRatio))
      set the loc of group "Slider" of me to (item 1 of the loc of me), (item 2 of the loc of group "Slider" of me)
   end if
   
   updateLayoutSlider
end updateLayout

-- lays out the slider group. 
-- The group has 4 images, the two ends, the middle and the icon.
-- These images have data placed into from the from array sImages,
-- depending on whether the state of the slider
private command updateLayoutSlider
   local tGroup, tPropname, tImageData, tImage
   local tSliderMidLength
   
   put the long id of group "Slider" of me into tGroup
   
   set the top of image "slider_end1" of tGroup to the top of tGroup
   set the loc of image "slider_end1" of tGroup to (item 1 of the loc of tGroup), (item 2 of the loc of image "slider_end1" of tGroup)
   
   set the bottom of image "slider_end2" of tGroup to the bottom of tGroup
   set the loc of image "slider_end2" of tGroup to (item 1 of the loc of tGroup), (item 2 of the loc of image "slider_end2" of tGroup)
   
   put the top of image "slider_end2" of tGroup - the bottom of image "slider_end1" of tGroup into tSliderMidLength
   
   -- Make sure the height is not set to 0 to prevent crash
   if tSliderMidLength < 1 then
      put 1 into tSliderMidLength
   end if
   
   set the height of image "slider_mid" of tGroup to tSliderMidLength
   set the top of image "slider_mid" of tGroup to the bottom of image "slider_end1" of tGroup
   set the loc of image "slider_mid" of tGroup to (item 1 of the loc of tGroup), (item 2 of the loc of image "slider_mid" of tGroup)
   
   set the loc of button "slider_icon" of tGroup to the loc of image "slider_mid" of tGroup
end updateLayoutSlider

-- Update the attached control
private command updateControl
   set the vScroll of sControl to round(sThumbPosition)
end updateControl

-- Returns the ratio between the endvalue - startvalue of the scrollbar
-- and the actual length of the scrolling area.
private function scrollbarRatio
  return scrollbarLength() / (sEndValue - sStartValue)
end scrollbarRatio

-- Returns the length of the scrollable area
private function scrollbarLength
   return the height of me - (the height of button "end1" of me + the height of button "end2" of me)
end scrollbarLength

-- Returns the maximum scroll value of a control
-- pControl is a reference to the control,
-- pOrientation is "horizontal" or "vertical"
private function controlMaxScroll pControl, pOrientation
   local tScroll, tOldScroll
   
   messagesLock
   lock screen
   put the vScroll of pControl into tOldScroll
   set the vScroll of pControl to 65535
   put the vScroll of pControl into tScroll
   set the vScroll of pControl to tOldScroll
   unlock screen
   messagesUnlock
   
   return tScroll
end controlMaxScroll

-- The mouse can only be over or down on one object at a time
-- so if setting over or down, make sure all other objects are
-- normal. If setting normal, just do that.
private command mouseStateSet pObject, pState
  if pState is not among the items of "normal,over,down,disabled" then
    error "invalid state " & pState
  end if
  
  if pState is among the items of "over,down" then
    repeat for each key tKey in sMouseState
      put "normal" into sMouseState[tKey]
    end repeat
  end if
  
  put pState into sMouseState[pObject]
end mouseStateSet

-- Resets all mouse states to normal
private command mouseStateReset
  repeat with x=1 to the number of controls of me
    put "normal" into sMouseState[the short name of control x of me]
  end repeat
end mouseStateReset

-- Given a target reference, pControl, returns the long id
-- of the real target to use. This allows us to ignore the 
-- images in the scrollbar group and deal with the group only
private function targetResolve pControl
  local tName
  put the short name of pControl into tName
  if char 1 to 6 of tName is "slider" or the long id of the owner of pControl is the long id of group "slider" of me then
    return the long id of group "Slider" of me
  end if
  return the long id of pControl
end targetResolve

on mouseDown pButton
   local tTarget, tTargetId
   put true into sMousedown
   if sDisabled then
      pass mouseDown
   end if
   put the short name of the target into tTarget
   put targetResolve(the long id of the target) into tTargetId
   mouseStateSet tTarget, "down"
   if the short name of tTargetId is "Slider" and pButton is 1 then
      put true into sDrag
      -- Calculate the distance from the mouse to the left of the button
      local tMouseloc
      put the clickV into tMouseloc
      put (tMouseloc - the top of group "slider" of me) / scrollbarRatio() into sDifference
   end if
   if the short name of tTargetId is among the items of "End1,End2" then
      send "mouseDownCallback tTarget" to me in kScrollrate milliseconds
   end if
   pass mouseDown
end mouseDown

command mouseDownCallback pName
   if not sMouseDown then
      exit mouseDownCallback
   end if 
   if pName is "End1" then
      put max(sThumbPosition - sLineInc, 0) into sThumbPosition
   end if
   if pName is "End2" then
      put min(sThumbPosition + sLineInc, sEndValue - sThumbSize) into sThumbPosition
   end if
   updateDo
   send "mouseDownCallback pName" to me in kScrollrate milliseconds
end mouseDownCallback

on mouseUp
   local tTarget
   put targetResolve(the long id of the target) into tTarget
   put false into sMousedown
   put false into sDrag
   if sDisabled then
      pass mouseUp
   end if
   
   mouseStateSet tTarget, "over"
   if the short name of tTarget is "End1" then
      put max(sThumbPosition - sLineInc, 0) into sThumbPosition
      updateDo
   end if
   if the short name of tTarget is "End2" then
      put min(sThumbPosition + sLineInc, sEndValue - sThumbSize) into sThumbPosition
      updateDo
   end if
   
   if the short name of tTarget is "Background" then
      if the mouseV < the top of group "slider" of me then
         put max(sThumbPosition - sPageInc, 0) into sThumbPosition
      else
         put min(sThumbPosition + sPageInc, sEndValue - sThumbSize) into sThumbPosition
      end if
      updateDo
   end if
end mouseUp

on mouseRelease
  local tTarget
  put targetResolve(the long id of the target) into tTarget
  mouseStateReset
  put false into sMousedown
  put false into sDrag
  pass mouseRelease
end mouseRelease

on mouseMove
   if sDisabled then 
      pass mouseMove
   end if
   
   if sDrag is false then
      exit mouseMove
   end if
   
   lock screen 
   local tVarloc, tRatio, tDiff, tPosition, tTarget
   put targetResolve(the long id of the target) into tTarget
   
   put scrollbarRatio() into tRatio
   put the mouseV / tRatio into tVarloc
   put (tVarloc - (the bottom of button "end1" of me / tRatio)) - sDifference into tPosition
   
   if tPosition > sStartValue and tPosition < (sEndValue - sThumbSize) then
      put tPosition into sThumbPosition
      updateDo
   end if
   
   if tPosition <= sStartValue then
      put sStartValue into sThumbPosition
      updateDo
   end if
   if tPosition >= (sEndValue - sThumbSize) then
      put (sEndValue - sThumbSize) into sThumbPosition
      updateDo
   end if
   
   unlock screen
   pass mouseMove
end mouseMove

on mouseEnter
  local tTarget
  put targetResolve(the long id of the target) into tTarget
  mouseStateSet the long id of tTarget, "over"
end mouseEnter

on mouseLeave
  local tTarget
  put targetResolve(the long id of the target) into tTarget
  mouseStateReset
end mouseLeave

private command error pMsg
   --breakpoint
   log pMsg
   --exit to top
end error

private command log pMessage
   put pMessage & return after msg
end log

local sMessageLockDepth

private command messagesLock
  lock messages
  add 1 to sMessageLockDepth
end messagesLock

private command messagesUnlock
   unlock messages
   if sMessageLockDepth > 0 then subtract 1 from sMessageLockDepth
end messagesUnlock


on rawkeydown pKey
   if pKey is 65308 then
      scrollUp
   else if pKey is 65309 then
      scrollDown
   end if
end rawkeydown


command scrollUp
   local tScrollValue
   put round(the formattedheight of sControl / 20) into tScrollValue
   set the vScroll of sControl to (the vScroll of sControl + tScrollValue)
   update
end scrollUp

command scrollDown
   local tScrollValue
   put round(the formattedheight of sControl / 20) into tScrollValue
   set the vScroll of sControl to (the vScroll of sControl - tScrollValue)
   update
end scrollDown

