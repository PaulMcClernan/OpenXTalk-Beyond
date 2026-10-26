script "stack_revOnline_group_id_1007"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "search filter" (id 1007)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sSearchString, sSelectedType, sSelectedTag, sSelectedUser

command initialize
   put empty into sSearchString   
   put empty into field "types" of me
   put empty into field "tags" of me
   listTypes      
end initialize

################################################################################
# Get / Set Props
################################################################################

#   Sets the list of types on the left of the object to pTypes : a return-delimited list of object types to display
setProp cTypes pTypes
   put "All" & return into field "types" of me
   repeat for each line tLine in pTypes
      if tLine is "code snippet" then
         put "code" into tLine
      else if tLine is "normal" then
         put "stack" into tLine
      end if
      put capitaliseChar1(tLine) & return after field "types" of me
   end repeat
   delete char -1 of field "types" of me
end cTypes

getProp cTags
   return the text of field "tags" of me
end cTags

#   Sets the list of tags on the right of the object to pTags : a return-delimited list of tags to display
setProp cTags pTags
   lock screen
   put "All" & return into field "tags" of me
   repeat for each line tLine in pTags
      put capitaliseChar1(tLine) & return after field "tags" of me
   end repeat
   delete char -1 of field "tags" of me
   hiliteText sSelectedTag, the long id of field "tags" of me
   resize
   unlock screen
end cTags

# search string
setProp cSearchString pString
   put pString into field "search" of me
   put pString into sSearchString
   updateSearch
end cSearchString

getProp cSearchString
   return the text of field "search" of me
end cSearchString

# type
setProp cSelectedType pType
   local tDisplayType
   --if pType is not sSelectedType then
   switch pType
      case "external"
         put "external" into sSelectedType
         put "External" into tDisplayType
      break
      case "stack"
      case "normal"
         put "normal" into sSelectedType
         put "Stack" into tDisplayType
      break
      case "code"
      case"code snippet"
         put "code snippet" into sSelectedType
         put "Code" into tDisplayType
      break
      default
         put empty into sSelectedType
         put "All" into tDisplayType
   end switch
   hiliteText tDisplayType, the long id of field "types" of me
   listTags
   --end if
   
end cSelectedType

getProp cSelectedType
   return sSelectedType
end cSelectedType

setProp cSelectedTag pTag   
   if pTag is not sSelectedTag then
      put pTag into sSelectedTag
      updateSearch
   end if
   hiliteText pTag, the long id of field "tags" of me
end cSelectedTag

getProp cSelectedTag
   return sSelectedTag
end cSelectedTag

setProp cSelectedUser pUser
   lock screen
   put pUser into sSelectedUser
   # User filter field
   if pUser is not empty then
      show field "user filter" of me
      if pUser is revOnlineId() then
         put "My uploads" into field "user filter" of me
      else
         send "clearStyles" to field "controls" of group "menubar" of this stack
         send "clearColors" to field "controls" of group "menubar" of this stack
      end if
   else
      hide field "user filter" of me
      put empty into field "user filter" of me
      send "clearStyles" to field "controls" of group "menubar" of this stack
      send "clearColors" to field "controls" of group "menubar" of this stack
   end if
   listTags
   resize
   unlock screen
end cSelectedUser

getProp cSelectedUser
   return sSelectedUser
end cSelectedUser

################################################################################
# Functions / Commands
################################################################################

command listTypes
   local tCallback
   put revCallbackCreate(the long id of me, "listTypesCallback") into tCallback
   rvoListTypes tCallback
end listTypes

command listTypesCallback pTypes
   set the cTypes of me to pTypes   
   # Initialization related
   local tSearchPrefs, tObjectType
   put revOnlinePrefGet("lastsearch") into tSearchPrefs
   put tSearchPrefs["tag"] into sSelectedTag  
   set the cSelectedType of me to tSearchPrefs["objectType"]
   set the cSelectedUser of me to empty 
end listTypesCallback

