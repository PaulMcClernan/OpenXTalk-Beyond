script "stack_revOnline_group_id_78150"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "search order" (id 78150)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sOrder
local sView
local sDirection
constant kColor = "124,193,222"

command initialize    
   local tSearchPrefs
   put revOnlinePrefGet("lastsearch") into tSearchPrefs
   set the cSelectedOrder of me to tSearchPrefs["searchType"]
   set the cSelectedDirection of me to tSearchPrefs["direction"]   
end initialize

setprop cSelectedOrder pOrder
   # Multiple cases here to account for discrepancy search order terms used in cgi
   # and search order displayed in gui
   local tDisplayOrder
   switch pOrder
      case "Rating"
      case "top rated"
         put "top rated" into sOrder
         put "Rating" into tDisplayOrder
      break
      case "Popularity"
      case "popular"
         put "popular" into sOrder
         put "Popularity" into tDisplayOrder
      break
      case "Date"
      case "latest"
         put "latest" into sOrder
         put "Date" into tDisplayOrder
      break
      default
         put "all" into sOrder
         put "A to Z" into tDisplayOrder
   end switch      
   put tDisplayOrder into field "sort by" of me   
   resize
end cSelectedOrder

getprop cSelectedOrder
   return sOrder
end cSelectedOrder

setProp cSelectedDirection pDirection
   put pDirection into sDirection
   if pDirection is "ascending" then
      set the icon of button "direction" of me to 205461
      set the hiliteIcon of button "direction" of me to 205463
      set the hoverIcon of button "direction" of me to 205463
   else if pDirection is "descending" then
      set the icon of button "direction" of me to 205462
      set the hiliteIcon of button "direction" of me to 205464
      set the hoverIcon of button "direction" of me to 205464
   end if
end cSelectedDirection

getProp cSelectedDirection
   return sDirection
end cSelectedDirection


setProp cSelectedView pView
   put pView into sView
   if pView is "list" then
      set the textStyle of word 3 of field "view as" of me to empty
      set the textColor of word 3 of field "view as" of me to empty
      
      --set the textStyle of word 1 of field "view as" of me to "bold"
      set the textColor of word 1 of field "view as" of me to rvoHiliteColor()
   else if pView is "grid" then
      set the textStyle of word 1 of field "view as" of me to empty
      set the textColor of word 1 of field "view as" of me to empty
      
      --set the textStyle of word 3 of field "view as" of me to "bold"
      set the textColor of word 3 of field "view as" of me to rvoHiliteColor()
   end if
end cSelectedView

getProp cSelectedView
   return sView
end cSelectedView


command resize
   --set the topleft of field "sort by label" of me to (the left of me, the 
   set the left of field "sort by label" of me to the left of me
   set the width of field "sort by" of me to the formattedwidth of field "sort by" of me + 6
   set the left of field "sort by" of me to (the left of field "sort by label" of me + the formattedwidth of field "sort by label" of me - 5)
   set the left of button "direction" of me to the right of field "sort by" of me - 6
   set the right of field "view as" of me to the right of me
   set the right of field "view as label" of me to (the right of field "view as" of me - the formattedwidth of field "view as label" of me - 5)
end resize






