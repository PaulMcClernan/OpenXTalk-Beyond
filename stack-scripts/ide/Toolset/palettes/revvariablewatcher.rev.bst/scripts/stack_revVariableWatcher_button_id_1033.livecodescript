script "stack_revVariableWatcher_button_id_1033"
-- Stack file: ide/Toolset/palettes/revvariablewatcher.rev
-- Object: stack "revVariableWatcher" > card "home" (id 1002) > button "Execution Contexts" (id 1033)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

 on menuPick
  revUpdatePalette true
end menuPick

on mouseDown
  global gREVShowStacks
  local tOutput, tIsRevStack
  put the executionContexts into tVar
  repeat for each line l in tVar
    if the number of words in l is 0 then next repeat
    
    do "put revTargetStack(the long id of" && item 1 to -3 of l & ") into tIsRevStack"
       
    local tFilteredStackList
    put revFilterStacksList(tIsRevStack) into tFilteredStackList
        
    if tFilteredStackList is not empty or (gREVShowStacks and tIsRevStack is not in "revErrorDisplay,revVariableWatcher,message box,revLibrary") then
      do "put the name of" && item 1 to -3 of l && "after tOutput"
      put " , line" && item -1 of l & cr after tOutput
      put l & cr after tContextsSet
    end if
  end repeat
  delete last char of tOutput
  set the text of me to tOutput
  delete last char of tContextsSet
  set the cContexts of me to tContextsSet
end mouseDown