command listTags
   local tCallback
   set the cTags of me to empty
   put revCallbackCreate(the long id of me, "listTagsCallback") into tCallback
   rvoListTags sSelectedType, empty, 0, 100, tCallback, empty, sSelectedUser, true
end listTags

command listTagsCallback pTags
   if sSelectedTag is not among the lines of pTags then
      put "all" into sSelectedTag
   end if
   set the cTags of me to pTags 
   updateSearch
end listTagsCallback

command updateSearch
   updateSearchList 0
end updateSearch


command resize
   
   
   set the rect of field "search" of me to \
         (the left of me + 4, the top of me + 4, the left of me + 170, the top of me + 24)
   --(the left of me + 5, the top of me + 9, the left of button "go" of me, the top of me + 29)
   --(the left of me + 5, the top of me + 6, the left of button "go" of me, the top of me + 26)
   --set the rect of image "search background" of me to the rect of field "search" of me
   set the topLeft of button "go" of me to the (right  of field "search" of me + 4, the top of field "search" of me)
   
   if the cSelectedUser of me is empty then
      set the bottomleft of field "user filter" of me to (the left of me, the top of me - 20)
      set the bottomleft of button "remove user filter" of me to the bottomright of field "user filter" of me
      set the rect of field "types" of me to \
            (the left of me, the top of me + 28, the left of me + 90, the bottom of me)
      --(the left of me, the bottom of field "search" of me + 2, the left of me + 90, the bottom of me)
      set the rect of field "tags" of me to \
            (the right of field "types" of me, the top of me + 45, the right of me, the bottom of me - 10)   
      --(the right of field "types" of me, the bottom of field "search" of me + 15, the right of me, the bottom of me - 10)   
      set the loc of button "up" of me to (item 1 of the loc of field "tags" of me, the top of field "tags" of me - 4)
      set the loc of button "down" of me to (item 1 of the loc of field "tags" of me, the bottom of me - 5)
   else
      set the bottomleft of button "remove user filter" of me to (the left of me + 7, the bottom of field "search" of me + 29)
      set the rect of field "user filter" of me to \
            (the right of button "remove user filter" of me - 5, the bottom of field "search" of me + 5, the right of me, the bottom of field "search" of me + 32)
      set the rect of field "types" of me to \
            (the left of me, the bottom of field "user filter" of me - 5, the left of me + 90, the bottom of me)
      set the rect of field "tags" of me to \
            (the right of field "types" of me, the bottom of field "user filter" of me + 12, the right of me, the bottom of me - 10)   
      set the loc of button "up" of me to (item 1 of the loc of field "tags" of me, the bottom of field "user filter" of me + 10)
      set the loc of button "down" of me to (item 1 of the loc of field "tags" of me, the bottom of me - 5)
   end if
   if the formattedheight of field "tags" of me > the height of field "tags" of me then
      enable button "up" of me
      enable button "down" of me
   else
      disable button "up" of me
      disable button "down" of me
   end if
   set the bottomleft of image "revLogo" of me to (the left of me, the bottom of me - 5)
end resize

################################################################################
# GUI related methods
################################################################################

# Hilite selected tag or type
command hiliteText pText pFieldID
   lock screen
   set the wholematches to true
   repeat with x = 1 to the number of lines of the text of pFieldID
      set the textColor of line x of pFieldID to (the foregroundcolor of me)
      set the textStyle of line x of pFieldID to empty
   end repeat
   local tLine 
   put lineoffset (pText, the text of pFieldID) into tLine
   
   # If the target is teh tags field need to keep selected tag visible
   if pFieldId is the long id of field "tags" of me then
      local tVPos = 0
      put ((tLIne - 1) * 16) - the vScroll of pFieldID into tVPos
      
      if tVPos > the height of pFieldID or tVPos < 0 then
         local tCentredPos
         put tVPos - round(the height of pFieldID / 2) into tCentredPos
         set the vScroll of pFieldID to (the vScroll of pFieldID + tCentredPos)
      end if
   end if
   
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
      if the textStyle of line x of pFieldID is not "bold" then
         set the textColor of line x of pFieldID to (the foregroundcolor of me)
      end if
   end repeat
end clearColors










