script "stack_revAddLibraryStack_button_id_1008"
-- Stack file: ide/Toolset/palettes/revaddlibrarystack.livecode
-- Object: stack "revAddLibraryStack" > card (id 1002) > button "OK" (id 1008)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  set the cREVResult of this stack to "OK"
  set the cREVStack of this stack to the label of btn "Stack"
  close this stack
end mouseUp
