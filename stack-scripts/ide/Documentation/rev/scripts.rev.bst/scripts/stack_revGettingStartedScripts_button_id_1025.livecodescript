script "stack_revGettingStartedScripts_button_id_1025"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Inserting some text before each line in a field Example" (id 1022) > button "Add prefix:" (id 1025)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put prefixed(field "List",field "Prefix") into field "List"
end mouseUp

function prefixed listOfLines,thePrefix
  repeat for each line theLine in listOfLines
    put thePrefix & theLine & return after newList
  end repeat
  return char 1 to -2 of newList -- leave off trailing return
end prefixed
