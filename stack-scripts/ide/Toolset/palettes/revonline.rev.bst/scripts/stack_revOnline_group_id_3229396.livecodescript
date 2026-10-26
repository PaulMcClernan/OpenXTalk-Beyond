script "stack_revOnline_group_id_3229396"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "templates" (id 157677) > group "tag template 2" (id 3229396)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sOriginalText
local sPages
local sCurrentPage

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
   --   else if tTarget is "cancel" then
   --      hide me
   if tTarget is "auto copy" then
      if the mousetext is not empty then
         autocomplete (word 2 of the mouseline)
         hide field "auto copy" of me
      end if
   end if 
end mouseUp

local sTags

command displayTags pTags
   put empty into sTags
   repeat for each item tTag in pTags
      put word 1 to -1 of tTag into tTag
      put tTag & comma after sTags
      copy group "tag item template" of card "templates" of stack "revonline" to me
      set the name of it to "tag" & tTag
      set the showBorder of group ("tag" & tTag) of me to false
      put capitaliseChar1(tTag) into field "name" of group ("tag" & tTag) of me
      set the height of field "name" of group ("tag" & tTag) of me to the formattedheight of field "name" of group ("tag" & tTag) of me - 6
      set the top of field "name" of group ("tag" & tTag) of me to the top of button 1 of group ("tag" & tTag) of me + 2
      set the height of group ("tag" & tTag) of me to the formattedheight of group ("tag" & tTag) of me
   end repeat
   delete char -1 of sTags
   wrapObjects
   put 1 into sCurrentPage
   showPage
   focus on field "input" of me
end displayTags

command addTag
   local tTag
   put word 1 to -1 of item 1 of the text of field "input" of me into tTag
   if tTag is not empty then
      put empty into field "input" of me
      if tagIsNew(tTag) then
         if there is a field "auto copy" of me then
            hide field "auto copy" of me
         end if
         if sTags is not empty then
            put comma & space & tTag after sTags
         else
            put tTag into sTags
         end if
         lock screen
         copy group "tag item template" of card "templates" of stack "revonline" to me
         set the name of it to "tag" & tTag
         set the showBorder of group ("tag" & tTag) of me to false
         put capitaliseChar1(tTag) into field "name" of group ("tag" & tTag) of me
         set the height of field "name" of group ("tag" & tTag) of me to the formattedheight of field "name" of group ("tag" & tTag) of me - 6
         set the top of field "name" of group ("tag" & tTag) of me to the top of button 1 of group ("tag" & tTag) of me + 2
         set the height of group ("tag" & tTag) of me to the formattedheight of group ("tag" & tTag) of me
         unlock screen
      end if
      wrapObjects
      showPage
   end if
end addTag

command wrapObjects
   lock screen
   clearPages
   local tTagList   
   local tTop, tLeft
   put the bottom of field "input" of me + 2 into tTop
   
   local tPageName
   
   
   local tNewPage = "true"
   local tPageNumber = 1
   local tTagGroupName, tPageGroupName
   sort items of sTags ascending
   repeat with x = 1 to the number of items in sTags
      --breakpoint
      put "tag" & (word 1 to -1 of item x of sTags) into tTagGroupName
      --put tTagGroupName & return after msg
      if tNewPage then
         put "page" && tPageNumber into tPageGroupName
         put tPageGroupName & return after sPages
         put the left of me + 10 into tLeft
         put the bottom of field "input" of me + 2 into tTop
         create group tPageGroupName in me
         --set the showborder of group tPageGroupName of me to true
         --breakpoint
         set the lockLoc of group tPageGroupName of me to true
         set the rect of group tPageGroupName of me to (the left of me, the bottom of field "input" of me, the right of me, the top of button "next" of me)
         put empty into tNewpage
      end if
      --      if there is a group tPageGroupName of me then
      --         breakpoint
      --      end if
      
      if there is a group tTagGroupName of me then
         copy group tTagGroupName of me to group tPageGroupName of me
         set the topleft of group tTagGroupName of group tPageGroupName of me to (tLeft, tTop)    
         
         if (the bottom of group tTagGroupName of group tPageGroupName of me + 5) > the top of button "next" of me then
            if tLeft is the left of me + 10 then
               put the left of me + (the width of me / 2) into tLeft
               put the bottom of field "input" of me + 2 into tTop
               set the topleft of group tTagGroupName of group tPageGroupName of me to (tLeft, tTop)
            else
               delete group tTagGroupName of group tPageGroupName of me
               subtract 1 from x
               add 1 to tPageNumber
               put true into tNewpage
               next repeat
            end if            
         end if
         put the bottom of group tTagGroupName of group tPageGroupName of me into tTop
         
      end if
   end repeat
   unlock screen   
end wrapObjects
   
command clearPages
   --put sPages
   repeat for each line tPage in sPages
      if there is a group tPage of me then
         delete group tPage of me
      end if
   end repeat
   put empty into sPages
end clearPages
   
command nextPage
   if sCurrentPage < the number of lines in sPages then
      add 1 to sCurrentPage
      showPage
   end if
end nextPage

command prevPage
   if sCurrentPage > 1 then
      subtract 1 from sCurrentPage
      showPage
   end if
end prevPage

command lastPage
   put the number of lines in sPages into sCurrentPage
   showPage
end lastPage

command firstPage
   put 1 into sCurrentPage
   showPage
end firstPage

command showPage
   local tPageName
   put "page" && sCurrentPage into tPageName
   repeat for each line tPage in sPages
      if there is a group tPage of me then
         if tPage is tPageName then
            show group tPage of me
         else
            hide group tPage of me
         end if
      end if
   end repeat
   if sCurrentPage is 1 then
      disable button "prev" of me
      disable button "first" of me
   else
      enable button "prev" of me
      enable button "first" of me
   end if
   if sCurrentPage is the number of lines of sPages or the number of lines of sPages is 0 then
      disable button "next" of me
      disable button "last" of me
   else
      enable button "next" of me
      enable button "last" of me
   end if
   
end showPage


command submitTagsRequest
   local tTagArray, tTag
   repeat with x = 1 to the number of items in sTags
      put word 1 to -1 of item x of sTags into tTag
      if there is a group ("tag" & tTag) of me then
         put tTag into tTagArray[x]
      end if
   end repeat
   send "submitTags tTagArray" to the owner of me in 0 milliseconds
end submitTagsRequest

command removeTag pTag
   if there is a group ("tag" & pTag) of me then
      delete group ("tag" & pTag) of me
      local tItem
      put itemoffset(pTag, sTags) into tItem
      delete item tItem of sTags
   end if
   wrapObjects
   showPage
end removeTag

function tagIsNew pTag
   local tTag
   repeat with x = 1 to the number of items in sTags
      put word 1 to -1 of item x of sTags into tTag
      if pTag is tTag then
         return false
      end if
   end repeat
   return true
end tagIsNew

command resetAll
   put empty into sTags
   repeat with x = the number of groups of me down to 1
      delete group x of me
   end repeat
end resetAll

command hideMe
   send "hidepalette" to the owner of me in 0 milliseconds
end hideMe
