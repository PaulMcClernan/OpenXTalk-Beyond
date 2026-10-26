script "stack_revMenuManager_button_id_7536"
-- Stack file: ide/Toolset/palettes/revmenumanager.rev
-- Object: stack "revMenuManager" > card "Menu Manager" (id 1002) > group "Menu Item Controls" (id 3265) > button "Control" (id 7536)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if not the hilite of btn "Command" and not the hilite of btn "Option_Alt" then
      set the hilite of me to false  --TL 12/22, no shift only allowed
   else updateMenuLine
end mouseUp
