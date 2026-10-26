script "stack_revSearch_button_id_1237"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002) > group "Controls" (id 1149) > button "Remove from List" (id 1237)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

global gREVSearchIn,gREVShowStacks, gREVFinalResult
  
on mouseUp
   
   lock screen
   local tHilited
   put the hilitedLines of fld "stack" of cd 1 of stack "revSearch" into tHilited
   delete line tHilited of gREVFinalResult
   
   local tDelete
   put the text of fld "type" into tDelete
   delete line (the hilitedLines of fld "stack") of tDelete
   set the text of fld "type" to tDelete
   --
   put the text of fld "name" into tDelete
   delete line (the hilitedLines of fld "stack") of tDelete
   set the text of fld "name" to tDelete
   --
   put the text of fld "card" into tDelete
   delete line (the hilitedLines of fld "stack") of tDelete
   set the text of fld "card" to tDelete
   --
   put the text of fld "stack" into tDelete
   delete line (the hilitedLines of fld "stack") of tDelete
   set the text of fld "stack" to tDelete
   --
   if tHilited > 1 then
      set the hilitedLines of fld "type" of stack "revSearch" to tHilited -1
      set the hilitedLines of fld "name" of stack "revSearch" to tHilited -1
      set the hilitedLines of fld "card" of stack "revSearch" to tHilited -1
      set the hilitedLines of fld "stack" of stack "revSearch" to tHilited -1
      send "mouseUp" to fld "stack" of stack "revSearch"
   end if
   if tHilited is 1 then
      set the hilitedLines of fld "type" of stack "revSearch" to 1
      set the hilitedLines of fld "name" of stack "revSearch" to 1
      set the hilitedLines of fld "card" of stack "revSearch" to 1
      set the hilitedLines of fld "stack" of stack "revSearch" to 1
      send "mouseUp" to fld "stack" of stack "revSearch"
   end if
   if the num of lines in fld "stack" of stack "revSearch" is 0 then
      set the hilitedLines of fld "type" of stack "revSearch" to empty
      set the hilitedLines of fld "name" of stack "revSearch" to empty
      set the hilitedLines of fld "card" of stack "revSearch" to empty
      set the hilitedLines of fld "stack" of stack "revSearch" to empty
      --
      put empty into fld "item info" of stack "revSearch"
      disable btn "Remove from List" of stack "revSearch"
      disable fld "replace" of stack "revSearch"
      disable btn "replace" of stack "revSearch"
      put empty into fld "feedback" of stack "revSearch"
      focus fld "search term" of stack "revSearch"
      exit mouseUp
   end if
   if the num of lines in fld "stack" of stack "revSearch" is 1 then
      set the text of fld "feedback" of stack "revSearch" to the num of lines in fld "stack" of cd 1 of stack "revSearch" && "item listed"
   end if
   if the num of lines in fld "stack" of stack "revSearch" > 1 then
      set the text of fld "feedback" of stack "revSearch" to the num of lines in fld "stack" of cd 1 of stack "revSearch" && "items listed"
   end if
   
   # OK-2008-08-13 : Bug 6477 - Ensure the scrollbar gets updated when items are removed from the list
   updateScrollbar
   unlock screen
   
end mouseUp

on mouseDoubleUp
  mouseUp
end mouseDoubleUp
