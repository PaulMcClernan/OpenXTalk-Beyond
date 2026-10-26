script "stack_revResourceCenter_field_id_578785"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Shiftingselectedtexttotherightorleft" (id 80409) > group "mainContent" (id 80420) > group (id 571866) > group "Example" (id 578784) > field "Example Text" (id 578785)
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
