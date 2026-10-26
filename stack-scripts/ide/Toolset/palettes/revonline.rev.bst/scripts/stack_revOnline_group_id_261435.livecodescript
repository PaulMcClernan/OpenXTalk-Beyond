script "stack_revOnline_group_id_261435"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > group "tag template" (id 261435)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sOriginalText

on keydown pKey
   send "refreshlist" to me in 0 milliseconds
   send "autocomplete 1" to me in 0 milliseconds
   pass keydown
end keydown

on arrowKey pKey
   if pKey is "down" then
      if there is a field "auto copy" of me and the cList of field "auto" of me is not empty then
         if the visible of field "auto copy" of me then
            incrementSelection
         else
            show field "auto copy" of me
         end if
         autoComplete (the cSelectedLine of field "auto copy" of me)
      end if
   else if pKey is "up" then
      if there is a field "auto copy" of me and the cList of field "auto" of me is not empty then
         if the visible of field "auto copy" of me then
            decrementSelection
         end if
         autoComplete (the cSelectedLine of field "auto copy" of me)
      end if
   else 
      --send "refreshList" to me in 0 milliseconds
      pass arrowKey
   end if
   --send "refreshList" to me in 0 milliseconds
end arrowKey

on backSpaceKey
   send "refreshList" to me in 0 milliseconds
   pass backSpaceKey
end backSpaceKey

on deleteKey
   send "refreshList" to me in 0 milliseconds
   pass deleteKey
end deleteKey

command incrementSelection
   local tLine
   put the cSelectedLine of field "auto copy" of me into tLine
   if tLine < the number of lines of field "auto copy" of me then
      add 1 to tLine
      set the cSelectedLine of field "auto copy" of me to tLine
   end if
end incrementSelection
      
command decrementSelection
   local tLine
   put the cSelectedLine of field "auto copy" of me into tLine
   if tLine > 0 then
      subtract 1 from tLine
      set the cSelectedLine of field "auto copy" of me to tLine
      if tLine = 0 then
         hide field "auto copy" of me
      end if
   end if
end decrementSelection
   
command refreshList
   --put "refresh" & return after msg
   lock screen
   
   if there is a field "auto copy" of me then
      delete field "auto copy" of me
   end if
   
   put the text of field "input" of me into sOriginalText
   if the text of field "input" of me is not empty then      
      set the cSelectedLine of field "auto" of me to 0
      local tMatch, tTags
      put the text of field "input" of me & "*" into tMatch
      put the cAllTags of me into tTags
      filter tTags with tMatch
      set the cList of field "auto" of me to tTags
      
      copy field "auto" of me to me
      set the name of it to "auto copy"
      set the topleft of field "auto copy" of me to (the left of field "input" of me, the bottom of field "input" of me - 1)
      
      if the cList of field "auto" of me is not empty then
         show field "auto copy" of me
      else
         hide field "auto copy" of me
      end if
   else
      --hide field "auto copy" of me
      set the cList of field "auto" of me to empty
   end if
   unlock screen
end refreshList

command autoComplete pLine
   lock screen
   put sOriginalText & char (the number of chars of sOriginalText + 1) to -1 of line pLine of the text of field "auto" of me into field "input" of me
   select char (the number of chars of sOriginalText + 1) to -1 of field "input" of me
   unlock screen
end autoComplete

on mouseUp
   local tTarget, tTag
   put the short name of target into tTarget
   --   if tTarget is "submit" and the text of field "input" of me is not empty then
   --      put the text of field "input" of me into tTag
   --      repeat until char 1 of tTag is not space
   --         delete char 1 of tTag
   --      end repeat
   --      submitTag (item 1 of tTag)
   --   else if tTarget is "cancel" then
   --      hide me
   if tTarget is "auto" then
      if the mousetext is not empty then
         autocomplete (word 2 of the mouseline)
      end if
   end if 
end mouseUp

command addTag
   local tTag
   put word 1 to -1 of item 1 of the text of field "input" of me into tTag
   if tTag is not empty then
      ###submitTag (tTag)
      send "submitTag tTag" to the owner of me in 0 milliseconds
   end if
end addTag

command hideMe
   send "hidepalette" to the owner of me in 0 milliseconds
end hideMe



