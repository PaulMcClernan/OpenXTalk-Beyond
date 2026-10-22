script "revHyperCardLibrary"
-- OXT-Beyond: the end of an imported HyperCard stack's message path.
--
-- revHyperCardFixScripts (revhypercardscriptlibrary.livecodescript) puts
-- this script in the substack "HyperCard Library (<the stack's name>)" of
-- a stack imported with File > Import Stack and makes that substack the
-- stack's behavior, so that it comes after the stack's own script, where
-- HyperCard's Home stack and HyperCard itself were. The scripts it rewrites call these
-- handlers for the parts of HyperCard this engine does not have. A
-- stack's own handler of the same name comes first, as in HyperCard.
--
-- What each does here, rather than in HyperCard, is said beside it.

-- A menu choice: HyperCard sent doMenu for each one, and a stack's
-- "on doMenu" handler is called hcDoMenu after the import (no handler here
-- can be called doMenu). A choice that reaches here does what the
-- engine's doMenu command does with it.
on hcDoMenu pItem, pMenu
   local tMessage
   -- an item of a menu the stack made, with a menu message: the message,
   -- as HyperCard sent it
   put hcMenuMessage(pItem) into tMessage
   if tMessage is not empty then
      send tMessage to this card
      return the result
   end if
   doMenu pItem
   return the result
end hcDoMenu

-- HyperCard's version, which scripts compare with numbers ("the version
-- < 2"): that of HyperCard 2.4.1, the last
function hcVersion
   return "2.4.1"
end hcVersion

-- HyperCard's long version, as HyperCard 2.4.1 gave it
function hcLongVersion
   return "02418000"
end hcLongVersion

-- Whether HyperCard was in the background (MultiFinder): never here
function hcSuspended
   return false
end hcSuspended

-- reset menubar put HyperCard's own menus back; there are none here
on hcResetMenubar
end hcResetMenubar

-- go home: HyperCard's Home stack, if one was imported (in the IDE a
-- stack called "home" is the IDE's own, which is not it); in the web
-- Stack Player, the player's library, which is its home; else a Home
-- stack beside this one, found as hcStackName finds any stack
on hcGoHome
   local tStack
   global gHyperCardHome
   if _HCIsHyperCardStack("Home") then
      go stack "Home"
      return the result
   end if
   if gHyperCardHome is not empty and exists(gHyperCardHome) then
      send "playerGoHome" to gHyperCardHome in 0 milliseconds
      return empty
   end if
   put hcStackName("Home") into tStack
   if tStack is not empty then
      go stack tStack
      return the result
   end if
   return "Can't find the Home stack"
end hcGoHome

----------------------------------------------------------------------
-- go to a stack that is not open
--
-- HyperCard looked for a stack that was not open in the folders it knew
-- of, then asked "Where is ...?"; if the stack could not be found, "go"
-- put "No such card" in the result and the script went on. Here "go" to
-- a stack it cannot find stops the script with an error, and a stack
-- that "go" finds in a HyperCard file is imported without its scripts
-- fixed. So the import rewrites each "go" that names a stack (rule T16)
-- as "do hcGo(...)": the stack is found by hcStackName first, and the
-- statement is run with the stack in the variable tHCStack.

local sHCAsked

-- The statements "do" runs for a "go" to a stack: pStatement, the "go"
-- with the stack expression replaced by tHCStack; pStack, that
-- expression. A stack that cannot be found leaves "No such card" in the
-- result, as in HyperCard, rather than an error
function hcGo pStatement, pStack
   return "put hcStackName(" & pStack & ") into tHCStack" & return & \
         "if tHCStack is empty then" & return & \
         "put (" & pStack & ") into tHCStack" & return & \
         "try" & return & pStatement & return & "catch tHCError" & return & "end try" & return & \
         "else" & return & pStatement & return & "end if"
end hcGo

/*
The stack "go" should go to for pStack, which HyperCard may have named
by its HFS path ("Disk:Stacks:Name"): pStack itself when there is such a
stack; else a HyperCard stack of that name beside the file this stack was
imported from (or in the disk image it came from), imported with its
scripts fixed; else, in the IDE, the file the user gives when asked
"Where is ...?", as HyperCard asked (once a name). Empty if none.
*/
function hcStackName pStack
   local tName, tFile, tStack
   if pStack is empty then return empty
   put _HCLastPart(pStack) into tName
   if tName is "Home" and not _HCIsHyperCardStack("Home") then
      -- (the IDE's stack "home" is not HyperCard's)
      put empty into tStack
   else if there is a stack pStack then
      return pStack
   else if tName is not pStack and there is a stack tName then
      return tName
   end if
   put _HCFindSibling(pStack, tName) into tFile
   if tFile is empty then put _HCWhereIs(tName) into tFile
   if tFile is empty then return empty
   put _HCImport(tFile) into tStack
   if tStack is empty then return empty
   if tName is not "Home" and there is a stack pStack then return pStack
   return tStack
end hcStackName

-- Whether the stack of that name is one imported from HyperCard
private function _HCIsHyperCardStack pName
   if there is not a stack pName then return false
   return "uHyperCard" is among the lines of the customPropertySets of stack pName
