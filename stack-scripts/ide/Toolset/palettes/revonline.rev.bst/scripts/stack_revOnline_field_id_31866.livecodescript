script "stack_revOnline_field_id_31866"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "viewing pane" (id 31859) > group "stack" (id 31860) > field "tags" (id 31866)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseMove
   lock screen
   local tItem
   put distinguishItem() into tItem
   clearStyles
   if tItem > 0 and item tItem of the text of me is not " ..." then
      set the textStyle of word 1 to -1 of item tItem of me to "underline"
   end if
   unlock screen
end mouseMove

on mouseUp
   lock screen
   local tItem
   put distinguishItem() into tItem
   local tTag
   put word 1 to -1 of item tItem of me into tTag
   # Need to make sure this tag is available in the list else ... maybe should remove user filter at this point
   if tTag is not empty then
      if tTag is among the lines of the cTags of group "search filter" of this stack then
         set the cSelectedTag of group "search filter" of this stack to tTag
      end if
   end if
   unlock screen
end mouseUp


function distinguishItem
   if the mousechunk is not empty then
      lock screen
      local tChar, tTags, tTag
      local x = 1
      put word 2 of the mouseChunk into tChar
      put the text of me into tTags
      put char tChar of tTags into tTag
      repeat with x = 1 to the number of chars in tTags
         put char (tChar + x) of tTags after tTag
         if char - 1 of tTag = comma then 
            delete char -1 of tTag
            exit repeat
         end if
      end repeat
      
      if tChar > 1 then
         repeat with x = 1 to the number of chars in tTags
            put char (tChar - x) of tTags before tTag
            if char 1 of tTag = comma or char 1 of tTag = tab then 
               delete char 1 of tTag
               exit repeat
            end if
         end repeat
      end if
      put word 1 to - 1 of tTag into tTag
      repeat with x = 1 to the number of items in tTags
         if word 1 to -1 of item x of tTags is tTag then
            return x
         end if
      end repeat      
   end if
   return empty
end distinguishItem

command clearStyles
   repeat with x = 1 to the number of items of me
      set the textStyle of item x of me to empty
   end repeat
end clearStyles

on mouseLeave
   clearStyles
end mouseLeave
