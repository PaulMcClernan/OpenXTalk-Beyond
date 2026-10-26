script "stack_revResourceCenter_field_id_579815"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Scrollingtextbanner" (id 80237) > group "mainContent" (id 80247) > group (id 579816) > group "Example" (id 577025) > field "Animation" (id 579815)
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
