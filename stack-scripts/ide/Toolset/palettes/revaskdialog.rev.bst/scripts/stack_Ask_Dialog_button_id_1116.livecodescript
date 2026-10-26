script "stack_Ask_Dialog_button_id_1116"
-- Stack file: ide/Toolset/palettes/revaskdialog.rev
-- Object: stack "Ask Dialog" > card (id 1002) > button "OK" (id 1116)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  --  switch the fieldmode of this card
  --  case "plain"
  --  case "question"
  --  case "error"
  --  case "information"
  --  case "warning"
  --    get field 2
  --    break
  --  case "clear"
  --    get field 3
  --    break
  --  case "password"
  --    get mcencrypt(field 3)
  --    break
  --  end switch
  --  set the dialogData to it
  --  lock messages
  --  close this stack
  --  revCleanUpAskDialog--won't get closeStack
  --  unlock messages
  closeAccept
end mouseUp