end _HCIsHyperCardStack

-- The last part of a path, HFS (colons) or not (slashes)
private function _HCLastPart pPath
   if char -1 of pPath is ":" then delete char -1 of pPath
   set the itemDelimiter to ":"
   put the last item of pPath into pPath
   set the itemDelimiter to slash
   return the last item of pPath
end _HCLastPart

-- A HyperCard stack named pName (or at the HFS path pStack) beside the
-- file this stack was imported from, or on the disk image it came from:
-- the path of a copy that can be imported, or empty
private function _HCFindSibling pStack, pName
   local tSet, tFolder, tFile, tStacks, tLine, tPath, tHFSFolder, tAny
   put the customProperties["uHyperCard"] of me into tSet
   if tSet["file"] is not empty then
      set the itemDelimiter to slash
      put item 1 to -2 of tSet["file"] into tFolder
      repeat for each line tFile in files(tFolder)
         if char 1 to 2 of tFile is "._" or tFile ends with ".rsrc" then next repeat
         set the itemDelimiter to "."
         if tFile is pName or (the number of items of tFile > 1 and item 1 to -2 of tFile is pName) then
            return tFolder & slash & tFile
         end if
      end repeat
   end if
   if tSet["image"] is empty or there is not a file tSet["image"] then return empty
   try
      put revHyperCardImageStacks(tSet["image"]) into tStacks
   catch tError
      -- (the disk image library is the IDE's, and the Stack Player's)
      return empty
   end try
   set the itemDelimiter to ":"
   put item 1 to -2 of tSet["imagepath"] into tHFSFolder
   repeat for each line tLine in tStacks
      set the itemDelimiter to tab
      put item 1 of tLine into tLine
      set the itemDelimiter to ":"
      if tLine is pStack or tLine is (tHFSFolder & ":" & pName) then
         put tLine into tPath
         exit repeat
      end if
      if tAny is empty and the last item of tLine is pName then put tLine into tAny
   end repeat
   if tPath is empty then put tAny into tPath
   if tPath is empty then return empty
   put the temporary folder & "/oxt-hypercard-" & the milliseconds into tFolder
   create folder tFolder
   put revHyperCardImageExtract(tSet["image"], tPath, tFolder) into tFile
   if the result is not empty then return empty
   -- (the copy goes once the stack is imported: _HCImport)
   return tFile & return & tSet["image"] & return & tPath
end _HCFindSibling

-- "Where is ...?", as HyperCard asked, in the IDE only, once a name
private function _HCWhereIs pName
   if the environment is not "development" then return empty
   if sHCAsked[pName] then return empty
   put true into sHCAsked[pName]
   answer file "Where is" && pName & "?"
   if the result is "Cancel" then return empty
   return it
end _HCWhereIs

-- Import the HyperCard stack in the file on line 1 of pFile (lines 2 and
-- 3: the disk image it was copied from, and its HFS path there, the copy
-- then deleted), with messages locked and its scripts fixed: the long id
-- of the stack, or empty
private function _HCImport pFile
   local tStack, tWasLocked, tPath, tFolder, tEach
   put line 1 of pFile into tPath
   put the lockMessages into tWasLocked
   lock messages
   try
      put the long id of stack tPath into tStack
   catch tError
      put empty into tStack
   end try
   if tStack is not empty then
      if line 2 of pFile is empty then
         set the uHyperCard["file"] of tStack to tPath
      else
         set the uHyperCard["image"] of tStack to line 2 of pFile
         set the uHyperCard["imagepath"] of tStack to line 3 of pFile
      end if
      try
         -- (the IDE's, and the Stack Player's)
         get revHyperCardFixScripts(tStack)
      catch tError
      end try
   end if
   set the lockMessages to tWasLocked
   if line 2 of pFile is not empty then
      set the itemDelimiter to slash
      put item 1 to -2 of tPath into tFolder
      repeat for each line tEach in files(tFolder)
         delete file (tFolder & slash & tEach)
      end repeat
      delete folder tFolder
   end if
   return tStack
end _HCImport

-- palette "Name", "h,v": open the palette (the importer makes each PLTE
-- resource a substack of that name) with its top left at h,v
on hcPalette pName, pLocation
   if there is not a stack pName then return "Can't find palette" && pName
   palette stack pName
   if pLocation is not empty then set the topLeft of stack pName to pLocation
   return empty
end hcPalette

-- open report printing: HyperCard's report templates are not imported
on hcOpenReportPrinting pWith
   return "Report printing is not supported"
end hcOpenReportPrinting

-- dial ... with modem: there is no modem to dial
on hcDial pNumber, pModemCommands
   return "dial with modem is not supported"
end hcDial

----------------------------------------------------------------------
-- HyperCard 2.2's menus (rule T22)
--
-- A HyperCard stack made its own menus with "create menu", "put ... into
-- menu ... with menuMsgs", "enable menuItem" and "set the checkMark of
-- menuItem". An imported stack has no menu bar here, and this engine's
-- "menu" names a button of one, so each of those statements stopped the
-- script with an error. They come here instead, and the menus are kept
-- as the scripts make them: what a script puts in a menu, checks,
-- disables or renames reads back as it was (hcMenuItem), and a doMenu of
-- an item with a menu message sends that message. A menu HyperCard had
-- (File, Edit, Go...) is made empty the first time a script names it.
-- The menus are not shown: verified statically and by the importer's
-- tests; the stack has no menu bar to show them in.

