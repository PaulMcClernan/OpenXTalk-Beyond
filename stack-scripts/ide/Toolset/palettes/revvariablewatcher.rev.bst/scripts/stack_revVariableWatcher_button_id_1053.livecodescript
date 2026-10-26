script "stack_revVariableWatcher_button_id_1053"
-- Stack file: ide/Toolset/palettes/revvariablewatcher.rev
-- Object: stack "revVariableWatcher" > card "home" (id 1002) > button "hLine" (id 1053)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local dragging
on mouseDown
  put true into dragging
end mouseDown

on mouseMove x,y
  local tTop
  
  if dragging then
    put min(max(y, 64),the height of this cd - 48) into tTop
    set the top of me to tTop
    repeat for each item tFieldName in "Watched,Names,Values"
      get the rect of fld tFieldName
      put tTop + 3 into item 4 of it
      set the rect of fld tFieldName to it
    end repeat
    get the rect of control "vLine" 
    put tTop + 3 into item 4 of it
    set the rect of control "vLine" to it
    
    get the rect of fld "contents"
    put tTop + 5 into item 2 of it
    set the rect of fld "contents" to it 
    
    get the rect of fld "contentsArrayKey"
    put tTop + 5 into item 2 of it
    set the rect of fld "contentsArrayKey" to it 
    
    get the rect of fld "contentsArrayValue"
    put tTop + 5 into item 2 of it
    set the rect of fld "contentsArrayValue" to it
    
    get the rect of control "contentsArrayLine" 
    put tTop + 3 into item 2 of it
    set the rect of control "contentsArrayLine" to it
    
    --resizeStack
  end if
end mouseMove


on mouseUp
  put false into dragging
  resizeStack
end mouseUp

on mouseRelease
  put false into dragging
  resizeStack
end mouseRelease

on mouseEnter
  set cursor to 30
  lock cursor
end mouseEnter

on mouseLeave
  unlock cursor
end mouseLeave
