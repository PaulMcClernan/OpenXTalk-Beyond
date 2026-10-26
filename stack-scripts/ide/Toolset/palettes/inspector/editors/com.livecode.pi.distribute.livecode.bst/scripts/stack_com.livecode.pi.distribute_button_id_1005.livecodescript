script "stack_com.livecode.pi.distribute_button_id_1005"
-- Stack file: ide/Toolset/palettes/inspector/editors/com.livecode.pi.distribute.livecode
-- Object: stack "com.livecode.pi.distribute" > card (id 1002) > group "template" (id 1007) > group "controls" (id 1008) > button "Distribute Horizontal" (id 1005)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

# This script distributes the space between
# a set of selected objects in equal intervals
# between the first and last objects selected.
# Note that the first and last objects selected
# must be the left and right objects.

on mouseUp
  revSaveLayout
  put the selectedObjects into tObjectNames
  put the number of lines in tObjectNames into tNumberOfObjects
  put 0 into tWidth
  switch the menuHistory of button "Distribution Method"
  case 1
    if tNumberOfObjects < 3 then exit to top
    repeat with i = 2 to tNumberOfObjects -1
      get line i of tObjectNames
      add the width of it to tWidth
    end repeat
    get line 1 of tObjectNames
    put the right of it into tStartX
    get line tNumberOfObjects of tObjectNames
    put the left of it into tEndX
    put (tEndX - tStartX - tWidth) / (tNumberOfObjects -1) into tPerSpace
    put tStartX + tPerSpace into tOffset
    repeat with i = 2 to tNumberOfObjects -1
      get line i of tObjectNames
      set the left of it to round(tOffset)
      add the width of it + tPerSpace to tOffset
    end repeat
    break
  case 3
    if tNumberOfObjects < 1 then exit to top
    repeat with i = 1 to tNumberOfObjects
      get line i of tObjectNames
      add the width of it to tWidth
    end repeat
    get line 1 of tObjectNames
    put word 5 to (the number of words in it) of it into tCardName
    put the width of tCardName into tCardWidth
    put (tCardWidth - tWidth) / (tNumberOfObjects + 1) into tPerSpace
    put tPerSpace into tOffset
    repeat with i = 1 to tNumberOfObjects
      get line i of tObjectNames
      set the left of it to round(tOffset)
      add the width of it + tPerSpace to tOffset
    end repeat
    break
  case 2
    if tNumberOfObjects < 2 then exit to top
    repeat with i = 2 to tNumberOfObjects
      put line i of tObjectNames into tLeftObj
      put line (i - 1) of tObjectNames into tRightObj
      set the left of tLeftObj to the right of tRightObj
    end repeat
    break
  end switch
end mouseUp
