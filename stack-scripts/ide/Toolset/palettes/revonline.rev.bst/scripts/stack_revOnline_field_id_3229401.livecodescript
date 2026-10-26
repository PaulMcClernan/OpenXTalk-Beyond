script "stack_revOnline_field_id_3229401"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > group "tag template 2" (id 3229396) > field "Auto" (id 3229401)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sLine, sList

getProp cList
   return sList
end cList

setProp cList pList
   # want to remove all capitalisation
   local tNewList
   repeat for each line tLine in pList
      put toLower(tLine) & return after tNewList
   end repeat
   delete char -1 of tNewList
   put tNewList into me
   put tNewList into sList
   set the height of me to the formattedheight of me
end cList

setProp cSelectedLine pLine
   put pLine into sLine
   colorizeList
end cSelectedLine

getProp cSelectedLine
   return sLine
end cSelectedLine

private command colorizeList
   repeat with x = 1 to the number of lines of me
      if x is sLine then
         set the textColor of line x of me to rvoHiliteColor()
      else
         set the textColor of line x of me to empty
      end if
   end repeat
end colorizeList

on mouseMove
   if the tool is "browse tool" then
      local tLine
      get the mouseLine
      put word 2 of it into tLine
      hiliteHoverText tLine, (the long id of me)
   end if
end mouseMove

on mouseLeave
   if the tool is "browse tool" then
      clearColors (the long id of me)
   end if
end mouseLeave

# Hilite selected line
command hiliteText pText pFieldID
   lock screen
   repeat with x = 1 to the number of lines of the text of pFieldID
      set the textColor of line x of pFieldID to "white"
   end repeat
   local tLine 
   put lineoffset (pText, the text of pFieldID) into tLine
   set the textColor of line tLine of pFieldID to rvoHiliteColor()
   set the textStyle of line tLine of pFieldID to "bold"
   unlock screen
end hiliteText

# Hilite current mousetext
command hiliteHoverText pLine pFieldID
   lock screen
   clearColors pFieldID
   if the mouseText is not empty then
      set the textColor of line pLine of pFieldID to rvoHiliteColor()
   end if
   unlock screen
end hiliteHoverText

# Remove hiliting
command clearColors pFieldID
   repeat with x = 1 to the number of lines of the text of pFieldID
      set the textColor of line x of pFieldID to empty
   end repeat
end clearColors















