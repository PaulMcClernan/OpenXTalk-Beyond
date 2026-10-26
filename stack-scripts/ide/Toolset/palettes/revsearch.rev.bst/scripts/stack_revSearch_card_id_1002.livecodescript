script "stack_revSearch_card_id_1002"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   
   #Don't use dividers in option menus on PCs
   if the platform is "MacOS"
   then set the text of btn "Search In" to the cMacOSText of btn "Search In"
   else set the text of btn "Search In" to the cPCText of btn "Search In"
   pass preOpenCard
end preOpenCard

on resizeStack
   local tHilited
   put the hilitedLines of fld "stack" of stack "revSearch" into tHilited
   revUpdateGeometry
   
   set the hilitedLines of fld "type" of stack "revSearch" to tHilited
   set the hilitedLines of fld "name" of stack "revSearch" to tHilited
   set the hilitedLines of fld "card" of stack "revSearch" to tHilited
   set the hilitedLines of fld "stack" of stack "revSearch" to tHilited
   set the scroll of fld "type" of stack "revSearch" to the scroll of fld "stack" of stack "revSearch"
   set the scroll of fld "name" of stack "revSearch" to the scroll of fld "stack" of stack "revSearch"
   set the scroll of fld "card" of stack "revSearch" to the scroll of fld "stack" of stack "revSearch"
   set the thumbPosition of sb "results" of stack "revSearch" to the scroll of fld "stack" of stack "revSearch"
end resizeStack

on returnInField
   -- MM-2011-08-08: Accept return characters in replace field allowing for multiline replace
   if the short name of the target is "Replace" then
      pass returnInField
   end if
   click at the loc of btn "search"
end returnInField

on enterInField 
   click at the loc of btn "search"
end enterInField

command updateScrollbar
   if the formattedHeight of field "Type" of me <= the height of field "Type" of me then
      set the enabled of scrollbar "Results" of me to false
      exit updateScrollbar
   end if
   
   local tThumbPosition
   put the thumbPosition of scrollbar "Results" of me into tThumbPosition
   
   set the enabled of scrollbar "Results" of me to true
   set the startValue of scrollbar "Results" of me to 0
   set the endValue of scrollbar "Results" of me to the formattedHeight of field "Type" of me
   set the thumbSize of scrollbar "Results" of me to the height of field "Type" of me
   set the thumbPosition of scrollbar "Results" of me to tThumbPosition
end updateScrollbar