-- The menus: sHCMenus["order"], the names one a line; for each menu (by
-- its name in lower case) ["name"], ["enabled"] and, for each item by
-- number, [n]["name"], [n]["enabled"], [n]["checkmark"], [n]["menumessage"]...
local sHCMenus

on hcCreateMenu pMenu
   get _HCMenu(pMenu, true)
   return empty
end hcCreateMenu

on hcDeleteMenu pMenu
   local tKey, tOrder
   put toLower(pMenu) into tKey
   if sHCMenus[tKey] is empty then return "Can't find menu" && pMenu
   delete variable sHCMenus[tKey]
   put sHCMenus["order"] into tOrder
   if pMenu is among the lines of tOrder then delete line lineOffset(pMenu, tOrder) of tOrder
   put tOrder into sHCMenus["order"]
   return empty
end hcDeleteMenu

-- put pItems into (after, before) menu pMenu [with menuMsgs pMessages],
-- put pItems into menuItem pItem of menu pMenu. The items are separated
-- by returns, else by commas; "-" is a line between items
on hcPutIntoMenu pItems, pPreposition, pMenu, pMessages, pItem
   local tKey, tCount, tNew, tLine, i, tAt, tOld, tMessage
   put _HCMenu(pMenu, true) into tKey
   if return is in pItems then
      set the itemDelimiter to return
   end if
   put the number of items of pItems into tCount
   if pItem is not empty then
      put _HCMenuItemNumber(tKey, pItem) into tAt
      if tAt is 0 then return "Can't find menu item" && pItem
      put item 1 of pItems into sHCMenus[tKey][tAt]["name"]
      return empty
   end if
   put sHCMenus[tKey]["count"] into tOld
   if pPreposition is "into" then
      repeat with i = 1 to tOld
         delete variable sHCMenus[tKey][i]
      end repeat
      put 0 into tOld
      put 0 into tAt
   else if pPreposition is "before" then
      -- the items there move down
      repeat with i = tOld down to 1
         put sHCMenus[tKey][i] into sHCMenus[tKey][i + tCount]
      end repeat
      put 0 into tAt
   else
      put tOld into tAt
   end if
   repeat with i = 1 to tCount
      put item i of pItems into tLine
      delete variable sHCMenus[tKey][tAt + i]
      put tLine into sHCMenus[tKey][tAt + i]["name"]
      put true into sHCMenus[tKey][tAt + i]["enabled"]
      put false into sHCMenus[tKey][tAt + i]["checkmark"]
   end repeat
   put tOld + tCount into sHCMenus[tKey]["count"]
   -- the menu messages, one per item, separated as the items are
   set the itemDelimiter to comma
   if return is in pMessages then set the itemDelimiter to return
   repeat with i = 1 to tCount
      put item i of pMessages into tMessage
      put word 1 to -1 of tMessage into sHCMenus[tKey][tAt + i]["menumessage"]
   end repeat
   return empty
end hcPutIntoMenu

-- enable and disable menu pMenu, or menuItem pItem of it
on hcEnableMenu pEnabled, pMenu, pItem
   local tKey, tAt
   put _HCMenu(pMenu, true) into tKey
   if pItem is empty then
      put pEnabled into sHCMenus[tKey]["enabled"]
      return empty
   end if
   put _HCMenuItemNumber(tKey, pItem) into tAt
   if tAt is 0 then return "Can't find menu item" && pItem
   put pEnabled into sHCMenus[tKey][tAt]["enabled"]
   return empty
end hcEnableMenu

-- set the pProperty of menuItem pItem of menu pMenu (of menu pMenu, if
-- pItem is empty) to pValue
on hcSetMenuItem pProperty, pMenu, pItem, pValue
   local tKey, tAt
   put _HCMenu(pMenu, true) into tKey
   put _HCMenuProperty(pProperty) into pProperty
   if pItem is empty then
      put pValue into sHCMenus[tKey][pProperty]
      return empty
   end if
   put _HCMenuItemNumber(tKey, pItem) into tAt
   if tAt is 0 then return "Can't find menu item" && pItem
   put pValue into sHCMenus[tKey][tAt][pProperty]
   return empty
end hcSetMenuItem

-- the pProperty of menuItem pItem of menu pMenu, as a script set it, or
-- HyperCard's default (enabled, no checkmark, plain)
function hcMenuItem pProperty, pMenu, pItem
   local tKey, tAt, tValue
   put _HCMenu(pMenu, true) into tKey
   put _HCMenuProperty(pProperty) into pProperty
   put _HCMenuItemNumber(tKey, pItem) into tAt
   if tAt is not 0 then put sHCMenus[tKey][tAt][pProperty] into tValue
   if tValue is empty then
      switch pProperty
         case "enabled"
            return true
         case "checkmark"
            return false
         case "textstyle"
            return "plain"
         case "name"
            if pItem is not an integer then return pItem
      end switch
   end if
   return tValue
