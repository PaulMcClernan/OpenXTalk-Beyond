script "stack_revResourceCenter_button_id_580797"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "ListingAllTheHandlersInAScript" (id 113685) > group "mainContent" (id 113705) > group "listinghandlers" (id 113700) > group "Example" (id 580795) > button "List the handlers" (id 580797)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put field "Script" into myScript
  put empty into theTypes
  repeat with x = 1 to the number of buttons of group "Handler Types" of the owner of me
    if the hilite of button x of group "Handler Types" of the owner of me
    then put word 1 of the short name of button x of group "Handler Types" of the owner of me \
        into item (the number of items of theTypes + 1) of theTypes
  end repeat
  repeat for each item thisType in theTypes
    put return & return & thisType && "handlers:" & return \
        & handlerNames(myScript,thisType) after myHandlerList
  end repeat
  put "All handlers:" & return & handlerNames(myScript) before myHandlerList
  answer myHandlerList
end mouseUp

function handlerNames theScript,handlerType
  switch handlerType
  case "message" -- list the message handlers
    filter theScript with "on*"
    break
  case "function" -- list the function handlers
    filter theScript with "function*"
    break
  case "setProp" -- list the setProp handlers
    filter theScript with "setProp*"
    break
  case "getProp" -- list the getProp handlers
    filter theScript with "getProp*"
    break
  default -- list all the handlers, if no type specified
    filter theScript with "end*"
  end switch
  repeat with x = 1 to the number of lines of theScript
   -- word 2 of the first or last line of a handler
    -- is the handler name:
    put word 2 of line x of theScript into line x of theScript
  end repeat
  if theScript is empty then return "(None found)"
  else return theScript
end handlerNames
