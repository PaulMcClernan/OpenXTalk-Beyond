script "stack_revMessageWatcher_button_id_1008"
-- Stack file: ide/Toolset/palettes/revmessagewatcher.rev
-- Object: stack "revMessageWatcher" > card (id 1002) > button "Suppress..." (id 1008)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  suppressRecording 1
  modal "revSuppressMessages"
  suppressRecording 0
end mouseUp
