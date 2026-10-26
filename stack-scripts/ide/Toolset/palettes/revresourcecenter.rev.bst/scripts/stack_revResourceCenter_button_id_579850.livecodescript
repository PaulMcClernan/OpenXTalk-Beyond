script "stack_revResourceCenter_button_id_579850"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Placingafontlistintoamenu" (id 100330) > group "mainContent" (id 100342) > group (id 579852) > group "Example" (id 577033) > button "Font" (id 579850)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick theItem
  answer "You chose" && quote & theItem & quote & "."
end menuPick
