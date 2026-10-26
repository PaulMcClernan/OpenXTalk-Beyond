script "stack_Data_Grid_Tables"
-- Stack file: ide/Resources/Examples/Remastered/Data Grid Tables.oxtstack
-- Object: stack "Data Grid Tables"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--Data Grid Tables: Terry Little's DataGrid Table v1.0, remastered for OXT-Beyond in 2026
--DataGrid Table v1.0, Terry Little, c 2022.
--This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
--as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
--You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

--Each lesson is a card: its data grid and the things to try at the left of the stage, and the lesson's
--notes at the right (the field "Info", in the background group "Notes", as Terry's was in the group
--"Nav"). The sidebar, the header, the stage and the scripts drawer are the groups "Frame", "Workbench"
--and "Scripts", which the script of the group "Frame" runs.

--(remaster) Where the wheel is taking the notes, and where a drag of their thumb began
local sGlideGoal, sDragFrom, sDragScroll

on openStack  --added: a word, if the IDE's data grid library is not there to draw the grids
   if there is not a stack "revDataGridLibrary" then
      answer "The data grids on these cards need the IDE's data grid library, and it is not loaded." &cr& \
            "In Preferences, under Compatibility, untick Disable Data Grids, then start the IDE again." with "OK" titled "Data Grid Tables"
   end if
   pass openStack
end openStack

on preOpenCard  --was in Terry's < Prev and Next > buttons, which the window's Back and Next are now
   put empty into sGlideGoal  --(remaster) a glide of the last card's notes stops
   codeFontMatch  --(remaster) the code on the card in the scripts panel's font
   if there is a fld "Info" then set the vScroll of fld "Info" to "0"  --top
   notesFit  --(remaster) the notes end at the foot of a line, not halfway down one
   notesThumb  --(remaster) the thumb that shows how far down the notes are
   pass preOpenCard
end preOpenCard

--(remaster) Code in the scripts panel's font (the window finds it before this stack's preOpenCard),
--or else in the first of its choices this computer has: each field whose cCode is true, and the
--code in the notes, whose font the card's cNotesFace names. The web IDE, say, has Droid Sans Mono
--and not Source Code Pro.

command codeFontMatch
   local tFont, tIndex, tField, tWas, tHtml
   put codeFontHere() into tFont
   if tFont is empty then exit codeFontMatch
   repeat with tIndex = 1 to the number of fields of this card
      put the long id of field tIndex of this card into tField
      if the cCode of tField is true and the textFont of tField is not tFont then set the textFont of tField to tFont
   end repeat
   put the cNotesFace of this card into tWas
   if there is a fld "Info" and tWas is not empty and tWas is not tFont then
      put the htmlText of fld "Info" into tHtml
      replace "face=" & quote & tWas & quote with "face=" & quote & tFont & quote in tHtml
      set the htmlText of fld "Info" to tHtml
      set the cNotesFace of this card to tFont
   end if
end codeFontMatch

function codeFontHere
   local tFont
   if there is a field "codeText" then
      if the textFont of field "codeText" is not empty then return the textFont of field "codeText"
   end if
   repeat for each item tFont in "Source Code Pro,Droid Sans Mono,Menlo,Consolas,DejaVu Sans Mono,Courier New"
      if tFont is among the lines of the fontNames then return tFont
   end repeat
   return empty
end codeFontHere

--(remaster) The notes as tall as the lines of this card's notes that show whole: their foot as
--far down as cNotesBottom lets it, at the foot of the last such line (a line of a paragraph, as
--its words show where it ends), so that the card does not open on a line cut in half.

command notesFit
   local tBottom, tLimit, tLine, tWord, tRect, tFoot, tCount
   if there is no fld "Info" or the cNotesBottom of fld "Info" is empty then exit notesFit
   put the cNotesBottom of fld "Info" into tLimit
   set the rect of fld "Info" to item 1 of the rect of fld "Info", item 2 of the rect of fld "Info", item 3 of the rect of fld "Info", tLimit
   put empty into tFoot
   put the number of lines of fld "Info" into tCount
   repeat with tLine = 1 to tCount
      put item 4 of the formattedRect of line tLine of fld "Info" into tBottom
      if tBottom > tLimit then exit repeat
      put tBottom into tFoot
   end repeat
   if tLine <= tCount then  --a paragraph runs past the foot: as far as its whole lines go
      repeat with tWord = 1 to the number of words of line tLine of fld "Info"
         put the formattedRect of word tWord of line tLine of fld "Info" into tRect
         if item 4 of tRect > tLimit then exit repeat
         put max(tFoot, item 4 of tRect) into tFoot
      end repeat
   end if
   if tFoot is not empty then
      set the rect of fld "Info" to item 1 of the rect of fld "Info", item 2 of the rect of fld "Info", item 3 of the rect of fld "Info", tFoot + 2
   end if
