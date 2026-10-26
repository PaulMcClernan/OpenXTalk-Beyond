script "stack_revNewScriptEditor_1_field_id_63399"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revNewScriptEditor 1" > card "Main" (id 1002) > group "Left Bar" (id 56896) > group "Left Handler List" (id 63398) > field "Handlers" (id 63399)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
 closeAccept
end mouseUp

on focusOut
  closeReject
end focusOut

on enterInField
  closeAccept
end enterInField

on returnInField
  closeAccept
end returnInField

on arrowKey pKey
  if pKey is among the items of "up,down" then
    selectionScroll pKey
  end if
end arrowKey

private command selectionScroll pDirection
  local tOldSelectedLine
  put word 2 of the selectedLine of me into tOldSelectedLine
  
  local tNewSelectedLine
  if pDirection is "up" then
    if tOldSelectedLine is empty then
      put 1 into tNewSelectedLine
    else if tOldSelectedLine is 1 then
      put 1 into tNewSelectedLine
    else
      put tOldSelectedLine - 1 into tNewSelectedLine
    end if
  end if
  
  if pDirection is "down" then 
    if tOldSelectedLine is empty then
      put 1 into tNewSelectedLine
    else if tOldSelectedLine is the number of lines of me then
      put the number of lines of me into tNewSelectedLine
    else
      put tOldSelectedLine + 1 into tNewSelectedLine
    end if
  end if
  
  select line tNewSelectedLine of me
end selectionScroll










