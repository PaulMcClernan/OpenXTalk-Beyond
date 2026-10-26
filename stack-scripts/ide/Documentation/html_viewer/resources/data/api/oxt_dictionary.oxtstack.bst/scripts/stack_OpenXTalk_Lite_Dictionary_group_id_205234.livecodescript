script "stack_OpenXTalk_Lite_Dictionary_group_id_205234"
-- Stack file: ide/Documentation/html_viewer/resources/data/api/oxt_dictionary.oxtstack
-- Object: stack "OpenXTalk Lite Dictionary" > card (id 1002) > group "groupdrag" (id 205234)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   send tCloseSearches to this card
   send tDragCheck to me in 1 millisecond
   if the mouse is up then 
      exit mousedown
   end if
end mousedown

on tDragCheck
   lock screen
   set the itemdelimiter to ","
   if the mouse is up then exit tDragCheck
   set the loc of me to (item 1 of the loc of me, the mouseV)
   --
   set the rect of fld "tEntries" to the item 1 of the rect of fld "tEntries", item 2 of the rect of fld "tEntries", item 3 of the rect of fld "tEntries", the top of me
   set the rect of fld "styledTextField" to item 1 of the rect of fld "styledTextField", the bottom of me, item 3 of the rect of fld "styledTextField", item 4 of the rect of fld "styledTextField"
   put (the height of cd fld "tEntries" / the textHeight of fld "tEntries") +"1.5" into tRoundVal
   put round(tRoundVal) into tRoundVal
   set the tLinesShown of fld "tEntries" to tRoundVal
   set the topright of btn "favaddbtn" to the right of fld "styledTextField" -5 -(the scrollbarwidth of fld "styledTextField"), the top of fld "styledTextField" +5
   --
   unlock screen
   if the mouse is down then send tDragCheck to me in 1 millisecond
   if the mouse is up then
      lock screen
      send KeywordToIconForVisible to this card -- update the icons if needed
      unlock screen
   end if
end tDragCheck
