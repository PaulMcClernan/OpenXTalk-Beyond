script "stack_revResourceCenter_button_id_579884"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Printingallthefieldsonacard" (id 78001) > group "mainContent" (id 78015) > group (id 579890) > group "Example" (id 577044) > button "Print This Card" (id 579884)
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
