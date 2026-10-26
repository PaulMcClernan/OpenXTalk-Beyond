script "stack_revSearch_button_id_1342"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002) > group "Folder" (id 1321) > button "Browse..." (id 1342)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  answer folder "Select a Folder"
  if it is not empty then
    set the cDirectory of stack "revSearch" to it
    set the itemDel to "/"
    put the last item of it into fld "folder" of stack "revSearch"
  end if
end mouseUp
