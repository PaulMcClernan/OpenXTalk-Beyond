script "stack_revDocsShortcut_Reference_field_id_1003"
-- Stack file: ide/Documentation/rev/Shortcut Reference.rev
-- Object: stack "revDocsShortcut Reference" > card (id 1002) > field "doc" (id 1003)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseMove
  highlightLink
  pass mouseMove
end mouseMove

on mouseEnter
  lock cursor
  pass mouseEnter
end mouseEnter

on mouseLeave
  clearHighlight
  if the mouseStack is not the short name of me then unlock cursor
  pass mouseLeave
end mouseLeave

-- ----------------------------------
-- handlers for glossary highlighting
-- ----------------------------------

on highlightLink currentMouseChunk
  -- set cursor to hand over hypertext phrases, I-beam over Find field, arrow otherwise
  -- highlight hypertext phrases (if they're not Transcript terms or URLs)
  --if char 1 to 7 of the short name of this stack is not "revDocs" then exit revDocsHighlight
  if currentMouseChunk is empty then put the mouseChunk into currentMouseChunk
  global gRevHelpHiliteColor
  -- first unhighlight the "old" phrase if necessary
  if the storedHilitedChunk of this stack is not empty \
      and the storedHilitedChunk of this stack is not currentMouseChunk then
    --put the mouseText & return after field "things"
    do "set the foregroundColor of" && (the storedHilitedChunk of this stack) && "to empty"
    set the storedHilitedChunk of this stack to empty
  end if
  -- check where we are to see the desired state of the cursor
  put the mouseText into tText
  if tText <> "" then -- over hypertext
    set the storedHilitedChunk of this stack to currentMouseChunk -- save for later unhighlighting
    set the foregroundColor of the mouseChunk to gRevHelpHiliteColor
    put the uDescription[tText] of this stack into fld "description"
  end if
end highlightLink

on clearHighlight
  if the storedHilitedChunk of this stack is not empty then
    do "set the foregroundColor of" && (the storedHilitedChunk of this stack) && "to empty"
    set the storedHilitedChunk of this stack to empty
  end if
  if the mouseStack is not the short name of this stack then unlock cursor
end clearHighlight