end hcMenuItem

on hcDeleteMenuItem pMenu, pItem
   local tKey, tAt, i, tCount
   put _HCMenu(pMenu, true) into tKey
   put _HCMenuItemNumber(tKey, pItem) into tAt
   if tAt is 0 then return "Can't find menu item" && pItem
   put sHCMenus[tKey]["count"] into tCount
   repeat with i = tAt to tCount - 1
      put sHCMenus[tKey][i + 1] into sHCMenus[tKey][i]
   end repeat
   delete variable sHCMenus[tKey][tCount]
   put tCount - 1 into sHCMenus[tKey]["count"]
   return empty
end hcDeleteMenuItem

-- The menu message of a menu item the stack made, by its name, or empty
-- (hcDoMenu sends it, as HyperCard did)
function hcMenuMessage pItem
   local tMenu, tKey, i
   repeat for each line tMenu in sHCMenus["order"]
      put toLower(tMenu) into tKey
      repeat with i = 1 to sHCMenus[tKey]["count"]
         if sHCMenus[tKey][i]["name"] is pItem then return sHCMenus[tKey][i]["menumessage"]
      end repeat
   end repeat
   return empty
end hcMenuMessage

-- The key of pMenu in sHCMenus, the menu made if pCreate and it is not
-- there yet
private function _HCMenu pMenu, pCreate
   local tKey
   put toLower(pMenu) into tKey
   if sHCMenus[tKey]["name"] is empty and pCreate then
      put pMenu into sHCMenus[tKey]["name"]
      put true into sHCMenus[tKey]["enabled"]
      put 0 into sHCMenus[tKey]["count"]
      if sHCMenus["order"] is empty then
         put pMenu into sHCMenus["order"]
      else
         put return & pMenu after sHCMenus["order"]
      end if
   end if
   return tKey
end _HCMenu

-- The number of an item of a menu, by its number or its name (with or
-- without its "..."), 0 if there is none
private function _HCMenuItemNumber pKey, pItem
   local i, tName
   if pItem is an integer then
      if pItem >= 1 and pItem <= sHCMenus[pKey]["count"] then return pItem
      return 0
   end if
   repeat with i = 1 to sHCMenus[pKey]["count"]
      put sHCMenus[pKey][i]["name"] into tName
      if tName is pItem or (tName ends with "..." and char 1 to -4 of tName is pItem) then return i
   end repeat
   return 0
end _HCMenuItemNumber

private function _HCMenuProperty pProperty
   switch pProperty
      case "cmdchar"
         return "commandchar"
      case "menumsg"
         return "menumessage"
   end switch
   return toLower(pProperty)
end _HCMenuProperty

-- set the cursor to ... (rule T17): this engine's number for HyperCard's
-- cursor numbers (1 iBeam, 2 cross, 3 plus, 4 watch) and names, and the
-- image id of one of the stack's own cursors (its CURS resources, which
-- the import makes images of the group "HC cursors") by name. A cursor
-- that is none of these gives empty: the default cursor, where this
-- engine stopped with an error
function hcCursor pCursor
   local tGroup, i
   if pCursor is an integer then
      if pCursor >= 1 and pCursor <= 4 then return item pCursor of "9,7,13,14"
      return pCursor
   end if
   put word 1 to -1 of pCursor into pCursor
   if pCursor is among the items of "none,busy,cross,ibeam,plus,watch,help,hand,arrow" then
      return item itemOffset(pCursor, "none,busy,cross,ibeam,plus,watch,help,hand,arrow") of "0,6,7,9,13,14,15,28,29"
   end if
   put "HC cursors" into tGroup
   if there is a background tGroup of me then
      repeat with i = 1 to the number of images of background tGroup of me
         if the short name of image i of background tGroup of me is pCursor then
            return the id of image i of background tGroup of me
         end if
      end repeat
   end if
   return empty
end hcCursor

-- tabKey, arrowKey, returnKey, enterKey, returnInField, enterInField and
-- functionKey as commands (rule T18): HyperCard sent the message to the
-- current card, and did what the key did if no handler took it. Here
-- the message goes to this card the same way, and what the key did is
-- below; a handler of the message that sends it again gets the key's
-- action, not its own message (HyperCard would have looped)
local sHCInKey

on hcTabKey
   if _HCKeyHandled("tabKey") then exit hcTabKey
   _HCNextField
end hcTabKey

on hcArrowKey pDirection
   if _HCKeyHandled("arrowKey", pDirection) then exit hcArrowKey
   switch pDirection
      case "left"
         go prev card
         break
      case "right"
         go next card
         break
      case "up"
         go forth
         break
      case "down"
         go back
         break
   end switch
end hcArrowKey

on hcReturnKey
   get _HCKeyHandled("returnKey")
end hcReturnKey

on hcEnterKey
   get _HCKeyHandled("enterKey")
end hcEnterKey

on hcReturnInField
   if _HCKeyHandled("returnInField") then exit hcReturnInField
   if the selectedField is not empty then put return into the selection
end hcReturnInField

on hcEnterInField
   if _HCKeyHandled("enterInField") then exit hcEnterInField
   select empty
end hcEnterInField

