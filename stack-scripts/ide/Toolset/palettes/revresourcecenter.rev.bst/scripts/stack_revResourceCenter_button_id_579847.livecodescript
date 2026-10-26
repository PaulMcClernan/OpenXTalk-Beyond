script "stack_revResourceCenter_button_id_579847"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Placingachecknexttoamenuitem" (id 100316) > group "mainContent" (id 100328) > group (id 584258) > group "Example" (id 577032) > button "Sample" (id 579847)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick theItem
  put the menuHistory of me into myItemNumber
  if char 1 to 2 of line myItemNumber of me is "!c"
  then delete char 1 to 2 of line myItemNumber of me
  else put "!c" before line myItemNumber of me
  -- This handler just handles the checkmarks. If you
  -- want to do other things in response to a menu choice,
  -- you'll do them here, after the checkmark code. Here's
  -- a simple example:
  answer "You chose" && quote & theItem & quote & "."
end menuPick
