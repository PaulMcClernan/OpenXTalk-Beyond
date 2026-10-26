script "stack_Scroll_an_Image_group_id_1144"
-- Stack file: ide/Resources/Examples/Remastered/Scroll an Image.oxtstack
-- Object: stack "Scroll an Image" > card "The Painting" (id 1031) > group "Tour" (id 1144)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--(added in the remaster) A tour of the
--painting: the script scrolls the group
--"Display" from place to place, a little
--at a time, so that its window glides. A
--click during the tour stops it.

local sTouring  --true while the tour is on

on mouseUp
   local tGroup, tCard, tLabel, tCaption, tStops, tStop
   if sTouring is true then
      put false into sTouring  --the tour stops
      exit mouseUp
   end if
   put true into sTouring
   --(long ids: the tour may end on another
   --card)
   put the long id of group "Display" into tGroup
   put the long id of this card into tCard
   put the long id of field "Tour_label" into tLabel
   put the long id of field "Stop" into tCaption
   set the text of tLabel to "Stop the tour"
   --each stop: what is there, and the
   --hScroll and vScroll that show it
   put "Her face,70,20" & return & \
         "Her hands and her ring,95,263" & return & \
         "The fur wrap,0,180" & return & \
         "The dark background,151,0" & return & \
         "Her face again,70,20" into tStops
   repeat for each line tStop in tStops
      set the text of tCaption to item 1 of tStop
      glide tGroup, item 2 of tStop, item 3 of tStop, tCard
      if sTouring is not true or the long id of this card is not tCard then exit repeat
      wait 1 second with messages
      if sTouring is not true or the long id of this card is not tCard then exit repeat
   end repeat
   put false into sTouring
   set the text of tLabel to "Take the tour"
   set the text of tCaption to "Lady in a Fur Wrap"
end mouseUp

--moves the window of pGroup to hScroll pX
--and vScroll pY in 40 small steps: fast at
--first, and slow at the end, as things
--come to rest
private command glide pGroup, pX, pY, pCard
   local tFromX, tFromY, tStep, tT
   put the hScroll of pGroup into tFromX
   put the vScroll of pGroup into tFromY
   repeat with tStep = 1 to 40
      if sTouring is not true or the long id of this card is not pCard then exit repeat
      put 1 - (1 - tStep / 40) ^ 3 into tT
      lock screen
      set the hScroll of pGroup to round(tFromX + (pX - tFromX) * tT)
      set the vScroll of pGroup to round(tFromY + (pY - tFromY) * tT)
      unlock screen
      wait 20 milliseconds with messages
   end repeat
end glide
