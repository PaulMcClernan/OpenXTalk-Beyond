script "stack_revResourceCenter_button_id_579881"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Printingallcardsthatcontainaword" (id 77987) > group "mainContent" (id 77997) > group (id 579883) > group "Example" (id 577043) > button "Print cards with" (id 579881)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  get field "String"
  if it is empty then beep
  else
    set the defaultStack to the topStack
    answer "Printing all cards that contain “" & it \
        & "” in “" & the title of the defaultStack & "”." \
        with "Cancel" or "OK"
    if it is "OK" then printCardsWith it
  end if
end mouseUp

on printCardsWith stringToFind,fieldName
  unmark all cards
  if fieldName is empty then -- search all fields
    mark cards by finding stringToFind
  else
    mark cards by finding stringToFind in field fieldName
  end if
  print marked cards
end printCardsWith
