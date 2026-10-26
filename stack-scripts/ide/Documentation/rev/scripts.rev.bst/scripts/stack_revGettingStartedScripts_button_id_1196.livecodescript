script "stack_revGettingStartedScripts_button_id_1196"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Printing all cards that contain a word Example" (id 1195) > button "Print cards with" (id 1196)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  get field "String"
  if it is empty then beep
  else
    set the defaultStack to the topStack
    answer "Printing all cards that contain " & it \
        & " in " & the title of the defaultStack & "." \
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
