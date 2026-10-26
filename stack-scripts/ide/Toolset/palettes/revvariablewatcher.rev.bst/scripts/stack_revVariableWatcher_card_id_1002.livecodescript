script "stack_revVariableWatcher_card_id_1002"
-- Stack file: ide/Toolset/palettes/revvariablewatcher.rev
-- Object: stack "revVariableWatcher" > card "home" (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

global gREVVariableWatcherValue

on preOpenStack
  local tFont, tControlProp
  
  put empty into field "Contents"
  put empty into field "contentsArrayKey"
  put empty into field "contentsArrayValue"
  
  lock messages -- otherwise would reset individual control layouts so lock messages
  if the cVariableWatcherRect of stack "revPreferences" is not empty then
    set the rect of this stack to the cVariableWatcherRect of stack "revPreferences"
  end if
  unlock messages
  set the textSize of field 1 to the scriptTextSize
  
  if the cVariableWatcherControlRect1 of stack "revPreferences" is empty then
    resizeStack -- set up control locations as default
  else
    repeat with i = 1 to the number of controls
      put "cVariableWatcherControlRect" & i into tControlProp
      if the tControlProp of stack "revPreferences" is not empty then set the rect of control i to the tControlProp of stack "revPreferences"
    end repeat
  end if
  repeat with i = 1 to the number of fields
    set the textFont of field i to the scriptTextFont
    set the textSize of field i to the scriptTextSize
    put the cREVScriptTextHeight of stack "revPreferences" into tFont
    set the textHeight of field i to tFont
  end repeat
  revUpdatePalette
  
  revInternal__ConstrainStack the short name of the owner of me
end preOpenStack

on saveControlRects
  local tControlProp
  repeat with i = 1 to the number of controls
    put "cVariableWatcherControlRect" & i into tControlProp
    set the tControlProp of stack "revPreferences" to the rect of control i
  end repeat
end saveControlRects

on suspendStack
  revSEShowPalettes
end suspendStack

on moveStack
  set the cVariableWatcherRect of stack "revPreferences" to the rect of this stack
end moveStack
 
on closeStack
  set the cVariableWatcherRect of stack "revPreferences" to the rect of this stack
  put "" into field "Names"
  put "" into field "Values"
  put "" into field "Contents"
end closeStack

command log pMessage
  put pMessage & return after msg
end log

on revUpdatePalette pPass
  global gREVShowStacks
  local tItemDel, tLineDel, tSameContext, tKeep, tTempName, i, tName, tObject, tTargetObject, tLine
  
  put the itemDel into tItemDel -- save existing as they take contex from current script
  put the lineDel into tLineDel
  set the itemDel to comma
  set the lineDel to cr
  get the executionContexts
  if not pPass then
    send "mouseDown" to button "execution contexts"
    set the menuHistory of button "execution contexts" to the number of lines in the cContexts of button "execution contexts"
    put field "Values" into tSameContext
  end if
  if the mode of this stack is 0 then
    set the itemDel to tItemDel
    set the lineDel to tLineDel
    exit revUpdatePalette
  end if
  lock screen
  put empty into field "Watched"
  put empty into field "Contents"
  if the number of lines in the cContexts of button "Execution Contexts" is 0 then
    get the globals
    replace comma with return in it
    if gREVShowStacks is false then 
      put it into tKeep
      filter it with "gREV*"
      replace it with empty in tKeep
      put tKeep into it
    end if
    if the number of words in line 1 of it is 0 then delete line 1 of it
    if the number of words in line -1 of it is 0 then delete line -1 of it
    sort lines of it
    -- Remove empty lines
    local tNewIt
    repeat for each line tLine in it
      if tLine is not empty then
        put tLine & return after tNewIt
      end if
    end repeat
    delete the last char of tNewIt
    put tNewIt into it
    put it into field "Names"
    setInvisible "scalar"
    
    if the cLiveColor of stack "revPreferences" then 
      set the textColor of char 1 to -1 of field "Names" to item 4 of the vcolors of this stack
    end if
    put empty into field "Values"
    
    repeat for each line tGlobal in it
      try
        local tCommand, tGlobalValue
        
        do "global" && tGlobal & "; put" && tGlobal && "into tGlobalValue"
        
        if the keys of tGlobalValue is empty then
          put char 1 to 100 of line 1 of value(tGlobal) & return after field "Values"
        else
          put "< array >" & return after field "Values"
        end if
         
      catch tError
        put "Error doing command" & return & return & tCommand & return & return & tError
      end try
      
    end repeat
    delete last char of field "Values"
    
    set the topLeft of field "watched" to -100,32
    set the rect of field "names" to 4, item 2 to 4 of the rect of field "names"
  else
    setInvisible "scalar"
    set the topLeft of field "watched" to 4,32
    set the rect of field "names" to 16,item 2 to 4 of the rect of field "names"
    set the curline of this stack to the hilitedLines of field "Names"
    if the curline of this stack is empty then 
      set the curline of this stack to 1
    end if
    set the curscroll of this stack to the scroll of field "Names"
    get the menuHistory of button "Execution Contexts"
    if it is empty then 
      get the number of lines in the cContexts of button "Execution Contexts"
    end if
    
    
    --log "setting the debugContext to : " & line it of the cContexts of button "Execution Contexts"
    set the debugContext to line it of the cContexts of button "Execution Contexts"
    
    -- MW-2008-01-18: [[ Bug 5800 ]] Make sure we use an absolute reference to the field we want
    --   to but the result into.
    debugdo "put the variableNames into field " && quote & "tvnames" & quote && "of stack" && quote & "revVariableWatcher" & quote
    
    replace "@" with empty in field "tvnames"
    replace cr with comma in field "tvnames"
    replace ",," with "," in field "tvnames"
    put word 1 to -1 of field "tvnames" into field "tvnames"
    if last char of field "tvnames" is comma then 
      delete last char of field "tvnames"
    end if
    if last item of field "tvnames" is empty then 
      delete last item of field "tvnames"
    end if
    sort items of field "tvnames"
    if char 1 of field "tvnames" is comma then 
      delete char 1 of field "tvNames"
    end if 
    put empty into field "Names"
    put empty into field "Values"
    put 1 into field "tcline"
    
    repeat until field "tcline" > 4
      put 1 into field "tcitem"
      
      repeat until field "tcitem" > the number of items of line (field "tcline") of field "tvnames"
        put item (field "tcitem") of line (field "tcline") of field "tvnames" & cr after field "Names"
        if the cLiveColor of stack "revPreferences" then set the textColor of the last line of field "Names" to item (field "tcline") of the vcolors of this stack
        put item (field "tcitem") of line (field "tcline") of field "tvnames" into field "tvname"
        if the number of words in line 1 of field "tvname" is not 0 then
          get the menuHistory of button "Execution Contexts"
          if it is empty then get the number of lines in the cContexts of button "Execution Contexts"
          set the debugContext to line it of the cContexts of button "Execution Contexts"
          
          put item (field "tcitem") of line (field "tcline") of field "tvnames" into tTempName
          
          debugDo "revDebuggerGrabValue" && tTempName
          
          if the keys of gREVVariableWatcherValue is not empty then
            -- MW-2008-01-18: [[ Bug 5800 ]] Make sure we use an absolute reference to the field we want
            --   to but the result into.
            debugDo "put" && quote & "< array >" & quote && "& cr after field" && quote & "Values" & quote && "of stack" && quote & "revVariableWatcher" & quote
          else
            # OK-2007-07-31 : Bug 5273. 100 chars seems a little too small, so I increased it and added
            # three dots after the string if the number of chars is too big to store.
            # debugDo "put char 1 to 100 of line 1 of" && field "tvname" && "& cr after field" && quote & "Values" & quote
            
            -- MW-2008-01-18: [[ Bug 5800 ]] Make sure we use an absolute reference to the field we want
            --   to but the result into.
            debugDo "put char 1 to 200 of line 1 of" && field "tvname" && "after field" && quote & "Values" & quote && "of stack" && quote & "revVariableWatcher" & quote
            
            lock screen
            lock messages
            create field "Variable Length"
            unlock messages
            
            -- MW-2008-01-18: [[ Bug 5800 ]] Make sure we use an absolute reference to the field we want
            --   to but the result into.
            debugDo "put the number of chars of line 1 of " & the text of field "tvname" & " into field " & quote & "Variable Length" & quote && "of stack" && quote & "revVariableWatcher" & quote
            if the text of field "Variable Length" > 200 then
              put "..." after field "Values"
            end if
            put return after field "Values"
            
            lock messages
            delete field "Variable Length"
            unlock messages
            unlock screen
            
          end if
        end if
        add 1 to field "tcitem"
      end repeat
      add 1 to field "tcline"
    end repeat
    delete last char of field "Names"
    if line 1 of field "names" is empty then delete line 1 of field "names"
    delete last char of field "Values"
    if tSameContext is not empty then -- what variable has changed?
      put 1 into i
      repeat for each line l in field "values"
        if l is not line i of tSameContext then
          set the hilitedLines of field "Names" to i
          set the hilitedLines of field "Values" to i
          exit repeat
        end if
        add 1 to i
      end repeat
    else if line (the curline of this stack) of field "Names" is not empty then
      set the hilitedLines of field "Names" to the curline of this stack
      set the hilitedLines of field "Values" to the curline of this stack
      put line (word 1 of the curline of this stack) of field "Names" into tName
       
      -- MW-2008-01-18: [[ Bug 5800 ]] Make sure we use an absolute reference to the field we want
      --   to but the result into.
      debugdo "put" && tName && "into field" && quote & "Contents" & quote && "of stack" && quote & "revVariableWatcher" & quote
    end if
    put empty into line (the number of lines in field "Names") of field "Watched"
    put item 2 of the debugContext into field "handler"
    put revScriptEditor(item 1 of the debugContext) into tObject
    set the debugContext to empty
    if tObject is not empty then 
      put the cTargetObject of cd 1 of stack tObject into tTargetObject
      repeat for each line l in the watchedVariables
        if item 1 of l is tTargetObject and item 2 of l is field "handler" then
          put lineOffset(item 3 of l, field "Names") into tLine
          put "." into line tLine of field "Watched"
          set the imageSource of char 1 of line tLine of field "Watched" to 203451
        end if
      end repeat
    end if
    set the scroll of field "Names" to the curscroll of this stack
    set the scroll of field "Watched" to the curscroll of this stack
    set the scroll of field "Values" to the curscroll of this stack
  end if
  set the itemDel to tItemDel
  set the lineDel to tLineDel
  unlock screen
end revUpdatePalette

on selectVar theLineNum
  --BB-2005-05-23: Added in code for array tracing in the variable watcher
  
  local tArrayDisplayValue
  local tIter = 0
  local tKeys, tName, tExtents, tArrayDisplayKey
  
  if line theLineNum of field "Names" is empty then
    exit to top
  end if
  
  if the number of lines in the cContexts of button "Execution Contexts" is 0 then
    local tGlobalValue
    get line theLineNum of field "Names"
    
    do "global" && it & "; put" && it && "into tGlobalValue;"
    
    # TH-2008-03-07 : Fix for 5800, performing check for arrays here
    if the keys of tGlobalValue is empty then
      setInvisible "scalar"
      put tGlobalValue into field "Contents"
    else
      showArray tGlobalValue
    end if
  else
    get the menuHistory of button "Execution Contexts"
    if it is empty then 
      get the number of lines in the cContexts of button "Execution Contexts"
    end if
    set the debugContext to line it of the cContexts of button "Execution Contexts"
    put line theLineNum of field "Names" into tName
    
    debugDo "revDebuggerGrabValue" && tName
    
    if the keys of gREVVariableWatcherValue is not empty then
      showArray gREVVariableWatcherValue
    else 
      setInvisible "scalar"
      debugdo "put" && tName && "into field" && quote & "Contents" & quote
    end if
  end if
  
  set the curline of this stack to theLineNum
  set the hilitedlines of field "Names" to theLineNum
  set the hilitedlines of field "Values" to theLineNum
end selectVar

on showArray pArray
  local tKeys, tExtents, tArrayDisplayKey, tArrayDisplayValue
  
  --get a list of the keys of the array and test it it contains any non-numeric character
  setInvisible "array"
   
  put the keys of pArray into tKeys
  put the extents of pArray into tExtents
  if tExtents is empty then
    -- The keys contain non-numeric characters so sort appropriately
    -- create the tKeys list again
    put "< array >" into field "Contents"
    sort lines of tKeys ascending text
    repeat for each line tKey in tKeys
      put tKey & return after tArrayDisplayKey
      
      # OK-2007-06-29: Bug 4971
      local tCaseSensitive
      put the caseSensitive into tCaseSensitive
      set the caseSensitive to true
      if the number of lines of pArray[tKey] > 1 then
        put line 1 of pArray[tKey]&"..." & return after tArrayDisplayValue
      else
        put line 1 of pArray[tKey]& return after tArrayDisplayValue
      end if
      set the caseSensitive to tCaseSensitive
    end repeat
    put tArrayDisplayValue into field "contentsArrayValue"
    put tArrayDisplayKey into field "contentsArrayKey"
     
  else
    -- The keys contain only numeric characters so sort appropriately
    -- answer "sorting numeric keys"

    repeat with tDimension = the number of lines of tExtents down to 1
      sort lines of tKeys numeric by item tDimension of each
    end repeat
    repeat for each line tKey in tKeys
      put "[" & tKey & "]" & return after tArrayDisplayKey
      put line 1 of pArray[tKey] & return after tArrayDisplayValue
    end repeat
    put tArrayDisplayValue into field "contentsArrayValue"
    put tArrayDisplayKey into field "contentsArrayKey"
  end if
end showArray

on setVar
  if the number of lines in the cContexts of button "Execution Contexts" is 0 then
    
    get the selectedText of field "Names"
    do "global" && it & "; put field" && quote & "Contents" & quote && "into" && it
  else
    get the menuHistory of button "Execution Contexts"
    if it is empty then get the number of lines in the cContexts of button "Execution Contexts"
    set the debugContext to line it of the cContexts of button "Execution Contexts"
    get the selectedText of field "Names"
    debugdo "put field" && quote & "Contents" & quote && "into" && it
  end if
  get the hilitedLine of field "Names"
  put char 1 to 100 of line 1 of field "Contents" into line it of field "Values" 
  set the hilitedLine of field "Values" to it
end setVar

on resizeStack
  local tWidth, tHt, tHalf, tTopHalf, tArrayHalf
  set the cVariableWatcherRect of stack "revPreferences" to the rect of this stack
  put the width of this stack into tWidth
  put the height of this stack into tHt
  
  if the left of control "vLine" > the width of this cd - 48 then
    put the width of this cd - 52 into tHalf
    set the left of control "vLine" to tHalf
  else put the left of control "vLine" + 3 into tHalf
  
  if the top of control "hLine" > the height of this cd - 48 then
    put the height of this cd - 52 into tTopHalf
    set the top of control "hLine" to tTopHalf
  else put the top of control "hLine" - 30 into tTopHalf
  
  set the height of field "Watched" to tTopHalf + 1
  if the topLeft of field "watched" is 4,32 then
    set the width of field "Names" to tHalf - 18
  else
    set the width of field "names" to tHalf- 7
  end if
  
  
  set the height of field "Names" to tTopHalf + 1
  
  set the width of field "Values" to the width of this cd - tHalf - 4
  set the height of field "Values" to tTopHalf + 1
  set the right of field "Values" to the width of this cd - 4
  
  set the right of control "script" to tWidth -4
  
  set the height of field "contentsArrayValue" to (tHt-the bottom of control "hLine") - 4
  set the width of field "contentsArrayValue" to (tWidth - the right of control "contentsArrayLine") -1
  set the left of field "contentsArrayValue" to (the right of control "contentsArrayLine")-3
  set the top of field "contentsArrayValue" to (the bottom of control "hLine")-3

  set the height of field "Contents" to (tHt-the bottom of control "hLine") - 4
  set the width of field "Contents" to the width of this stack - 8
  set the left of field "Contents" to 4
  set the top of field "Contents" to (the bottom of control "hLine")-3
  
  set the height of control "vLine" to the height of field "Names"
  set the top of control "vLine" to the top of field "names"
  
  set the height of field "contentsArrayKey" to (tHt-the bottom of control "hLine") - 4
  set the top of field "contentsArrayKey" to (the bottom of control "hLine")-3
  set the left of field "contentsArrayKey" to 4
  
  set the width of control "hLine" to the width of this cd
  set the left of control "hLine" to 0
  
  set the width of button "execution contexts" to the width of this cd - 105
  set the right of button "execution contexts" to the right of this cd - 40
  
  set the height of control "contentsArrayLine" to the height of field "contentsArrayValue"
  set the top of control "contentsArrayLine" to the top of field "contentsArrayValue"
  
  saveControlRects
end resizeStack

on setInvisible theType
  lock screen
  set the visible of field "contentsArrayKey" to theType is "array"
  set the visible of field "contentsArrayValue" to theType is "array"
  set the visible of control "contentsArrayLine" to theType is "array"
  set the visible of field "Contents" to theType is "scalar"
  unlock screen
end setInvisible
