script "stack_revResourceCenter_card_id_433723"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Video Viewer" (id 433723)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sSource
local sStackRect
local sArmedLink
constant kPlayerControlHeight = 20

on preOpenCard
   -----------------
   put empty into sArmedLink
   if sSource is not empty then
      set the filename of player 1 to sSource
      start player 1
   end if
end preOpenCard

on openCard
    resizePlayer
end openCard



on resizePlayer
   local tNewWidth, tNewHeight, tWidth, tHeight, tAvailableWidth, tAvailableHeight
   
   put the width of player 1 into tWidth
   put the height of player 1 into tHeight
   
   -- Find out the width and height available for the player.
   put (the right of me - (the right of button "resizeButton")) into tAvailableWidth
   put (the top of image "footer" - the bottom of image "topBanner") into tAvailableHeight
   
   
   
   -- Want the player to be as big as possible
   local tUsedWidthPercentage
   put tWidth into tUsedWidthPercentage
   divide tUsedWidthPercentage by tAvailableWidth
   --put the result into tUsedWidthPercentage
   
   --put tAvailableWidth divide tWidth into tUsedWidthPercentage
   local tMultiple
   if tUsedWidthPercentage < 1 then --not using whole space
      local tLeftOverWidth, tLeftOverWidthPercent
      put 1 - tUsedWidthPercentage into tLeftOverWidth
      put tLeftOverWidth + 1 into tLeftOverWidthPercent
      
      
      put tLeftOverWidthPercent into tMultiple
      
      repeat while tMultiple is not 1 
         if (tHeight * tLeftOverWidthPercent) <= tAvailableHeight then
            put tHeight * tLeftOverWidthPercent into tNewHeight
            put tWidth * tLeftOverWidthPercent into tNewWidth
            exit repeat
         else 
            put tMultiple - 0.01 into tMultiple
            put tMultiple into tLeftOverWidthPercent
         end if
      end repeat
   else if tUsedWidthPercentage > 1 then
      -- the player is to wide to fit into the available space
      put tUsedWidthPercentage - 1 into tMultiple
      put 1 - tMultiple into tMultiple
      put tMultiple into tLeftOverWidthPercent
      repeat while tMultiple is not 0
         if (tHeight * tMultiple) <= tAvailableHeight then
            put tHeight * tLeftOverWidthPercent into tNewHeight
            put tWidth * tLeftOverWidthPercent into tNewWidth
            exit repeat
         else
            put tMultiple - 0.01 into tMultiple
            put tMultiple into tLeftOverWidthPercent
         end if
      end repeat
   else
      -- width fits perfectly
      if tHeight <= tAvailableHeight then
         put tWidth into tNewWidth
         put tHeight into tNewHeight
      else
         -- need to reduce the width to a ratio where the height also fits
         put 0.9 into tMultiple
         repeat while tMultiple > 0
            if (tHeight * tMultiple) < tAvailableHeight then
               put tWidth * tMultiple into tNewWidth
               put tHeight * tMultiple into tNewHeight
               exit repeat
            else
               put tMultiple - 0.1 into tMultiple
            end if
         end repeat
      end if
   end if
   
   set the width of player 1 to tNewWidth
   set the height of player 1 to tNewHeight
   set the location of player 1 to (the right of button "resizeButton" of me + (tAvailableWidth div 2)), (the bottom of image "topBanner" + (tAvailableHeight div 2))
   
   
   
   
   
   
   
   
end resizePlayer

on mouseMove
  if the short name of the target is not "results" then
    pass mouseMove
  end if
   
  if the mouseChunk is not empty and the linkText of the mouseChunk is not empty then
    if sArmedLink is empty then
      put the mouseChunk into sArmedLink
      set the foregroundColor of the mouseChunk to the cLinkOverCol of this stack
    end if
  end if
  if the mouseChunk <> sArmedLink and sArmedLink is not empty then
    set the foregroundColor of sArmedLink to empty
    put empty into sArmedLink
  end if
  
  pass mouseMove
end mouseMove


on closeCard
  stop player 1
  --if sStackRect is not empty then
    --set the rect of this stack to sStackRect
  --end if
  --put empty into sStackRect
  pass closeCard
end closeCard

on resizeCard pOldWidth, pOldHeight, pNewWidth, pNewHeight
--  lock screen
--  set the width of player 1 to the width of me
--  set the height of player 1 to the height of me - the cNavBarHeight of this stack
--  set the left of player 1 to the left of me
--  set the top of player 1 to the top of me + the cNavBarHeight of this stack
--  unlock screen
end resizeCard

setProp cSource pValue
  put pValue into sSource
end cSource

getProp cSource 
  return sSource
end cSource

on searchCard pSearchString
  -- this card has no searchable content
end searchCard

on resourceDownloadCompleted pStatus
   if pStatus is "downloaded" then
      set the visible of scrollbar "Progress" to false
      set the location of field "DownloadTitle" to "526,424"
   end if
end resourceDownloadCompleted