on hcFunctionKey pKey
   if _HCKeyHandled("functionKey", pKey) then exit hcFunctionKey
   -- F1 to F4: undo, cut, copy, paste
   try
      switch pKey
         case 1
            undo
            break
         case 2
            cut
            break
         case 3
            copy
            break
         case 4
            paste
            break
      end switch
   catch tError
   end try
end hcFunctionKey

private function _HCKeyHandled pMessage, pParameter
   local tHandled
   if sHCInKey[pMessage] then return false
   put true into sHCInKey[pMessage]
   try
      if pParameter is empty then
         dispatch pMessage to this card
      else
         dispatch pMessage to this card with pParameter
      end if
      put it into tHandled
   catch tError
      put false into sHCInKey[pMessage]
      throw tError
   end try
   put false into sHCInKey[pMessage]
   return tHandled is "handled"
end _HCKeyHandled

-- The next field of this card that can be typed in, after the one being
-- typed in, its text selected
private command _HCNextField
   local tCount, tStart, i, tField
   put the number of fields of this card into tCount
   if tCount = 0 then exit _HCNextField
   put 0 into tStart
   if word 1 of the selectedField is "field" then put the number of the selectedField into tStart
   repeat with i = 1 to tCount
      put ((tStart + i - 1) mod tCount) + 1 into tField
      if the visible of field tField of this card and not the lockText of field tField of this card then
         select text of field tField of this card
         exit _HCNextField
      end if
   end repeat
end _HCNextField

-- flash n: the screen inverted and back n times (3 if n is left out), as
-- HyperCard did it. Here the card window is inverted, by a graphic made
-- for the purpose and deleted after
on flash pTimes
   local tGraphic, tWasLocked
   if pTimes is not an integer then put 3 into pTimes
   put the lockMessages into tWasLocked
   lock messages
   try
      create graphic "HC Flash"
      put the long id of it into tGraphic
      set the style of tGraphic to "rectangle"
      set the opaque of tGraphic to true
      set the lineSize of tGraphic to 0
      set the backgroundColor of tGraphic to "white"
      set the ink of tGraphic to "blendDifference"
      set the rect of tGraphic to 0, 0, the width of this card, the height of this card
      set the visible of tGraphic to false
      repeat pTimes times
         set the visible of tGraphic to true
         wait 3 ticks
         set the visible of tGraphic to false
         wait 3 ticks
      end repeat
   catch tError
   end try
   if tGraphic is not empty and exists(tGraphic) then delete tGraphic
   set the lockMessages to tWasLocked
end flash

-- show and hide card picture, background picture (rule T19): the paint
-- of the card or of its background, which the import makes an image
-- with no name, the first on the card or in the background
on hcShowPicture pWhich, pShow, pObject
   local tOwner, i, tImage
   if pObject is empty then put the long id of this card into pObject
   put pObject into tOwner
   if pWhich is "background" and word 1 of the long name of pObject is "card" then
      put empty into tOwner
      repeat with i = 1 to the number of backgrounds of pObject
         put the long id of background i of pObject into tOwner
         exit repeat
      end repeat
      if tOwner is empty then return "No background picture"
   end if
   repeat with i = 1 to the number of images of tOwner
      put the long id of image i of tOwner into tImage
      -- (an image with no name is called by its id)
      if the long id of the owner of tImage is the long id of tOwner and the short name of tImage ends with "image id" && the id of tImage then
         set the visible of tImage to (pShow is true)
         return empty
      end if
   end repeat
   return empty
end hcShowPicture

-- show, hide and close window (rule T21): a window that is a stack here
-- (a palette the import made, a picture the picture command opened, or
-- any stack), the message box, and HyperCard's own windows, which are
-- not here (the tool, pattern, scroll, FatBits and navigator windows):
-- left alone, as an error here would stop the script
on hcWindow pVerb, pName, pLocation
   local i
   -- (a location written h,v comes as two parameters)
   repeat with i = 4 to paramCount()
      put comma & param(i) after pLocation
   end repeat
   if pName is among the items of "message,msg,message box,message window" then
      if pVerb is "show" then
         show message box
      else
         hide message box
      end if
      return empty
   end if
   if pName is among the words of "tool tools pattern patterns scroll fatbits navigator" then return empty
   if there is not a stack pName then return "Can't find window" && pName
   switch pVerb
      case "show"
         if pLocation is not empty then set the loc of stack pName to pLocation
         if the mode of stack pName is 0 then
            if the uHyperCard["picture"] of stack pName is true then
               topLevel stack pName
            else
               palette stack pName
            end if
         else
            show stack pName
         end if
         break
      case "hide"
         hide stack pName
         break
      case "close"
         if the uHyperCard["picture"] of stack pName is true then
            delete stack pName
         else
            close stack pName
         end if
         break
   end switch
   return empty
end hcWindow

