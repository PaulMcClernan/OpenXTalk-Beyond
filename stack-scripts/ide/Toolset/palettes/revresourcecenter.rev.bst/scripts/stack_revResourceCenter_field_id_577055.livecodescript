script "stack_revResourceCenter_field_id_577055"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Linktextrollovereffect" (id 80250) > group "mainContent" (id 80257) > group (id 584230) > group "Example" (id 577002) > field "Highlighted Text Sample" (id 577055)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local storedHilitedChunk

on mouseMove
  -- first unhighlight the "old" phrase if necessary:
  if storedHilitedChunk is not empty \
      and storedHilitedChunk is not the mouseChunk then
    do "set the backgroundColor of" && \
        storedHilitedChunk && "to empty"
    put empty into storedHilitedChunk
  end if
  -- highlight if the text under the mouse is linked:
  if the mouseChunk is not empty \
      and "link" is in the textStyle of the mouseChunk then
    set the backgroundColor of the mouseChunk to "yellow"
    -- saved for later unhighlighting
    put the mouseChunk into storedHilitedChunk
  end if
  pass mouseMove 
end mouseMove

on mouseLeave
  -- unhighlight any currently highlighted text:
  if storedHilitedChunk is not empty then
    do "set the backgroundColor of" && \
       storedHilitedChunk && "to empty"
    put empty into storedHilitedChunk
  end if
  pass mouseLeave
end mouseLeave
