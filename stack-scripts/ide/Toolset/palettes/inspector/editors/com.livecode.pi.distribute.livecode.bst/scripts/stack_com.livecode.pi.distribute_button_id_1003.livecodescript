script "stack_com.livecode.pi.distribute_button_id_1003"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.distribute.livecode
-- Object: stack "com.livecode.pi.distribute" > card (id 1002) > group "template" (id 1007) > group "controls" (id 1008) > button "Distribute Vertical" (id 1003)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

# This script distributes the space between
# a set of selected objects in equal intervals
# between the first and last objects selected.
# Note that the first and last objects selected
# must be the top and bottom objects.

on mouseUp
  revSaveLayout
  put the selectedObjects into tObjectNames
  put the number of lines in tObjectNames into tNumberOfObjects
  put 0 into tObjectHeight
  switch the menuHistory of button "Distribution Method"
  case 1
    if tNumberOfObjects < 3 then exit to top
    repeat with i = 2 to tNumberOfObjects -1
      get line i of tObjectNames
      add the height of it to tObjectHeight
    end repeat
    get line 1 of tObjectNames
    put the bottom of it into tStartY
    get line tNumberOfObjects of tObjectNames
    put the top of it into tEndY
    put (tEndY - tStartY - tObjectHeight) / (tNumberOfObjects -1) into tPerSpace
    put tStartY + tPerSpace into tOffset
    repeat with i = 2 to tNumberOfObjects -1
      get line i of tObjectNames
      set the top of it to round(tOffset)
      add the height of it + tPerSpace to tOffset
      send "revCacheGeometry true" to it
    end repeat
    break
  case 3
    if tNumberOfObjects < 1 then exit to top
    repeat with i = 1 to tNumberOfObjects
      get line i of tObjectNames
      add the height of it to tObjectHeight
    end repeat
    get line 1 of tObjectNames
    put word 5 to (the number of words in it) of it into tCardName
    put the height of tCardName into tCardHeight
    put (tCardHeight - tObjectHeight) / (tNumberOfObjects + 1) into tPerSpace
    put tPerSpace into tOffset
    repeat with i = 1 to tNumberOfObjects
      get line i of tObjectNames
      set the top of it to round(tOffset)
      add the height of it + tPerSpace to tOffset
      send "revCacheGeometry true" to it
    end repeat
    break
  case 2
    if tNumberOfObjects < 2 then exit to top
    repeat with i = 2 to tNumberOfObjects
      put line i of tObjectNames into tBottomObj
      put line (i - 1) of tObjectNames into tTopObj
      set the top of tBottomObj to the bottom of tTopObj
      send "revCacheGeometry true" to tBottomObj
    end repeat
  end switch
end mouseUp
