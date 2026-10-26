script "stack_revGettingStartedScripts_button_id_1089"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Editing the clipboard Example" (id 1086) > button "Append Selected Text" (id 1089)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  appendSelectionToClipboard
  if the result is not empty then answer the result
  put the length of the clipboardData["text"] into word 1 of field "Clipboard Chars"
end mouseUp

on appendSelectionToClipboard
  if the selectedText is empty -- there's no selection, so...
  then return "Error: no text is selected" -- ...never mind
  -- put the selected text at the end of the clipboard:
  set the clipboardData["text"] \
     to the clipboardData["text"] & return & the selectedText
end appendSelectionToClipboard
