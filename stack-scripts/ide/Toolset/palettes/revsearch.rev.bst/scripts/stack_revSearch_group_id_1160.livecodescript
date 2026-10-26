script "stack_revSearch_group_id_1160"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002) > group "Tabs" (id 1160)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

global gREVFinalResult

on mouseUp
  if the owner of the target is not me then exit mouseUp
  
  put the hilitedText of fld "stack" of stack "revSearch" into tHilited
  
  set the itemDel to tab
  if the short name of the target is "type" then sort lines of gREVFinalResult by item 1 of each
  if the short name of the target is "name" then sort lines of gREVFinalResult by item 2 of each
  if the short name of the target is "card" then sort lines of gREVFinalResult by item 3 of each
  if the short name of the target is "stack" then sort lines of gREVFinalResult by item 4 of each
  
  lock screen
  
  put empty into fld "type" of stack "revSearch"
  put empty into fld "name" of stack "revSearch"
  put empty into fld "card" of stack "revSearch"
  put empty into fld "stack" of stack "revSearch"
  
  repeat for each line l in gREVFinalResult
    put item 1 of l & cr after fld "type" of stack "revSearch"
    put item 2 of l & cr after fld "name" of stack "revSearch"
    put item 3 of l & cr after fld "card" of stack "revSearch"
    put item 4 of l & tab & item 5 of l & cr after fld "stack" of stack "revSearch"
  end repeat
  
  set the hilitedLines of fld "stack" of stack "revSearch" to lineOffSet(tHilited,the text of fld "stack" of stack "revSearch")
  put the hilitedLines of fld "stack" of stack "revSearch" into tHilited
  set the hilitedLines of fld "type" of stack "revSearch" to tHilited
  set the hilitedLines of fld "name" of stack "revSearch" to tHilited
  set the hilitedLines of fld "card" of stack "revSearch" to tHilited
  unlock screen
  
end mouseUp
