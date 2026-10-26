script "stack_revResourceCenter_button_id_579726"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "ReversingText" (id 113742) > group "mainContent" (id 113755) > group (id 584246) > group "Example" (id 577014) > button "Reverse It!" (id 579726)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put reversed(field "Example Text") into field "Example Text"
end mouseUp
  
function reversed theString
  repeat with thisChar = the length of theString down to 1
    put char thisChar of theString after reversedString
  end repeat
  return reversedString
end reversed
