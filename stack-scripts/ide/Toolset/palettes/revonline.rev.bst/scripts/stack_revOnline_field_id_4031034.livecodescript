script "stack_revOnline_field_id_4031034"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > field "Order menu" (id 4031034)
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
         set the textColor of line x of me to "white"
      end if
   end repeat
end colorizeList

on mouseMove
   local tLine
   get the mouseLine
   put word 2 of it into tLine
   hiliteHoverText tLine, (the long id of me)
end mouseMove

on mouseLeave
   clearColors (the long id of me)
   send "hideMe" to me in 300 milliseconds
end mouseLeave

command hideMe
   if the mousecontrol is not empty then
      if the long id of the mousecontrol is not the long id of field "sort by" of group "search order" of stack "revonline" then
         hide me
         if there is a field "sort by" of group "search order" of stack "revonline" then
            set the textStyle of field "sort by" of group "search order" of stack "revonline" to empty
         end if
      end if
   else
      hide me
      if there is a field "sort by" of group "search order" of stack "revonline" then
         set the textStyle of field "sort by" of group "search order" of stack "revonline" to empty
      end if
   end if
end hideMe

# Hilite selected line
command hiliteText pText pFieldID
   lock screen
   repeat with x = 1 to the number of lines of the text of pFieldID
      set the textColor of line x of pFieldID to "50,50,50"
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
      set the textColor of line x of pFieldID to "50,50,50"
   end repeat
end clearColors

on mouseUp
   local tLine, tOrdering
   put word 2 of the mouseLine into tLine
   if the mousetext is not empty then
      put line tLIne of me into tOrdering
      if there is a field "sort by" of group "search order" of stack "revonline" then
         set the textStyle of field "sort by" of group "search order" of stack "revonline" to empty
      end if
      set the cSelectedOrder of group "search order" of this card of stack "revonline" to tOrdering
      updateSearchList 0
   end if
   hide me
end mouseUp













