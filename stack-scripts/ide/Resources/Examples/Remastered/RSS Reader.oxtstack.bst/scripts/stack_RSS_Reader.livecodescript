script "stack_RSS_Reader"
-- Stack file: ide/Resources/Examples/Remastered/RSS Reader.oxtstack
-- Object: stack "RSS Reader"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--RSS Reader: the RSS Demo of OpenXTalk Lite's demos, remastered for OXT-Beyond in 2026
--The original's only credit, the first line of its Import button's script:
-- via theotherbassist, April 2016

--Each card's program is in the scripts of the card and its controls.
--The scripts panel beside the stage shows them (on the wide card, the drawer that the Scripts button opens).

--The mouse wheel scrolls a list that has no scrollbar: a field whose custom property cWheel is true.
--Its thumb, the graphic its custom property cThumb names, shows how far down it is.
on rawKeyDown pKey
   local tField
   if pKey is 65308 or pKey is 65309 then  --the wheel, down or up
      put wheelField() into tField
      if tField is not empty then
         if pKey is 65308 then
            set the vScroll of tField to the vScroll of tField + 48
         else
            set the vScroll of tField to the vScroll of tField - 48
         end if
         showThumb the short name of tField
         dispatch "listScrolled" to this card  --(a card that follows the scroll)
         exit rawKeyDown
      end if
   end if
   pass rawKeyDown
end rawKeyDown

private function wheelField  --the list under the pointer
   local tIndex, tField
   repeat with tIndex = 1 to the number of fields of this card
      put the long id of field tIndex of this card into tField
      if the cWheel of tField is true and the mouseLoc is within the rect of tField then
         return tField
      end if
   end repeat
   return empty
end wheelField

command showThumb pField  --as tall as the part of the list shown, as far down as it is scrolled
   local tThumb, tRoom, tShown, tHeight, tTop
   if there is not a field pField or the cThumb of field pField is empty then
      exit showThumb
   end if
   put the long id of graphic (the cThumb of field pField) into tThumb
   put the formattedHeight of field pField - the height of field pField into tRoom
   if tRoom <= 4 then
      hide tThumb
      exit showThumb
   end if
   put the height of field pField - 8 into tShown
   put max(24, round(tShown * tShown / (tShown + tRoom))) into tHeight
   put the top of field pField + 4 + round((tShown - tHeight) * min(1, the vScroll of field pField / tRoom)) into tTop
   set the rect of tThumb to item 1 of the rect of tThumb, tTop, item 3 of the rect of tThumb, tTop + tHeight
   show tThumb
end showThumb
