script "stack_revVariableWatcher_button_id_1057"
-- Stack file: ide/Toolset/palettes/revvariablewatcher.rev
-- Object: stack "revVariableWatcher" > card "home" (id 1002) > button "vLine" (id 1057)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local dragging

on mouseDown
  put true into dragging
end mouseDown

on mouseMove x, y
  local tRect
  
  if dragging then
    set the left of me to min(max(x, the left of field "Names" + 24),the width of this cd - 48)
    put the rect of fld "names" into tRect
    put the left of me into item 3 of tRect
    set the rect of fld "names" to tRect
    put the rect of fld "values" into tRect
    put the right of me - 5 into item 1 of tRect
    set the rect of fld "values" to tRect
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
  set cursor to 31
  lock cursor
end mouseEnter

on mouseLeave
  unlock cursor
end mouseLeave