end notesFit

--(remaster) The notes scroll with the wheel, without a scrollbar, as the scripts panel does: the slim
--thumb at their right shows how far down they are, and can be dragged.

on rawKeyDown pKey
   local tGliding
   if pKey is not 65308 and pKey is not 65309 then pass rawKeyDown  --the wheel, down or up
   if not notesUnderMouse() then pass rawKeyDown
   put sGlideGoal is not empty into tGliding  --a glide under way takes the new goal (a second one beside it would double its speed)
   if not tGliding then put the vScroll of fld "Info" into sGlideGoal
   if pKey is 65308 then add 48 to sGlideGoal
   else subtract 48 from sGlideGoal
   put max(0, min(sGlideGoal, notesRoom())) into sGlideGoal
   if not tGliding then notesGlide
end rawKeyDown

on notesGlide  --one step of the scroll toward where the wheel is taking it
   local tNow, tStep
   if sGlideGoal is empty or there is no fld "Info" then
      put empty into sGlideGoal
      exit notesGlide
   end if
   put the vScroll of fld "Info" into tNow
   put round((sGlideGoal - tNow) * 0.35) into tStep
   if abs(sGlideGoal - tNow) <= 1 or tStep is 0 then
      set the vScroll of fld "Info" to sGlideGoal
      put empty into sGlideGoal
   else
      set the vScroll of fld "Info" to tNow + tStep
      if the vScroll of fld "Info" is tNow then put empty into sGlideGoal  --it did not move: it is at its end, and the glide is over
      else send "notesGlide" to me in 16 milliseconds
   end if
   notesThumb
end notesGlide

function notesUnderMouse  --the pointer is over the notes or their thumb (not the scripts drawer)
   local tControl
   if there is no fld "Info" then return false
   put the mouseControl into tControl
   if tControl is empty then return false
   return the long id of tControl is the long id of fld "Info" or the short name of tControl is "notesThumb"
end notesUnderMouse

function notesRoom  --how far down the notes go: measured, as the engine stops a field's scroll a few pixels short of its formattedHeight less its height
   local tNow, tRoom, tLocked
   put the vScroll of fld "Info" into tNow
   put the lockMessages into tLocked
   lock screen
   lock messages
   set the vScroll of fld "Info" to the formattedHeight of fld "Info" + the height of fld "Info"
   put the vScroll of fld "Info" into tRoom
   set the vScroll of fld "Info" to tNow
   set the lockMessages to tLocked
   unlock screen
   return max(0, tRoom)
end notesRoom

command notesThumb
   local tRoom, tTrack, tSize, tTop
   if there is no fld "Info" or there is no grc "notesThumb" then exit notesThumb
   put notesRoom() into tRoom
   if tRoom < 8 then
      hide grc "notesThumb"
      exit notesThumb
   end if
   put the height of fld "Info" - 16 into tTrack
   put max(24, round(tTrack * tTrack / (tTrack + tRoom))) into tSize
   put the top of fld "Info" + 8 + round((tTrack - tSize) * min(1, the vScroll of fld "Info" / tRoom)) into tTop
   set the rect of grc "notesThumb" to item 1 of the rect of grc "notesThumb", tTop, item 3 of the rect of grc "notesThumb", tTop + tSize
   show grc "notesThumb"
end notesThumb

on mouseDown pButton  --the thumb, dragged: the notes go as far down as it does
   if pButton is 1 and the short name of the target is "notesThumb" and there is a fld "Info" then
      put item 2 of the mouseLoc into sDragFrom
      put the vScroll of fld "Info" into sDragScroll
      put empty into sGlideGoal
   end if
   pass mouseDown
end mouseDown

on mouseMove pX, pY
   local tTrack, tRoom
   if sDragFrom is empty then pass mouseMove
   if the mouse is up or there is no fld "Info" then
      put empty into sDragFrom
      pass mouseMove
   end if
   put the height of fld "Info" - 16 - the height of grc "notesThumb" into tTrack
   if tTrack > 0 then
      put notesRoom() into tRoom
      set the vScroll of fld "Info" to max(0, min(tRoom, sDragScroll + round((pY - sDragFrom) * tRoom / tTrack)))
      notesThumb
   end if
   pass mouseMove
end mouseMove

on mouseUp pButton
   put empty into sDragFrom
   pass mouseUp
end mouseUp

on mouseRelease pButton
   put empty into sDragFrom
   pass mouseRelease
end mouseRelease
