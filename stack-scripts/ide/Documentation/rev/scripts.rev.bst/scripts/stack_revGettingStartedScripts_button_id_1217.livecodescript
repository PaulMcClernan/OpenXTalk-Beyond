script "stack_revGettingStartedScripts_button_id_1217"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Reversing text Example" (id 1215) > button "Reverse It!" (id 1217)
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
