script "stack_allguides_field_id_1009"
-- Stack file: ide/Toolset/palettes/userguides/allguides.oxtstack
-- Object: stack "allguides" > card "Contents" (id 1002) > group "ttitle" (id 1006) > field "ClickList" (id 1009)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   put word 2 of the clickLine into tClickedLine
   put line tClickedLine of me into tClickedText
   -- put "clicked line " & tClickedLine & return & "text is: " & tClickedText
   if there is a cd tClickedText of this stack then go cd tClickedText of this stack
   send tRefreshIndex to fld "ClickList"
end mousedown

on tRefreshIndex
   put the cToolSelectorColor of stack "revPreferences" into tNavHiliteColour
   lock screen
   put the vScroll of fld "ClickList" into tOldVScroll
   put the number of cards of this stack into tCardsInTotal
   local tNewIndex
   put 0 into tCardCount
   repeat tCardsInTotal
      add 1 to tCardCount
      put the short name of card tCardCount of this stack into line (the number of lines of tNewIndex +1) of tNewIndex 
   end repeat
   filter lines of tNewIndex without empty
   put tNewIndex into fld "ClickList"
   -- restore selection
   put the number of this card of this stack into tSelNum
   if isNumber(tSelNum) then 
      set the hilitedline of fld "ClickList" to ""
      set the backgroundColor of fld "Clicklist" to ""
      set the backgroundColor of line tSelNum of fld "Clicklist" to tNavHiliteColour
      -- set the scroll of the side-list appropriately
      put the textHeight of fld "ClickList" into tLineH
      put the mouseV / tLineH into tVertOffset
      put tLineH * (round (tVertOffset,0) -2) into tAddV
      put tSelNum * tLineH into tTestScroll
      set the vScroll of fld "ClickList" to tTestScroll - tAddV
   else
      -- restore vertical pos of click list
      set the vScroll of fld "ClickList" to tOldVScroll
   end if
   -- make sure main content is always scrolled to top
   set the vScroll of fld "tActualContent" to 0
   unlock screen
end tRefreshIndex
