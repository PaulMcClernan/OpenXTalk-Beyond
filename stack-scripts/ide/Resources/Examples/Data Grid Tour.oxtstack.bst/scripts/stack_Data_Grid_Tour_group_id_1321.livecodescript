script "stack_Data_Grid_Tour_group_id_1321"
-- Stack file: ide/Resources/Examples/Data Grid Tour.oxtstack
-- Object: stack "Data Grid Tour" > card "Welcome" (id 73190) > group "Chrome" (id 1321)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on openCard
   adjustSlider
   pass openCard
end openCard

on deleteCard
   send adjustSlider to me in 0 seconds
   pass deleteCard
end deleteCard

on adjustSlider
   lock screen
   put the number of cards into n
   put the number of this card into c
   
   -- update field contents:
   put the short name of this card into myName
   set the itemDelimiter to ":"
   put space & myName into the last item  fld "Page Heading"
   put myName into fld "Page Title"
   put c into fld "Scroll Page"
   
   -- update nav buttons:
   set the disabled of btn "Back" to (c is 1)
   --set the disabled of btn "Next" to (c is n)  --comment out to loop.
   
   -- configure scrollbar:
   put the width of graphic "Scroll Well" into w
   put the height of graphic "Scroll Well" into h
   put the left of graphic "Scroll Well" into startLeft
   put the top of graphic "Scroll Well" into startTop
   put w / n into segmentWidth
   
   -- layout segments corresponding to cards if necessary:
   if  the numSegs of group "Scroll Well" is not n then
      repeat with i = 1 to n
         put "s" && i into segmentName
         if there is not a graphic segmentName then create graphic segmentName in group "Scroll Well"
         set the width of graphic segmentName to trunc(segmentWidth+1)
         set the height of graphic segmentName to h
         set the left of graphic segmentName to startLeft + trunc((i-1) * segmentWidth)
         set the top of graphic segmentName to startTop
         set the visible of graphic segmentName to false
      end repeat
      set the numSegs of group "Scroll Well" to i
      
      -- clean up any extra segments from deleted cards:
      repeat while there is a graphic ("s" && i + 1)
         delete graphic ("s" && i + 1)
         add 1 to i
      end repeat
   end if
   
   set the itemDelimiter to comma
   put the loc of grc ("s" && c) into newLoc
   
   -- figure out where to drop the slider:
   put trunc(the width of group "Scroller" / 2) into w
   put the left of grc "Scroll Well" + w into maxleft
   put the right of grc "Scroll Well" - w into maxright
   if c = n then put maxRight into item 1 of newLoc
   if c = 1 then put maxLeft into item 1 of newLoc
   put max(maxleft, min(maxright, item 1 of newLoc)) into item 1 of newLoc
   
   unlock screen
   move group "Scroller" to newLoc in 250 milliseconds  -- position the slider.
end adjustSlider
