script "stack_demos_button_id_1006"
-- Stack file: ide/Resources/Examples/demos.oxtstack
-- Object: stack "demos" > card (id 1002) > button "Open" (id 1006)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on checkDemoStack
   put word 2 of the selectedLine of field "pickList" into myLine
   if isNumber(myLine) is true then
      -- we have a line
      put line myLine of field "pickList" into myDemoStackChosen
      put the storedPath of field "pickList" into myPath
      put myPath & slash & myDemoStackChosen & ".oxtstack" into myDemoStackPath
      if there is a file myDemoStackPath then
         put myDemoStackChosen into field "status"
         hide field "status" -- show for debug field
         set the storedDemoToOpen of field "pickList" to myDemoStackPath
      else
         -- stack does not exist
         show field "status"
         put "stack not found" into field "status"
      end if
   else
      -- no valid line selection
   end if
end checkDemoStack

on mousedown
   put the storedDemoToOpen of field "pickList" into myDemoStackPath
   if there is a file myDemoStackPath then open stack myDemoStackPath
end mousedown
