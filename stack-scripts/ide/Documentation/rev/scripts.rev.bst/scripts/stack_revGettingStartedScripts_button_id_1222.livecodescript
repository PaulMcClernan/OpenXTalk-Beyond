script "stack_revGettingStartedScripts_button_id_1222"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Rounding a number up to a ceiling Example" (id 1219) > button "Ceiling" (id 1222)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  answer ceiling(field "Example Number")
end mouseUp

function ceiling theNumber
  if theNumber is not a number then return "Error: not a number"
  if theNumber < zero or theNumber is an integer then
    return trunc(theNumber)
  else
    return 1 + trunc(theNumber)
  end if
end ceiling