-- picture name, type, style, visible, depth, floating (hcPicture after
-- the import, rule T18: a handler called "picture" here stops every
-- function of its script being found): HyperCard's picture command, a
-- window that shows a picture. The picture is the
-- stack's PICT resource of that name (type "resource": the import made
-- each one an image of the group "HC Pictures") or a file of that name
-- beside the file the stack was imported from (type "file", in a format
-- this engine reads); the window is a stack of that name, which show,
-- hide and close window act on. The style and depth are not kept
on hcPicture pName, pType, pStyle, pVisible, pDepth, pFloating
   local tDefault, tTitle, tSource, tFile, tStack, tSet, i
   if pType is empty then put "file" into pType
   put pName into tTitle
   if char -1 of tTitle is ":" then delete char -1 of tTitle
   set the itemDelimiter to ":"
   put the last item of tTitle into tTitle
   set the itemDelimiter to comma
   if pType is not among the items of "resource,file" then
      return "Can't show a picture from" && pType
   end if
   if pType is "resource" and there is a background "HC Pictures" of me then
      repeat with i = 1 to the number of images of background "HC Pictures" of me
         if the short name of image i of background "HC Pictures" of me is tTitle then
            put the long id of image i of background "HC Pictures" of me into tSource
            exit repeat
         end if
      end repeat
   end if
   if pType is "file" then
      put the customProperties["uHyperCard"] of me into tSet
      set the itemDelimiter to slash
      if tSet["file"] is not empty then put item 1 to -2 of tSet["file"] & slash & tTitle into tFile
      if tFile is not empty and there is not a file tFile then put empty into tFile
   end if
   if tSource is empty and tFile is empty then
      return "Can't find picture" && pName
   end if
   put the defaultStack into tDefault
   if there is a stack tTitle and the uHyperCard["picture"] of stack tTitle is true then
      delete stack tTitle
   end if
   create invisible stack tTitle
   put the long id of it into tStack
   set the uHyperCard["picture"] of tStack to true
   set the destroyStack of tStack to true
   set the title of tStack to tTitle
   set the defaultStack to the short name of tStack
   create image "Picture"
   if tFile is not empty then
      set the filename of image "Picture" to tFile
   else
      set the text of image "Picture" to the text of tSource
   end if
   set the topLeft of image "Picture" to 0,0
   set the width of tStack to max(the formattedWidth of image "Picture", 32)
   set the height of tStack to max(the formattedHeight of image "Picture", 32)
   set the defaultStack to tDefault
   if pVisible is not false then
      if pFloating is true then
         palette stack tTitle
      else
         topLevel stack tTitle
      end if
      set the defaultStack to tDefault
   end if
   return empty
end hcPicture

----------------------------------------------------------------------
-- Stand-ins for the externals stacks call most
--
-- An XCMD or XFCN is 68k code, which this engine cannot run; a call to
-- one that the stack carried comes here instead. These are the externals
-- the most stacks of a 2,186-stack corpus call from script, each written
-- from the way those stacks call it and from the externals' own
-- documentation, so the less common forms of a call may differ. The
-- dialogs and menus are this engine's; an external with no counterpart
-- here (a dialog builder, a resource copier) does nothing and says so in
-- the result, which is where an XCMD put its error.

local sHCMenuCount
local sHCBalloons
local sHCPopUp

