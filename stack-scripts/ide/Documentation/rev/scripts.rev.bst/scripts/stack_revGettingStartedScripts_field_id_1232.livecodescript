script "stack_revGettingStartedScripts_field_id_1232"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Shifting selected text to the right or left Example" (id 1231) > field "Example Text" (id 1232)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on tabKey
  if the selectedText is empty then pass tabKey
  -- there's an insertion point, but no selection,
  -- so let tab key operate normally. Otherwise...
  put the selectedLines into savedSelectedLines -- save for later
  put word 2 of the selectedLines into firstLine
  if word 3 of the selectedLines is "to" then
    -- multiple lines are selected
    put word 4 of the selectedLines into lastLine
  else -- single line is selected
    put firstLine into lastLine
  end if
  if the shiftKey is down then -- shift left - remove a tab:
    repeat with thisLine = firstLine to lastLine
      if char 1 of line thisLine \
          of (the text of the selectedField) is tab
      then delete char 1 of line thisLine \
          of the selectedField -- remove leading tab
    end repeat
  else -- shift key not down, so shift right - add a tab:
    repeat with thisLine = firstLine to lastLine
      -- add a leading tab to each line in the selection
      put tab before line thisLine of the selectedField
    end repeat
  end if
  select savedSelectedLines -- (re)select all affected lines
end tabKey
