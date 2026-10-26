script "stack_A_Data_Grid_Tour"
-- Stack file: ide/Resources/Examples/Remastered/A Data Grid Tour.oxtstack
-- Object: stack "A Data Grid Tour"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--A Data Grid Tour: LiveCode Ltd's Data Grid Tour v1.0, remastered for OXT-Beyond in 2026
--Data Grid Tour v1.0, (c) LiveCode Ltd., edited and debranded for open source as requested by LiveCode Ltd.

--Each stop of the tour is a card. The sidebar, the header, the stage and the scripts drawer are the
--groups "Frame", "Workbench" and "Scripts", which the script of the group "Frame" runs: they take the
--place of the tour's own title bar, page slider and Back and Next buttons (its group "Chrome").

--(remaster) Where the wheel is taking a field and which field, and where a drag of a thumb began
local sGlideGoal, sGlideField, sDragField, sDragFrom, sDragScroll

on openStack
   choose browse tool
   --added: a word, if the IDE's data grid library is not there to draw the grids
   if there is not a stack "revDataGridLibrary" then
      answer "The data grids on these cards need the IDE's data grid library, and it is not loaded." &cr& \
            "In Preferences, under Compatibility, untick Disable Data Grids, then start the IDE again." with "OK" titled "A Data Grid Tour"
   end if
end openStack

on preOpenCard  --(remaster) the code on the card in the scripts panel's font; a glide stops, and each field the wheel scrolls is at its top, with its thumb
   local tIndex, tField, tFont
   put empty into sGlideGoal
   put empty into sDragField
   put codeFontHere() into tFont
   repeat with tIndex = 1 to the number of fields of this card
      put the long id of field tIndex of this card into tField
      if tFont is not empty and the cCode of tField is true and the textFont of tField is not tFont then
         set the textFont of tField to tFont
      end if
      if the cWheel of tField is true then
         set the vScroll of tField to 0
         wheelSync tField
      end if
   end repeat
   pass preOpenCard
end preOpenCard

function codeFontHere  --(remaster) code's font: the scripts panel's (the window finds it before this stack's preOpenCard), or else the first of its choices this computer has
   local tFont
   if there is a field "codeText" then
      if the textFont of field "codeText" is not empty then return the textFont of field "codeText"
   end if
   repeat for each item tFont in "Source Code Pro,Droid Sans Mono,Menlo,Consolas,DejaVu Sans Mono,Courier New"
      if tFont is among the lines of the fontNames then return tFont
   end repeat
   return empty
end codeFontHere

--(remaster) A field that holds more than it shows (its custom property cWheel is true) scrolls with the
--wheel, without a scrollbar, as the scripts panel does: the slim thumb at its right (the graphic its
--cThumb names) shows how far down it is, and can be dragged.

on rawKeyDown pKey
   local tField, tGliding
   if pKey is not 65308 and pKey is not 65309 then pass rawKeyDown  --the wheel, down or up
   put wheelField() into tField
   if tField is empty then pass rawKeyDown
   put sGlideGoal is not empty into tGliding  --a glide under way takes the new goal (a second one beside it would double its speed)
   if not tGliding or tField is not sGlideField then put the vScroll of tField into sGlideGoal
   put tField into sGlideField
   if pKey is 65308 then add 48 to sGlideGoal
   else subtract 48 from sGlideGoal
   put max(0, min(sGlideGoal, wheelRoom(tField))) into sGlideGoal
   if not tGliding then wheelGlide
end rawKeyDown

on wheelGlide  --one step of the scroll toward where the wheel is taking it
   local tNow, tStep
   if sGlideGoal is empty or sGlideField is empty or not exists(sGlideField) then
      put empty into sGlideGoal
      exit wheelGlide
   end if
   put the vScroll of sGlideField into tNow
   put round((sGlideGoal - tNow) * 0.35) into tStep
   if abs(sGlideGoal - tNow) <= 1 or tStep is 0 then
      set the vScroll of sGlideField to sGlideGoal
      put empty into sGlideGoal
   else
      set the vScroll of sGlideField to tNow + tStep
      if the vScroll of sGlideField is tNow then put empty into sGlideGoal  --it did not move: it is at its end, and the glide is over
      else send "wheelGlide" to me in 16 milliseconds
   end if
   wheelSync sGlideField
end wheelGlide

function wheelField  --the field under the pointer that the wheel scrolls (or whose thumb it is over), or empty
   local tControl
   put the mouseControl into tControl
   if tControl is empty then return empty
   put the long id of tControl into tControl
   if word 1 of tControl is "field" and the cWheel of tControl is true then return tControl
   if word 1 of tControl is "graphic" and the cField of tControl is not empty then
      return the long id of fld (the cField of tControl)
   end if
   return empty
end wheelField

function wheelRoom pField  --how far down a field goes: measured, as the engine stops a field's scroll a few pixels short of its formattedHeight less its height
   local tNow, tRoom, tLocked
   put the vScroll of pField into tNow
   put the lockMessages into tLocked
   lock screen
   lock messages
   set the vScroll of pField to the formattedHeight of pField + the height of pField
   put the vScroll of pField into tRoom
   set the vScroll of pField to tNow
   set the lockMessages to tLocked
   unlock screen
   return max(0, tRoom)
end wheelRoom

command wheelSync pField  --the field's thumb: as long as the share of the field it shows, as far down as the field is
   local tThumb, tRoom, tTrack, tSize, tTop
   if pField is empty or not exists(pField) then exit wheelSync
   put the cThumb of pField into tThumb
   if tThumb is empty or there is no grc tThumb then exit wheelSync
   put wheelRoom(pField) into tRoom
   if tRoom < 8 then
      hide grc tThumb
      exit wheelSync
   end if
   put the height of pField - 16 into tTrack
   put max(24, round(tTrack * tTrack / (tTrack + tRoom))) into tSize
   put the top of pField + 8 + round((tTrack - tSize) * min(1, the vScroll of pField / tRoom)) into tTop
   set the rect of grc tThumb to item 1 of the rect of grc tThumb, tTop, item 3 of the rect of grc tThumb, tTop + tSize
   show grc tThumb
end wheelSync

on mouseDown pButton  --a thumb, dragged: its field goes as far down as it does
   if pButton is 1 and word 1 of the target is "graphic" and the cField of the target is not empty then
      put the long id of fld (the cField of the target) into sDragField
      put item 2 of the mouseLoc into sDragFrom
      put the vScroll of sDragField into sDragScroll
      put empty into sGlideGoal
   end if
   pass mouseDown
end mouseDown

on mouseMove pX, pY
   local tTrack, tRoom
   if sDragField is empty then pass mouseMove
   if the mouse is up or not exists(sDragField) then
      put empty into sDragField
      pass mouseMove
   end if
   put the height of sDragField - 16 - the height of grc (the cThumb of sDragField) into tTrack
   if tTrack > 0 then
      put wheelRoom(sDragField) into tRoom
      set the vScroll of sDragField to max(0, min(tRoom, sDragScroll + round((pY - sDragFrom) * tRoom / tTrack)))
      wheelSync sDragField
   end if
   pass mouseMove
end mouseMove

on mouseUp pButton
   put empty into sDragField
   pass mouseUp
end mouseUp

on mouseRelease pButton
   put empty into sDragField
   pass mouseRelease
end mouseRelease
