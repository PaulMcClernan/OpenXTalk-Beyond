script "stack_revGettingStartedScripts_button_id_1199"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Printing all the fields on a card Example" (id 1198) > button "Print This Card" (id 1199)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  printAllFields
end mouseUp

on printAllFields
  repeat with thisField = 1 to the number of fields
    -- collect data in collectedFields variable:
    put "<p><b>" & the short name of field thisField \
       & ":</b></p>" \
       & the htmlText of field thisField after collectedFields
  end repeat
  -- print the variable
  revShowPrintDialog false, true
  revPrintText collectedFields
end printAllFields
