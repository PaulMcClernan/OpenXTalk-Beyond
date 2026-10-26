script "stack_revResourceCenter_button_id_578806"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "InsertingSomeTextBeforeEachLineinaField" (id 100240) > group "mainContent" (id 100260) > group (id 578809) > group "Example" (id 578803) > button "Add prefix:" (id 578806)
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
