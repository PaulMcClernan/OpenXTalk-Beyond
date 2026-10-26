script "stack_revGettingStartedScripts_field_id_1014"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Scrolling text banner Example" (id 1012) > field "Animation" (id 1014)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put "                                   " \
      & "You too can be a winner!" into me
  repeat until the text of me is empty
    -- shift everything one character to the left:
    delete first character of me
    wait 6 ticks -- 1/10th of a second
  end repeat
end mouseUp
