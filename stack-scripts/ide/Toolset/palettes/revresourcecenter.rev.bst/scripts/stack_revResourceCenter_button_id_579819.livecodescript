script "stack_revResourceCenter_button_id_579819"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Editingtheclipboard" (id 102558) > group "mainContent" (id 102572) > group (id 579822) > group "Example" (id 577026) > button "Append Selected Text" (id 579819)
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