-- FileName([type, ...] [, prompt]): the path of a file the user picks
-- (Standard File's open dialog), or empty if they cancel. File types
-- are four characters; anything longer is taken as the prompt
function FileName
   local tPrompt, i
   put "Choose a file:" into tPrompt
   repeat with i = 1 to paramCount()
      if (the number of chars of param(i)) > 4 then put param(i) into tPrompt
   end repeat
   answer file tPrompt
   if the result is "Cancel" then return empty
   return it
end FileName

-- fileName(...) after the import (rule T20; this engine reads
-- "fileName(" as the property): FileName, above
function hcX_FileName
   local tParams, i
   repeat with i = 1 to paramCount()
      put "param(" & i & ")," after tParams
   end repeat
   delete the last char of tParams
   return value("FileName(" & tParams & ")")
end hcX_FileName

-- splashDialog id, seconds, ...: a splash screen while the stack starts,
-- from a resource that is not imported; nothing is shown
on splashDialog
   return empty
end splashDialog

-- NewFileName(prompt, default name): the path the user gives a new file
-- (Standard File's save dialog), or empty if they cancel
function NewFileName pPrompt, pDefault
   if pPrompt is empty then put "Save as:" into pPrompt
   ask file pPrompt with pDefault
   if the result is "Cancel" then return empty
   return it
end NewFileName

-- PutFile(prompt, default name): the same save dialog
function PutFile pPrompt, pDefault
   return NewFileName(pPrompt, pDefault)
end PutFile

-- PopUpMenu(items, checked item, top, left): a popup menu of the items
-- (separated by semicolons, else by returns, else by commas) with its top
-- left at left,top; the number of the item chosen, 0 if none
function PopUpMenu pItems, pChecked, pTop, pLeft
   local tItems, tChosen
   put hcPopUpItems(pItems) into tItems
   put _HCPopUp(_HCMenuText(tItems, pChecked), pTop, pLeft) into tChosen
   if tChosen is empty then return 0
   return _HCLineOf(tChosen, tItems)
end PopUpMenu

-- HPopUpMenu(menus, checked item, top, left): a popup menu with one
-- line per entry, and on a line with commas the first item the entry and
-- the rest its submenu; "line,item" of the choice (item 0 for an entry
-- with no submenu), 0 if none
function HPopUpMenu pMenus, pChecked, pTop, pLeft
   local tText, tLine, tChosen, i
   repeat for each line tLine in pMenus
      put item 1 of tLine & return after tText
      repeat with i = 2 to the number of items of tLine
         put tab & item i of tLine & return after tText
      end repeat
   end repeat
   delete the last char of tText
   put _HCPopUp(tText, pTop, pLeft) into tChosen
   if tChosen is empty then return 0
   return hcHPopUpChoice(pMenus, tChosen)
end HPopUpMenu

-- "line,item" of an HPopUpMenu choice, as the popup gives it ("entry" or
-- "entry|subitem"), 0 if it is not one of pMenus
function hcHPopUpChoice pMenus, pChosen
   local tItem, tLineNumber, tItemNumber, i
   set the itemDelimiter to "|"
   put item 1 of pChosen into tItem
   put item 2 of pChosen into pChosen
   set the itemDelimiter to comma
   repeat with i = 1 to the number of lines of pMenus
      if item 1 of line i of pMenus is tItem then
         put i into tLineNumber
         exit repeat
      end if
   end repeat
   if tLineNumber is empty then return 0
   put 0 into tItemNumber
   if pChosen is not empty then
      repeat with i = 2 to the number of items of line tLineNumber of pMenus
         if item i of line tLineNumber of pMenus is pChosen then
            put i - 1 into tItemNumber
            exit repeat
         end if
      end repeat
   end if
   return tLineNumber & comma & tItemNumber
end hcHPopUpChoice

-- The items of a PopUpMenu list, one per line
function hcPopUpItems pItems
   if ";" is in pItems then
      replace ";" with return in pItems
   else if return is not in pItems then
      replace comma with return in pItems
   end if
   return pItems
end hcPopUpItems

-- XScrollBox(mode, prompt, list): the user picks a line of the list;
-- "line number,line" of it, empty if they cancel
function XScrollBox pMode, pPrompt, pList
   local tLine
   put hcChooseLine(pPrompt, pList) into tLine
   if tLine is empty then return empty
   return tLine & comma & line tLine of pList
end XScrollBox

-- ShowList(list, prompt, ...): the user picks a line of the list; the
-- button ("OK" or "Cancel") on line 1 and the line picked on line 2.
-- When the second argument is a delimiter, the prompt is the third
function ShowList pList, pPrompt
   local tLine
   if pPrompt is among the items of (return & comma & ";,") or pPrompt is tab then put param(3) into pPrompt
   put hcChooseLine(pPrompt, pList) into tLine
   if tLine is empty then return "Cancel"
   return "OK" & return & line tLine of pList
end ShowList

-- DoList button, button, list, one: the user picks a line of the list;
-- the result is "button,line" ("Cancel," if they cancel). DoList 999,
-- list, ... takes the list second
on DoList pButton, pCancel, pList
   local tLine
   if pButton is a number then
      put pCancel into pList
      put "OK" into pButton
      put "Cancel" into pCancel
   end if
   put hcChooseLine(empty, pList) into tLine
   if tLine is empty then return pCancel & comma
   return pButton & comma & line tLine of pList
end DoList

-- PrintField "field description": prints the field's text
on PrintField pField
   local tField
   try
      put the long id of pField into tField
   catch tError
      try
         put value("the long id of" && pField) into tField
      catch tError
         return "Can't find" && pField
      end try
   end try
   try
      revPrintField tField
   catch tError
      return "Printing is not available"
   end try
   return empty
end PrintField

-- Speak text / Talk text, rate, pitch: speech, where this engine has it
on Speak pText
   return _HCSpeak(pText)
end Speak

on Talk pText
   return _HCSpeak(pText)
end Talk

-- HCBalloon text: a balloon for the object the message came to, here its
-- tooltip. HCBalloon "on", "off" and "query" turn balloons on and off and
-- give back whether they are on
on HCBalloon pText
   if sHCBalloons is empty then put true into sHCBalloons
   switch pText
      case "on"
         put true into sHCBalloons
         return empty
      case "off"
         put false into sHCBalloons
         return empty
      case "query"
         return sHCBalloons
   end switch
   if sHCBalloons then set the toolTip of the target to pText
   return empty
end HCBalloon

-- ColorizeHC: colour drawn over the card, which this engine does with
-- its own colours (the importer keeps AddColor's as a colour layer)
on ColorizeHC
   return empty
end ColorizeHC

-- MaxDepth(): the deepest colour of the screens
function MaxDepth
   return the screenDepth
end MaxDepth

-- Promptoid message: a small window with the message, which scripts
-- close as the window "Promptoid"
on Promptoid pMessage
   local tDefault
   put the defaultStack into tDefault
   if there is a stack "Promptoid" and the uHyperCard["promptoid"] of stack "Promptoid" is not true then
      -- the stack's own window of that name: left alone
      return "There is already a window called Promptoid"
   end if
   if there is not a stack "Promptoid" then
      create invisible stack "Promptoid"
      set the uHyperCard["promptoid"] of it to true
      set the destroyStack of it to true
      set the width of it to 320
      set the height of it to 60
      set the defaultStack to "Promptoid"
      create field "Message"
      set the rect of it to 10,10,310,50
      set the lockText of it to true
      set the defaultStack to tDefault
   end if
   put pMessage into field "Message" of stack "Promptoid"
   palette stack "Promptoid"
   set the defaultStack to tDefault
   return empty
end Promptoid

-- NewMenu(title, items...), DeleteMenu(menu), ShowMenu menu: menus added
-- to HyperCard's menu bar, which this engine's menus do not take yet.
-- NewMenu gives back a number for DeleteMenu, as the external did
function NewMenu
   add 1 to sHCMenuCount
   return sHCMenuCount
end NewMenu

function DeleteMenu pMenu
   return empty
end DeleteMenu

on DeleteMenu pMenu
   return "HyperCard menus are not supported yet"
end DeleteMenu

on ShowMenu pMenu
   return "HyperCard menus are not supported yet"
end ShowMenu

function ShowMenu pMenu
   return empty
end ShowMenu

-- Externals with nothing like them here: they do nothing, and say so
on Dialoger
   return "The Dialoger external is not supported"
end Dialoger

function Dialoger
   return empty
end Dialoger

on ShowDialog
   return "The ShowDialog external is not supported"
end ShowDialog

on ResCopy
   return "ResCopy is not supported: resources are not copied"
end ResCopy

function Search
   return empty
end Search

-- popUp (called hcX_popUp after the import, since popup is a command
-- here): the Home stack's popup cards, which are not imported
on hcX_popUp
   return "popUp is not supported"
end hcX_popUp

-- The line of pList the user picks in a list dialog, or empty if they
-- cancel
function hcChooseLine pPrompt, pList
   local tDefault, tLine, tName, tStack
   if pList is empty then return empty
   put the defaultStack into tDefault
   -- (a name of its own, so that no stack of the user's is touched; kept
   -- until its choice is read)
   put "HyperCard List " & the milliseconds into tName
   create invisible stack tName
   put the long id of it into tStack
   set the title of tStack to "Choose"
   set the width of tStack to 360
   set the height of tStack to 300
   set the defaultStack to tName
   create field "Prompt"
   set the rect of it to 10,10,350,34
   set the lockText of it to true
   put pPrompt into field "Prompt"
   create field "List"
   set the rect of it to 10,40,350,250
   set the listBehavior of it to true
   set the lockText of it to true
   set the vScrollbar of it to true
   put pList into field "List"
   set the hilitedLine of field "List" to 1
   create button "OK"
   set the rect of it to 270,262,350,288
   set the default of it to true
   set the script of it to "on mouseUp" & return & "set the uChosen of the owner of the owner of me to the hilitedLine of field " & quote & "List" & quote & " of the owner of me" & return & "close stack (the short name of the owner of the owner of me)" & return & "end mouseUp"
   create button "Cancel"
   set the rect of it to 180,262,260,288
   set the script of it to "on mouseUp" & return & "close stack (the short name of the owner of the owner of me)" & return & "end mouseUp"
   set the defaultStack to tDefault
   modal stack tName
   if exists(tStack) then
      put the uChosen of tStack into tLine
      delete stack tName
   end if
   return tLine
end hcChooseLine

private function _HCMenuText pItems, pChecked
   if pChecked is an integer and abs(pChecked) > 0 and abs(pChecked) <= the number of lines of pItems then
      put "!c" before line abs(pChecked) of pItems
   end if
   return pItems
end _HCMenuText

private function _HCLineOf pChosen, pItems
   local tLine, i
   put 0 into i
   repeat for each line tLine in pItems
      add 1 to i
      if tLine is pChosen or (char 1 to 2 of tLine is "!c" and char 3 to -1 of tLine is pChosen) then return i
   end repeat
   return 0
end _HCLineOf

-- Shows pText as a popup menu with its top left at pLeft,pTop (the mouse
-- if they are left out); the item chosen, or empty
private function _HCPopUp pText, pTop, pLeft
   local tDefault, tChosen
   put the defaultStack into tDefault
   if sHCPopUp is empty or not exists(sHCPopUp) then
      -- (a name of its own, so that no stack of the user's is touched)
      create invisible stack ("HyperCard Popup " & the milliseconds)
      put the long id of it into sHCPopUp
      set the defaultStack to the short name of sHCPopUp
      create button "Menu"
      set the style of it to "menu"
      set the menuMode of it to "popup"
      set the menuMouseButton of it to 0
      set the script of it to "on menuPick pItem" & return & "set the uChosen of me to pItem" & return & "end menuPick"
      set the defaultStack to tDefault
   end if
   set the text of button "Menu" of sHCPopUp to pText
   set the uChosen of button "Menu" of sHCPopUp to empty
   if pTop is an integer and pLeft is an integer then
      popup button "Menu" of sHCPopUp at pLeft, pTop
   else
      popup button "Menu" of sHCPopUp
   end if
   put the uChosen of button "Menu" of sHCPopUp into tChosen
   return tChosen
end _HCPopUp

private function _HCSpeak pText
   try
      revSpeak pText
   catch tError
      return "Speech is not available"
   end try
   return the result
end _HCSpeak
