script "stack_revVariableWatcher_button_id_1059"
-- Stack file: ide/Toolset/palettes/revvariablewatcher.rev
-- Object: stack "revVariableWatcher" > card "home" (id 1002) > button "script" (id 1059)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp       
  local tSelectedLine, tCommand, tItemOne
  
  put the menuHistory of button "execution contexts" into tSelectedLine
  put item 1 of line tSelectedLine of the cContexts of button "execution contexts" into tItemOne
  put item 3 of line tSelectedLine of the cContexts of button "execution contexts" into tItemThree
  --answer tItemOne
  
  put revScriptEditor(tItemOne) into tEditor
  
  if tEditor is not empty then
    --answer "topleveling"
    modeless tEditor
    set the hilitedLines of fld "script" of stack tEditor to tItemThree
  else 
    put "edit the script of the" && item 1 of the cContexts of button "execution contexts" into tCommand
    do tCommand
  end if
end mouseUp
