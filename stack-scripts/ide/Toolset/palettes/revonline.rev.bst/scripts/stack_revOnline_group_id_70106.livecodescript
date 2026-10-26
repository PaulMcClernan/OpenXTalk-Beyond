script "stack_revOnline_group_id_70106"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "paging" (id 70106)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sNumberOfPages
local sCurrentPage
local sPageList

command initialize
   set the cPages of me to empty
end initialize

setProp cPageList pPageList
   put pPageList into sPageList
end cPageList

getProp cPageList
   return sPageList
end cPageLIst

setProp cPage pPage
   repeat with x = the number of chars of pPage down to 1
      if char x of pPage is " " or char x of pPage is "." then
         delete char x of pPage
      end if
   end repeat   
   put pPage into sCurrentPage
end cPage

getProp cPage
   return sCurrentPage
end cPage

setProp cPages pPages
   put pPages into sNumberOfPages
   put empty into sPageList
   repeat with x = 1 to sNumberOfPages
      put x & " " after sPageList
   end repeat
   delete char -1 of sPageList
   displayCorrectPageList
   local tItem
   set the itemdelimiter to space
   put itemoffset(sCurrentPage, the text of field "pages" of me) into tItem
   if word 1 of item tItem of field "pages" of me is "..." then
      set the textStyle of word -1 of item tItem of field "pages" of me to "bold"
      set the textColor of word -1 of item tItem of field "pages" of me to rvoHiliteColor()
   else   
      set the textStyle of word 1 of item tItem of field "pages" of me to "bold"
      set the textColor of word 1 of item tItem of field "pages" of me to rvoHiliteColor()
   end if
end cPages

getProp cPages
   return sNumberOfPages
end cPages

command nextPage
   if sCurrentPage + 1 <= sNumberOfPages then
      set the cPage of me to sCurrentPage + 1
      updateSearch
   end if
end nextPage

command prevPage
   if sCurrentPage - 1 > 0 then
      set the cPage of me to sCurrentPage - 1
      updateSearch
   end if
end prevPage

command selectPage pPage
   set the cPage of me to pPage
   updateSearch
end selectPage

command updateSearch
   ## shouldn't reference the other group here
   local tOffset
   put (sCurrentPage - 1) * (the cPageLimit of group "search list" of this stack) into tOffset
   updateSearchList tOffset
end updateSearch

# Creates the string that goes into the pages field, prevents clipping a list of pages too long
command displayCorrectPageList
   lock screen
   put sPageList into field "pages" of me
   set the itemdelimiter to space
   if the formattedwidth of field "pages" of me > the width of field "pages" of me then
      local tList
      local tCounter = 1
      put sCurrentPage into tList
      put empty into field "pages" of me
      repeat until the formattedwidth of field "pages" of me > the width of field "pages" of me
         if sCurrentPage - tCounter > 0 then
            put (sCurrentPage - tCounter) & " " before tList
         end if
         if sCurrentPage + tCounter <= sNumberOfPages then
            put  " " & (sCurrentPage + tCounter) after tList
         end if
         put tList into field "pages" of me
         add 1 to tCounter
      end repeat   
      ### Need to alternate removing items from front and end of list
      local tAlternate
      if (sNumberOfPages - sCurrentPage) < sCurrentPage then
         put "false" into tAlternate
      else
         put "true" into tAlternate
      end if
      
      repeat until the formattedwidth of field "pages" of me < the width of field "pages" of me
         if tAlternate then
            if item -1 of tList is not sNumberOfPages and item -2 of tList is not "..." then
               delete item - 1 of tList
               put " ..." && sNumberOfPages after tList
            else if item -1 of tList is sNumberOfPages and item -2 of tList is "..." then
               delete item -3 of tList
            end if
            put "false" into tAlternate
         else
            if item 1 of tList is not 1 and item 2 of tList is not "..." then
               delete item 1 of tList
               put "1 ... " before tList
            else if item 1 of tList is 1 and item 2 of tList is "..." then
               delete item 3 of tList
            end if        
            put "true" into tAlternate
         end if
         # Need a fail safe to prevent infinite loop if item 1 is 1 and last item is sNumberOfPages
         if item 1 of tList is 1 and item 2 of tList is not "..." and item -1 of tList is sNumberOfPages and item -2 of tList is not "..." then
            if sCurrentPage > (sNumberOfPages - sCurrentPage) then
               # Selected page is closer to end of list so remove item 1
               delete item 1 of tList
               put "1 ... " before tList
            else
               # Selected page is closer to start of list so remove item -1
               delete item - 1 of tList
               put " ..." && sNumberOfPages after tList
            end if
         end if
         put tList into field "pages" of me
      end repeat
   end if
   # Need to remove trailing spaces   
   repeat until char -1 of field "pages" of me is not space
      delete char -1 of field "pages" of me
   end repeat
   unlock screen
end displayCorrectPageList

command resize
   set the topleft of field "pages label" of me to (the left of me, the top of me - 2)
   set the topleft of button "prev" of me to (the right of field "pages label" of me - 5, the top of me)
   set the topright of button "next" of me to the topright of me
   set the rect of field "pages" of me to \
   (the right of button "prev" of me - 4, the top of me, the left of button "next" of me + 4, the bottom of me)
end resize

command clearColors pTarget   
   set the itemdelimiter to space
   repeat with x = 1 to the number of items of the text pTarget
      if the textStyle of word 1 of item x of pTarget is not "bold" then
         set the textColor of item x of pTarget to (the foregroundcolor of stack "revonline")
      end if
   end repeat
end clearColors

command clearStyles pTarget
   set the textstyle of pTarget to empty
end clearStyles
