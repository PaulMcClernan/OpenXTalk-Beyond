script "stack_revGettingStartedScripts_button_id_1084"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Placing a check next to a menu item Example" (id 1083) > button "Sample" (id 1084)
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
