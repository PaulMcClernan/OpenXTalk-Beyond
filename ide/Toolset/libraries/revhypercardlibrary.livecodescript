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

-- A menu choice: HyperCard sent doMenu for each one, to the stack's
-- handlers first. In a stack imported without HyperCard's message order
-- (its hyperTalkCompatible false) no handler can be called doMenu: a
-- stack's "on doMenu" handler is called hcDoMenu after the import, and
-- each doMenu of its scripts is an hcDoMenu (rule T15), so that this one
-- comes after the stack's own. pMenu is the menu's name, when the script
-- gave it ("doMenu "Paste Button", "Edit""), and pWithout "without dialog".
on hcDoMenu pItem, pMenu, pWithout
   hcMenuChoice pItem, pMenu, pWithout
   return the result
end hcDoMenu

-- HyperCard's menu items, by the names HyperCard gave them, with or
-- without their "...", in any case: what a doMenu that no handler of the
-- stack takes does. hcDoMenu calls this; in a stack with HyperCard's
-- message order, where doMenu is a message and keeps its name, the "on
-- doMenu" of the substack "HyperCard Menus (<the stack's name>)", this
-- library's behavior, does. Each item does what it did in HyperCard as
-- nearly as this engine can:
--
-- File: New Stack..., Open Stack... (a HyperCard stack is imported as
-- "go" imports one), Close Stack, Save a Copy..., Delete Stack... (asked
-- first, "without dialog" too, whenever it would delete a file), Page
-- Setup..., Print Card, Print Stack..., Print Field... (the selected
-- field), Quit HyperCard (in the IDE the stack is closed rather than the
-- IDE quit: a stack that quit as it opened closed the IDE, with no word
-- about unsaved work; a standalone quits); Compact Stack and Convert
-- Stack... have nothing to do here.
-- Edit: Undo; Cut, Copy, Paste and Clear, alone or of Text, Button,
-- Field, Picture or Card, for what is selected; New Card, Delete Card,
-- Background (editing the background, or the card again).
-- Go: Back, Home, Help, Recent, First, Prev, Next, Last, Find... (asks
-- what to find), Message (shows the message box, or hides it).
-- Objects: New Button (named "New Button", as HyperCard named it), New
-- Field, New Background (a card with a background of its own), Bring
-- Closer, Send Farther, and Button Info... to Stack Info..., which show
-- the object in the IDE's inspector.
-- Style and Font: Plain, Bold, Italic, Underline, Condense, Extend,
-- Group, a font's name and a size, for the selected text, else the
-- selected buttons and fields; a style the text has already is taken off.
-- Paint: Select All with a paint tool takes the picture of the card (of
-- the background, while it is edited), which Cut, Copy and Clear Picture,
-- Flip Horizontal and Flip Vertical then act on.
--
-- An item of a menu the stack made sends its menu message, as HyperCard
-- did. Any other item leaves "doMenu "<item>" not implemented" in the
-- result, as this engine's doMenu does; an item that stops with an error
-- leaves the error in the result, and the script goes on, as it did
-- after this engine's doMenu.
on hcMenuChoice pItem, pMenu, pWithout
   local tMessage, tKey, tError, tStack, tObjects
   put hcMenuMessage(pItem) into tMessage
   if tMessage is not empty then
      _HCSendMenuMessage tMessage
      return the result
   end if
   put _HCMenuKey(pItem) into tKey
   try
      switch tKey
         -- File
         case "new stack"
            return _HCNewStack(pWithout)
         case "open stack"
         case "open stack in new window"
            answer file "Open which stack?"
            if it is empty then return "Cancel"
            put _HCOpenStack(it) into tStack
            if tStack is empty then return "No such stack"
            if tKey is "open stack" then
               go tStack
            else
               go tStack in a new window
            end if
            return the result
         case "close stack"
            close this stack
            return empty
         case "save a copy"
            return _HCSaveACopy()
         case "compact stack"
         case "convert stack"
            -- (the stack is in this engine's format already, and compact
            -- has nothing to do here)
            return empty
         case "delete stack"
            return _HCDeleteStack(pWithout)
         case "page setup"
            answer page setup
            return empty
         case "print card"
            print this card
            return empty
         case "print stack"
            print this stack
            return empty
         case "print field"
            put _HCSelected("field") into tObjects
            if tObjects is empty then return "No field is selected"
            PrintField line 1 of tObjects
            return the result
         case "quit hypercard"
         case "quit"
            if the environment is "development" then
               close this stack
            else
               quit
            end if
            return empty
         -- Edit
         case "undo"
            undo
            return empty
         case "cut"
         case "copy"
         case "clear"
            return _HCEdit(tKey, empty)
         case "cut text"
         case "copy text"
         case "clear text"
         case "cut button"
         case "copy button"
         case "clear button"
         case "cut field"
         case "copy field"
         case "clear field"
         case "cut picture"
         case "copy picture"
         case "clear picture"
            return _HCEdit(word 1 of tKey, word 2 of tKey)
         case "paste"
         case "paste text"
         case "paste button"
         case "paste field"
         case "paste card"
         case "paste picture"
            paste
            return the result
         case "new card"
            create card
            return empty
         case "delete card"
            delete this card
            return empty
         case "cut card"
            cut this card
            return the result
         case "copy card"
            copy this card
            return the result
         case "background"
            set the editBackground to not the editBackground
            return empty
         -- Go
         case "back"
            go back
            return the result
         case "home"
            hcGoHome
            return the result
         case "help"
            help
            return empty
         case "recent"
            go recent card
            return the result
         case "first"
         case "prev"
         case "previous"
         case "next"
         case "last"
            do "go to" && tKey && "card"
            return the result
         case "find"
            ask "Find:"
            if it is empty then return empty
            find it
            return the result
         case "message"
            if there is not a stack "Message Box" then return empty
            if the visible of stack "Message Box" then
               hide message box
            else
               show message box
            end if
            return empty
         -- Objects
         case "button info"
         case "field info"
         case "card info"
         case "bkgnd info"
         case "background info"
         case "stack info"
            return _HCInfo(word 1 of tKey, pItem)
         case "bring closer"
            return _HCLayer(1)
         case "send farther"
            return _HCLayer(-1)
         case "new button"
            -- (this engine's doMenu makes one with no name)
            create button "New Button"
            return empty
         case "new field"
            create field
            return empty
         case "new background"
            return _HCNewBackground()
         -- Style
         case "plain"
         case "bold"
         case "italic"
         case "underline"
         case "outline"
         case "shadow"
         case "condense"
         case "extend"
         case "group"
            return _HCStyle(tKey)
         -- Paint
         case "select all"
            return _HCSelectAll()
         case "flip horizontal"
         case "flip vertical"
            return _HCFlip(word 2 of tKey)
         case "keep"
            -- (what is painted here is kept as it is painted)
            return empty
      end switch
      -- the Style menu's sizes, and the Font menu's fonts
      if tKey is an integer and tKey >= 1 and tKey <= 127 then
         return _HCTextProperty("textSize", tKey)
      end if
      if _HCFont(pItem) is not empty then
         return _HCTextProperty("textFont", _HCFont(pItem))
      end if
   catch tError
      return "doMenu" && quote & pItem & quote && "failed:" && line 1 of tError
   end try
   return "doMenu" && quote & pItem & quote && "not implemented"
end hcMenuChoice

-- The name of a menu item as hcMenuChoice knows it: in lower case, its
-- words one space apart, without the "..." (or the "…") after it
private function _HCMenuKey pItem
   local tKey
   put toLower(pItem) into tKey
   replace numToCodepoint(160) with space in tKey
   replace numToCodepoint(8230) with "..." in tKey
   replace tab with space in tKey
   repeat while "  " is in tKey
      replace "  " with space in tKey
   end repeat
   put word 1 to -1 of tKey into tKey
   repeat while char -1 of tKey is "."
      delete char -1 of tKey
   end repeat
   return word 1 to -1 of tKey
end _HCMenuKey

-- The selected objects, one long id a line; with pType ("button",
-- "field") those of that type only
private function _HCSelected pType
   local tObject, tList
   repeat for each line tObject in the selectedObjects
      if pType is empty or word 1 of tObject is pType then put tObject & return after tList
   end repeat
   delete the last char of tList
   return tList
end _HCSelected

-- Whether the selectedChunk is text, not an insertion point ("char 6 to
-- 5 of field 1")
private function _HCHasText pChunk
   return word 1 of pChunk is "char" and word 2 of pChunk is an integer \
         and word 4 of pChunk is an integer and word 2 of pChunk <= word 4 of pChunk
end _HCHasText

-- Cut, Copy and Clear (pVerb) of the picture "Select All" took, of the
-- selected text, or of the selected buttons and fields (pWhat: "text",
-- "button", "field", "picture", or empty for what is selected)
private function _HCEdit pVerb, pWhat
   local tChunk, tObjects, tObject, tPicture
   put _HCSelectedPicture() into tPicture
   if pWhat is "picture" or (pWhat is empty and tPicture is not empty) then
      if tPicture is empty then
         -- (a selection made with this engine's paint tools)
         if pVerb is "copy" then copy
         if pVerb is "cut" then cut
         return empty
      end if
      if pVerb is among the words of "copy cut" then copy tPicture
      if pVerb is among the words of "cut clear" then set the text of tPicture to empty
      return empty
   end if
   put the selectedChunk into tChunk
   if pWhat is "text" or (pWhat is empty and _HCHasText(tChunk)) then
      if pVerb is "copy" then copy
      if pVerb is "cut" then cut
      if pVerb is "clear" and _HCHasText(tChunk) then do "delete" && tChunk
      return empty
   end if
   put _HCSelected(pWhat) into tObjects
   if tObjects is empty then
      -- (nothing of that kind selected: what this engine's own command
      -- does with the selection)
      if pVerb is "copy" then copy
      if pVerb is "cut" then cut
      return empty
   end if
   if pVerb is "clear" then
      repeat for each line tObject in tObjects
         delete tObject
      end repeat
      return empty
   end if
   if the number of lines of tObjects > 1 then
      -- (all of the selection, as the Edit menu takes it)
      if pVerb is "copy" then
         copy
      else
         cut
      end if
   else if pVerb is "copy" then
      copy tObjects
   else
      cut tObjects
   end if
   return the result
end _HCEdit

-- The picture Select All took: its card's long id, then its image's
local sHCPicture

-- Whether a paint tool is chosen
private function _HCPaintTool
   return word 1 of the tool is among the words of \
         "select lasso pencil brush eraser spray line rectangle rect roundrect round oval curve polygon regular text bucket dropper"
end _HCPaintTool

-- The picture of this card (of its background, while it is edited): the
-- image the import made of it, which has no name. Empty if it has none
private function _HCPictureOfCard
   local tCard, tOwner, i, tImage
   put the long id of this card into tCard
   put tCard into tOwner
   if the editBackground and the number of backgrounds of tCard > 0 then
      put the long id of background 1 of tCard into tOwner
   end if
   repeat with i = 1 to the number of images of tOwner
      put the long id of image i of tOwner into tImage
      if the long id of the owner of tImage is tOwner and the short name of tImage ends with "image id" && the id of tImage then
         return tImage
      end if
   end repeat
   return empty
end _HCPictureOfCard

-- Select All: with a paint tool, the picture of the card; with the
-- browse tool, the text of the field being edited
private function _HCSelectAll
   if _HCPaintTool() then
      put the long id of this card & return & _HCPictureOfCard() into sHCPicture
      return empty
   end if
   if the selectedField is not empty then do "select text of" && the selectedField
   return empty
end _HCSelectAll

-- The picture Select All took, while a paint tool is chosen and its card
-- is this card: its image's long id, or empty
private function _HCSelectedPicture
   if not _HCPaintTool() or line 1 of sHCPicture is not the long id of this card then return empty
   if line 2 of sHCPicture is empty or not exists(line 2 of sHCPicture) then return empty
   return line 2 of sHCPicture
end _HCSelectedPicture

-- Flip Horizontal, Flip Vertical of the picture Select All took
private function _HCFlip pDirection
   local tPicture
   put _HCSelectedPicture() into tPicture
   if tPicture is not empty then do "flip" && tPicture && pDirection
   return empty
end _HCFlip

-- Button Info... to Stack Info...: the object in the IDE's inspector
private function _HCInfo pWhat, pItem
   local tObject, tCard
   switch pWhat
      case "button"
      case "field"
         put line 1 of _HCSelected(pWhat) into tObject
         break
      case "card"
         put the long id of this card into tObject
         break
      case "bkgnd"
      case "background"
         put the long id of this card into tCard
         if the number of backgrounds of tCard > 0 then put the long id of background 1 of tCard into tObject
         break
      case "stack"
         put the long id of this stack into tObject
         break
   end switch
   if tObject is empty then return empty
   -- (a standalone has no inspector)
   if the environment is "development" then
      dispatch "revIDEInspectObjects" with tObject
      if it is "handled" then return empty
   end if
   return "doMenu" && quote & pItem & quote && "not implemented"
end _HCInfo

-- Bring Closer (pBy 1) and Send Farther (-1): the selected object a layer
-- up or down
private function _HCLayer pBy
   local tObject
   put line 1 of the selectedObjects into tObject
   if tObject is empty or the layer of tObject + pBy < 1 then return empty
   set the layer of tObject to the layer of tObject + pBy
   return empty
end _HCLayer

-- New Background: a card after this one with a background of its own (a
-- new card here gets the backgrounds of the card it follows)
private function _HCNewBackground
   local tGroup, tCard
   create card
   put the long id of this card into tCard
   repeat while the number of backgrounds of tCard > 0
      remove group id (the id of background 1 of tCard) from this card
   end repeat
   create group
   put it into tGroup
   set the backgroundBehavior of tGroup to true
   return empty
end _HCNewBackground

-- The selected text, else the selected buttons and fields: what the Style
-- and Font menus changed. A chunk or long ids, one a line
private function _HCTextTargets
   local tChunk, tObject, tList
   put the selectedChunk into tChunk
   if _HCHasText(tChunk) then return tChunk
   repeat for each line tObject in the selectedObjects
      if word 1 of tObject is among the words of "button field" then put tObject & return after tList
   end repeat
   delete the last char of tList
   return tList
end _HCTextTargets

-- A style of the Style menu (in HyperCard's words), on or off: Plain takes
-- every style off; a style the text has already is taken off; outline and
-- shadow, which this engine does not have, do nothing
private function _HCStyle pStyle
   local tStyle, tTarget, tStyles
   put hcTextStyle(pStyle) into tStyle
   if tStyle is "plain" and pStyle is not "plain" then return empty
   repeat for each line tTarget in _HCTextTargets()
      if tStyle is "plain" then
         put "plain" into tStyles
      else
         do "put the textStyle of" && tTarget && "into tStyles"
         if tStyle is among the items of tStyles then
            delete item itemOffset(tStyle, tStyles) of tStyles
         else if tStyles is empty or tStyles is among the words of "plain mixed" then
            put tStyle into tStyles
         else
            put comma & tStyle after tStyles
         end if
         if tStyles is empty then put "plain" into tStyles
      end if
      do "set the textStyle of" && tTarget && "to tStyles"
   end repeat
   return empty
end _HCStyle

-- A font or a size from the Font and Style menus, for the selected text
-- or the selected buttons and fields
private function _HCTextProperty pProperty, pValue
   local tTarget
   repeat for each line tTarget in _HCTextTargets()
      do "set the" && pProperty && "of" && tTarget && "to pValue"
   end repeat
   return empty
end _HCTextProperty

-- The fonts of the Macs HyperCard ran on, which a stack's menu choices
-- name whether or not this computer has them
constant kHCFonts = "Chicago,Geneva,Monaco,New York,Times,Helvetica,Courier,Palatino,Symbol,Zapf Dingbats,Zapf Chancery,Avant Garde,Bookman,New Century Schlbk,Helvetica Narrow,Venice,London,Athens,San Francisco,Los Angeles,Cairo,Toronto,Mobile,Charcoal"

-- pItem as a font's name: one this computer has, or one of HyperCard's
-- Macs; else empty
private function _HCFont pItem
   put word 1 to -1 of pItem into pItem
   if pItem is empty then return empty
   if pItem is among the lines of the fontNames or pItem is among the items of kHCFonts then return pItem
   return empty
end _HCFont

-- New Stack...: a stack of this one's size, saved where the user says,
-- and gone to; "without dialog", one called "Untitled", not saved
private function _HCNewStack pWithout
   local tWidth, tHeight, tPath, tName, tStack
   put the width of this stack into tWidth
   put the height of this stack into tHeight
   put "Untitled" into tName
   if pWithout is not "without dialog" then
      ask file "New stack name:" with "Untitled"
      if it is empty then return "Cancel"
      put it into tPath
      set the itemDelimiter to slash
      put the last item of tPath into tName
   end if
   create stack tName
   put it into tStack
   set the width of tStack to tWidth
   set the height of tStack to tHeight
   if tPath is not empty then save tStack as tPath
   go tStack
   return the result
end _HCNewStack

-- Save a Copy...: the stack (its mainstack, with every substack) saved to
-- the file the user names; the stack itself is still where it was
private function _HCSaveACopy
   local tStack, tFile, tPath, tResult
   put the long id of stack (the mainStack of this stack) into tStack
   ask file "Save a copy of the stack as:" with (the short name of tStack && "Copy")
   if it is empty then return "Cancel"
   put it into tPath
   put the fileName of tStack into tFile
   save tStack as tPath
   put the result into tResult
   set the fileName of tStack to tFile
   return tResult
end _HCSaveACopy

-- Delete Stack...: the stack is closed and gone from memory, and its file
-- deleted. It asks first ("without dialog" too, whenever a file would be
-- deleted: a HyperCard script's say-so is not the user's); a stack
-- imported and not saved yet has no file of its own
private function _HCDeleteStack pWithout
   local tStack, tFile
   put the long id of stack (the mainStack of this stack) into tStack
   put the fileName of tStack into tFile
   if tFile is not empty then
      answer warning "Delete the stack" && quote & the short name of tStack & quote && "and its file?" & return & tFile with "Cancel" or "Delete"
      if it is not "Delete" then
         return "Cancel"
      end if
   else if pWithout is not "without dialog" then
      answer warning "Delete the stack" && quote & the short name of tStack & quote & "?" with "Cancel" or "Delete"
      if it is not "Delete" then
         return "Cancel"
      end if
   end if
   if tFile is not empty and there is a file tFile then delete file tFile
   set the destroyStack of tStack to true
   close tStack
   return empty
end _HCDeleteStack

-- The stack in the file pPath, for Open Stack...: a HyperCard stack is
-- imported as "go" imports one (_HCImport), with its scripts fixed
private function _HCOpenStack pPath
   local tStack, tWasLocked
   put the lockMessages into tWasLocked
   lock messages
   try
      put the long id of stack pPath into tStack
   catch tError
      put empty into tStack
   end try
   set the lockMessages to tWasLocked
   if tStack is empty then return empty
   if the HCStack of tStack and the behavior of tStack is empty then return _HCImport(pPath)
   return tStack
end _HCOpenStack

-- HyperCard's version, which scripts compare with numbers ("the version
-- < 2"): that of HyperCard 2.4.1, the last
function hcVersion
   return "2.4.1"
end hcVersion

-- the heapSpace: the memory HyperCard had free, which stacks checked
-- before they ran (Gems of Hubble quits under 1321000). This engine's
-- heapSpace is 1000000 always; 16 MB passes those checks
function hcHeapSpace
   return 16777216
end hcHeapSpace

-- HyperCard's long version, as HyperCard 2.4.1 gave it
function hcLongVersion
   return "02418000"
end hcLongVersion

-- Whether HyperCard was in the background (MultiFinder): never here
function hcSuspended
   return false
end hcSuspended

-- HyperCard's name (rule T29): "HyperCard", or with pForm "long" its
-- path as HyperCard gave it, a Mac path with colons. Scripts take the
-- folder from it and add a stack's name, so it is put in the folder the
-- stack was imported from (on its disk image, the folder there), where
-- "go" finds the stacks beside it by their names
function hcHyperCardName pForm
   local tSet, tFolder
   if pForm is not "long" then
      return "HyperCard"
   end if
   put the customProperties["uHyperCard"] of me into tSet
   if tSet["imagepath"] is not empty then
      set the itemDelimiter to ":"
      put item 1 to -2 of tSet["imagepath"] into tFolder
   else if tSet["file"] is not empty then
      set the itemDelimiter to slash
      put item 1 to -2 of tSet["file"] into tFolder
      replace slash with ":" in tFolder
      if char 1 of tFolder is ":" then
         delete char 1 of tFolder
      end if
   else
      put "HyperCard" into tFolder
   end if
   return tFolder & ":HyperCard"
end hcHyperCardName

-- send message to HyperCard (rule T29): the message's built-in handler,
-- passing the stack's own; "doMenu Copy Text", the item not in quotes,
-- as HyperCard read it, and the menu's name after a comma and "without
-- dialog" after them ("doMenu "Paste Card", "Edit" without dialog")
on hcSendToHyperCard pMessage
   local tItem, tMenu, tWithout, tRest, tAt
   if word 1 of pMessage is "doMenu" then
      put word 2 to -1 of pMessage into tItem
      if word -2 to -1 of tItem is "without dialog" then
         put "without dialog" into tWithout
         put word 1 to -3 of tItem into tItem
      end if
      if char 1 of tItem is quote then
         put char 2 to -1 of tItem into tRest
         put offset(quote, tRest) into tAt
         if tAt is 0 then
            put tRest into tItem
         else
            put char 1 to tAt - 1 of tRest into tItem
            put char tAt + 1 to -1 of tRest into tMenu
            put word 1 to -1 of tMenu into tMenu
         end if
         if char 1 of tMenu is comma then
            delete char 1 of tMenu
         else
            put empty into tMenu
         end if
      else if comma is in tItem then
         put item 2 to -1 of tItem into tMenu
         put item 1 of tItem into tItem
      end if
      put word 1 to -1 of tItem into tItem
      put word 1 to -1 of tMenu into tMenu
      if char 1 of tMenu is quote then delete char 1 of tMenu
      if char -1 of tMenu is quote then delete char -1 of tMenu
      -- (HyperCard's own menu items: not doMenu, which in a stack with
      -- HyperCard's message order would reach the stack's handlers again)
      hcMenuChoice tItem, tMenu, tWithout
      return the result
   end if
   try
      do pMessage
   catch tError
      return "Can't understand" && pMessage
   end try
   return the result
end hcSendToHyperCard

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

-- HyperCard 2's Home stack had handlers other stacks called, as they
-- were in every user's message path (a CD's stacks call getHomeInfo in
-- 47 stacks, lastHCItem in 11, setUserLevelFive in 9). With no Home
-- stack here, these stand in for them; a stack's own comes first.

-- getHomeInfo: the Home stack read the user's name and search paths into
-- these globals (Stacks and Documents are hc_Stacks and hc_Documents in
-- the rewritten scripts, rule T2). The name is the system's user; the
-- paths stay as they are
on getHomeInfo
   global hc_Stacks, Applications, hc_Documents, UserName
   if UserName is empty then
      put $USER into UserName
      if UserName is empty then put $USERNAME into UserName
   end if
   return empty
end getHomeInfo

on setUserLevelFive
   global SvLvl
   put the userLevel into SvLvl
   set the userLevel to 5
end setUserLevelFive

on restoreUserLevel
   global SvLvl
   if SvLvl is a number then set the userLevel to SvLvl
end restoreUserLevel

on allowInterruption
   set the cantAbort of this stack to false
end allowInterruption

on disallowInterruption
   set the cantAbort of this stack to true
end disallowInterruption

-- A statement that the import left out of a handler because it does not
-- compile here (rule T39), after the then or the else of an if, where a
-- statement has to be: it does nothing, and the handler goes on, as it
-- does past a line left out whole (a comment). pStatement is the
-- statement as it was
on hcLeftOut pStatement
end hcLeftOut

-- the part of pText after the last pDelim, all of it with none
function lastHCItem pDelim, pText
   local tAt
   if pDelim is empty then return pText
   repeat
      put offset(pDelim, pText) into tAt
      if tAt is 0 then exit repeat
      delete char 1 to tAt + the number of chars of pDelim - 1 of pText
   end repeat
   return pText
end lastHCItem

-- the fonts the Home stack checked for and warned of: shown here in
-- another face when the system lacks them, which the import summary says
function checkHCFont pFont, pSizes
   if pFont is among the lines of the fontNames then return empty
   return pFont && pSizes & return
end checkHCFont

on checkForMissingFonts
   return empty
end checkForMissingFonts

-- debug sound off, debug pureQuickDraw true...: HyperCard 2's debug
-- options (rule T35), which have nothing to set here
on hcDebug pOptions
   return empty
end hcDebug

-- Externals stacks called most that this script can do (a CD's stacks:
-- SetVolume in 26, GetVolume in 18, Trim in 12): a stack's own XCMD or
-- XFCN of the name is not run here, so these stand in for it

-- the sound volume, 0 to 7 as the Macintosh's, from this engine's
-- playLoudness (0 to 100)
function GetVolume
   return round(the playLoudness * 7 / 100)
end GetVolume

on SetVolume pLevel
   if pLevel is not a number then return empty
   set the playLoudness to max(0, min(100, round(pLevel * 100 / 7)))
end SetVolume

-- whether the system has the font (FontExists in 19 stacks of the CD);
-- any size of a font it has is drawn here
function FontExists pFont, pSize
   return pFont is among the lines of the fontNames
end FontExists

-- the name of the window in front (FrontWindow, 12 stacks)
function FrontWindow
   return the short name of the topStack
end FrontWindow

-- the text without the spaces and tabs at its start and end
function Trim pText
   repeat while pText is not empty and (char 1 of pText is space or char 1 of pText is tab)
      delete char 1 of pText
   end repeat
   repeat while pText is not empty and (char -1 of pText is space or char -1 of pText is tab)
      delete char -1 of pText
   end repeat
   return pText
end Trim

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
go to a destination given by an expression (rule T25): pDest, its value;
pWindow, what followed it ("in a new window"). What "go" here takes (a
card's description, a stack that is open) it goes to; else a stack found
as hcGo finds one; else it leaves "No such card" in the result, as
HyperCard did, where "go" here stops with an error
*/
on hcGoTo pDest, pWindow
   local tStack
   if _HCLastPart(pDest) is "Home" then
      hcGoHome
      return the result
   end if
   try
      do "go to pDest" && pWindow
      return the result
   catch tError
   end try
   if word 1 of pDest is among the words of "card cd background bkgnd bg stack" then return "No such card"
   put hcStackName(pDest) into tStack
   if tStack is empty then return "No such card"
   try
      do "go to stack tStack" && pWindow
      return the result
   catch tError
   end try
   return "No such card"
end hcGoTo

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
      -- this engine's stack names have no commas: the name it gives
      if the short name of tStack contains comma then
         set the name of tStack to the short name of tStack
         put the long id of stack (the short name of tStack) into tStack
      end if
      if line 2 of pFile is empty then
         set the uHyperCard["file"] of tStack to tPath
      else
         set the uHyperCard["image"] of tStack to line 2 of pFile
         set the uHyperCard["imagepath"] of tStack to line 3 of pFile
         -- a name Windows refuses for a file was copied out under
         -- another (revHyperCardImageExtract): the stack gets its own
         if the platform is "Win32" then
            set the itemDelimiter to colon
            put the last item of line 3 of pFile into tEach
            replace slash with "-" in tEach
            replace comma with "_" in tEach
            if the short name of tStack is not tEach then
               set the name of tStack to tEach
               put the long id of stack tEach into tStack
            end if
         end if
      end if
      -- HyperCard's message order, as the stack it is gone to from has it
      -- (before its scripts are fixed, which compile them)
      try
         if the hyperTalkCompatible of stack (the mainStack of this stack) is true then
            set the hyperTalkCompatible of tStack to true
         end if
      catch tError
      end try
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

-- dial without a modem: HyperCard played the number's touch tones
-- through the speaker; here the call reaches the library by its name and
-- does nothing but say so in the result
on dial pNumber
   return "dial is not supported"
end dial

-- start using and stop using a stack (rule T23), found as hcStackName
-- finds the stack of a "go": a library stack beside this one, or on its
-- disk image; one that cannot be found leaves the result set, where this
-- engine stopped with an error
on hcStartUsing pStack
   local tStack
   put hcStackName(pStack) into tStack
   if tStack is empty then return "Can't find stack" && pStack
   if word 1 of tStack is "stack" then
      start using tStack
   else
      start using stack tStack
   end if
   return empty
end hcStartUsing

on hcStopUsing pStack
   if there is not a stack pStack then return "Can't find stack" && pStack
   stop using stack pStack
   return empty
end hcStopUsing

----------------------------------------------------------------------
-- open an application (rule T40)
--
-- HyperCard's "open" launched an application, with a document when the
-- script named one ("open "My Letter" with "TeachText""). It asked "Where
-- is ...?" when it could not find the application, and when it could not
-- open it left "Couldn't open that application." in the result, which
-- scripts test, and the script went on. Here an "open" of anything but a
-- file, printing, a process or a socket is a "go", which stops the script
-- with an error; the import rewrites it as hcOpen.

-- The applications the user said where to find when asked, by name, for
-- as long as the library is open
local sHCApplications

/*
open pApplication, or pDocument with pApplication, as HyperCard did (rule
T40): the application is pApplication itself when there is such a file
(or, on a Mac, such an application's bundle), else one of that name in a
Mac's Applications folders, else the file the user gives when asked
"Where is ...?" (in the IDE, once a name, as for a stack). The document
is pDocument, or a file of that name beside this stack's file or the
HyperCard file it was imported from. Leaves "Couldn't open that
application." in the result when there is no application to launch or
it cannot be launched; an application already running counts as opened,
as HyperCard brought it to the front
*/
on hcOpen pApplication, pDocument
   local tApplication, tDocument, tResult
   put _HCApplication(pApplication) into tApplication
   if tApplication is empty then return "Couldn't open that application."
   if pDocument is not empty then put _HCDocument(pDocument) into tDocument
   put _HCLaunch(tApplication, tDocument) into tResult
   if tResult is not empty and tResult is not "process is already open" then return "Couldn't open that application."
   return empty
end hcOpen

-- The application pName names, as hcOpen finds it, or empty. HyperCard
-- named one by its HFS path ("Disk:Apps:TeachText") or by its name
private function _HCApplication pName
   local tName, tFolder, tPath
   if pName is empty then return empty
   if there is a file pName or (pName ends with ".app" and there is a folder pName) then return pName
   put _HCLastPart(pName) into tName
   if tName is empty then return empty
   if sHCApplications[tName] is not empty then return sHCApplications[tName]
   if the platform is "MacOS" then
      repeat for each item tFolder in "/Applications,/System/Applications," & specialFolderPath("home") & "/Applications"
         put tFolder & slash & tName into tPath
         if not (tPath ends with ".app") then put ".app" after tPath
         if there is a folder tPath then return tPath
      end repeat
   end if
   put _HCWhereIs(tName) into tPath
   if tPath is empty then return empty
   put tPath into sHCApplications[tName]
   return tPath
end _HCApplication

-- The document pDocument names, as hcOpen finds it: pDocument as it is
-- when there is no such file beside the stack either
private function _HCDocument pDocument
   local tName, tSet, tFolders, tFolder
   if there is a file pDocument or there is a folder pDocument then return pDocument
   put _HCLastPart(pDocument) into tName
   put the customProperties["uHyperCard"] of me into tSet
   set the itemDelimiter to slash
   put item 1 to -2 of (the effective filename of me) into tFolders
   put return & item 1 to -2 of tSet["file"] after tFolders
   repeat for each line tFolder in tFolders
      if tFolder is not empty and there is a file (tFolder & slash & tName) then return tFolder & slash & tName
   end repeat
   return pDocument
end _HCDocument

-- launch, in a handler of its own so that the result is launch's (on
-- Linux it is empty even when there was nothing to launch, which is why
-- _HCApplication finds the file first)
private function _HCLaunch pApplication, pDocument
   try
      if pDocument is empty then
         launch pApplication
      else
         launch pDocument with pApplication
      end if
   catch tError
      -- (a player that cannot start a process: the web's, a phone's)
      return "can't launch"
   end try
   return the result
end _HCLaunch

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
      -- (with menuMsg X: the item's message too)
      if pMessages is not empty then put word 1 to -1 of pMessages into sHCMenus[tKey][tAt]["menumessage"]
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

-- HyperCard's commands that this engine has too, which a menu message
-- can be (_HCSendMenuMessage)
constant kHCMenuCommands = "add answer ask beep choose click close convert create delete disable divide drag edit enable export find get go hide import lock mark multiply open palette play pop print push put read reply request reset save select send set show sort start stop subtract type unlock unmark visual wait write"

-- Sends pMessage, the menu message of an item chosen, to this card, as
-- HyperCard did. A handler of the stack's takes it, with its parameters
-- as send gives them ("doImport single"). One of HyperCard's commands
-- with parameters ("go to card id 90024", "hide field 1", "show fld
-- "Notes"") runs as it was written, as HyperCard ran a command of its own
-- that no handler took: send would hand it to the engine with its
-- parameters evaluated first, and hide the field named by the text of
-- field 1. A doMenu goes to the stack's doMenu handlers, called hcDoMenu
-- in a stack imported without HyperCard's message order (rule T15)
private command _HCSendMenuMessage pMessage
   local tName
   put word 1 of pMessage into tName
   if tName is "doMenu" then
      if the hyperTalkCompatible of stack (the mainStack of this stack) is not true then
         put "hcDoMenu" into word 1 of pMessage
      end if
   else if word 2 of pMessage is not empty and tName is among the words of kHCMenuCommands then
      do pMessage
      return the result
   end if
   send pMessage to this card
   return the result
end _HCSendMenuMessage

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
   -- by its place, when no item has that name: "last", "first" ...
   -- "tenth", "middle" (a script's "last menuItem of menu M")
   if pItem is among the words of "first second third fourth fifth sixth seventh eighth ninth tenth" then
      put wordOffset(pItem, "first second third fourth fifth sixth seventh eighth ninth tenth") into i
   else if pItem is "last" then
      put sHCMenus[pKey]["count"] into i
   else if pItem is "middle" then
      put (sHCMenus[pKey]["count"] + 1) div 2 into i
   else
      return 0
   end if
   if i >= 1 and i <= sHCMenus[pKey]["count"] then return i
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
      if pCursor <= 29 then return pCursor
      -- a CURS resource with no image here (a copy of the stack without
      -- its resource fork) gives empty too, where the set stopped
      if there is an image id pCursor then return pCursor
      if there is an image id pCursor of stack (the mainStack of me) then return pCursor
      return empty
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

-- set the rect of this card (rule T32): HyperCard 2.2 resized the card,
-- and with it the card window; here the stack's window takes the size
on hcSetCardRect pRect
   local i
   repeat with i = 2 to paramCount()
      put comma & param(i) after pRect
   end repeat
   if the number of items of pRect is not 4 then return "Invalid card size"
   repeat for each item i in pRect
      if i is not an integer then return "Invalid card size"
   end repeat
   set the width of this stack to item 3 of pRect - item 1 of pRect
   set the height of this stack to item 4 of pRect - item 2 of pRect
   return empty
end hcSetCardRect

-- A text style as HyperCard named it (rule T32): condense and extend are
-- condensed and expanded here, group is this engine's group (link), and
-- outline and shadow, which this engine does not have, are left out
function hcTextStyle
   local i, tStyles, tStyle, tOut
   repeat with i = 1 to paramCount()
      put param(i) & comma after tStyles
   end repeat
   repeat for each item tStyle in tStyles
      put word 1 to -1 of tStyle into tStyle
      if tStyle is "condense" then put "condensed" into tStyle
      if tStyle is "extend" then put "expanded" into tStyle
      if tStyle is empty or tStyle is among the words of "outline shadow" then next repeat
      put tStyle & comma after tOut
   end repeat
   delete the last char of tOut
   if tOut is empty then return "plain"
   return tOut
end hcTextStyle

-- choose tool N (rule T30): HyperCard's tools by their numbers in the
-- tools palette (1 browse to 18 polygon), or by a name with or without
-- "tool" after it; this engine's "choose tool x" stops with an error
-- whatever x is. A tool that is none of these leaves the tool as it was
-- and "No such tool" in the result
on hcChooseTool pTool
   local tNames
   put "browse,button,field,select,lasso,pencil,brush,eraser,line,spray can,rectangle,round rectangle,bucket,oval,curve,text,regular polygon,polygon" into tNames
   put toLower(word 1 to -1 of pTool) into pTool
   if word -1 of pTool is "tool" then put word 1 to -2 of pTool into pTool
   if pTool is an integer and pTool >= 1 and pTool <= 18 then put item pTool of tNames into pTool
   if pTool is "btn" then put "button" into pTool
   if pTool is "fld" then put "field" into pTool
   if pTool is "spray" then put "spray can" into pTool
   if pTool is among the items of tNames or pTool is "pointer" then
      choose (pTool && "tool")
      return empty
   end if
   return "No such tool"
end hcChooseTool

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

-- HyperCard's own windows, which this engine does not have: their
-- properties as scripts set them (rule T28), and whether they are shown
constant kHCOwnWindows = "tool,tools,pattern,patterns,scroll,fatbits,navigator,variable watcher,message watcher"
local sHCWindows

-- show, hide and close window (rule T21): a window that is a stack here
-- (a palette the import made, a picture the picture command opened, or
-- any stack), the message box, and HyperCard's own windows, which are
-- not here (the tool, pattern, scroll, FatBits and navigator windows):
-- left alone, as an error here would stop the script, but shown or
-- hidden as far as hcWindowProperty("visible", ...) reads
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
   if pName is among the words of "tool tools pattern patterns scroll fatbits navigator" then
      put (pVerb is "show") into sHCWindows[pName]["visible"]
      return empty
   end if
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

/*
set the P of window W to V (rule T26), for the properties of HyperCard's
picture and palette windows that this engine's windows do not have:
scale (-5 to 5, the picture shown at 2 to that power) and scroll (the
point of the picture at the window's top left) of a picture window;
hilitedButton (its number, 0 for none) of a palette; globalLoc and
globalRect, the window's place on the screen. The card window ("card
window") always shows the whole card here, so its scroll is left as it
is, as are zoom and dithering. A window that is not open leaves "No
such window" in the result, as HyperCard said, rather than an error
*/
-- the visible (or another property) of one of HyperCard's own windows:
-- what a script set, or false for the visible of one never shown
function hcWindowProperty pProp, pWindow
   if sHCWindows[pWindow][pProp] is empty and pProp is "visible" then return false
   return sHCWindows[pWindow][pProp]
end hcWindowProperty

on hcSetWindow pProp, pWindow, pValue
   local tStack, tImage, i
   -- (a point or a rect not in quotes comes as more than one parameter)
   repeat with i = 4 to paramCount()
      put comma & param(i) after pValue
   end repeat
   if pWindow is "card window" then return empty
   if pWindow is among the items of kHCOwnWindows then
      put pValue into sHCWindows[pWindow][pProp]
      return empty
   end if
   if there is not a stack pWindow then return "No such window"
   put the long id of stack pWindow into tStack
   if there is an image "Picture" of card 1 of tStack then
      put the long id of image "Picture" of card 1 of tStack into tImage
   end if
   switch pProp
      case "scale"
         if tImage is empty or pValue is not an integer then return empty
         put max(-5, min(5, pValue)) into pValue
         lock screen
         set the width of tImage to max(1, round(the formattedWidth of tImage * 2 ^ pValue))
         set the height of tImage to max(1, round(the formattedHeight of tImage * 2 ^ pValue))
         set the topLeft of tImage to 0,0
         unlock screen
         break
      case "scroll"
         if tImage is empty or item 1 of pValue is not a number or item 2 of pValue is not a number then return empty
         set the topLeft of tImage to -(item 1 of pValue), -(item 2 of pValue)
         break
      case "hilitedbutton"
         repeat with i = 1 to the number of buttons of card 1 of tStack
            set the hilite of button i of card 1 of tStack to (i = pValue)
         end repeat
         break
      case "globalloc"
         set the topLeft of tStack to pValue
         break
      case "globalrect"
         set the rect of tStack to pValue
         break
   end switch
   return empty
end hcSetWindow

/*
The properties of the message box (rule T28): "the visible of msg" and
"set the loc of the message box to ..." name the message box's text
here, and stop with an error. In the IDE they are those of its Message
Box; where there is none (the Stack Player), the values a script set
read back, and the message box is not visible
*/
local sHCMessageBox

function hcMessageBox pProp
   local tValue
   if there is a stack "Message Box" then
      try
         do "put the" && pProp && "of stack" && quote & "Message Box" & quote && "into tValue"
         return tValue
      catch tError
      end try
   end if
   if pProp is "visible" and sHCMessageBox["visible"] is empty then return false
   return sHCMessageBox[pProp]
end hcMessageBox

on hcSetMessageBox pProp, pValue
   local i
   -- (a point or a rect not in quotes comes as more than one parameter)
   repeat with i = 3 to paramCount()
      put comma & param(i) after pValue
   end repeat
   put pValue into sHCMessageBox[pProp]
   if there is not a stack "Message Box" then return empty
   try
      if pProp is "visible" then
         if pValue is true then
            show message box
         else
            hide message box
         end if
      else
         do "set the" && pProp && "of stack" && quote & "Message Box" & quote && "to pValue"
      end if
   catch tError
   end try
   return empty
end hcSetMessageBox

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
   local tParams, i
   repeat with i = 1 to paramCount()
      put param(i) & return after tParams
   end repeat
   return _HCFileName(tParams)
end FileName

-- fileName(...) after the import (rule T20; this engine reads
-- "fileName(" as the property, here as in value()): FileName, above
function hcX_FileName
   local tParams, i
   repeat with i = 1 to paramCount()
      put param(i) & return after tParams
   end repeat
   return _HCFileName(tParams)
end hcX_FileName

private function _HCFileName pParams
   local tPrompt, tParam
   put "Choose a file:" into tPrompt
   repeat for each line tParam in pParams
      if the number of chars of tParam > 4 then put tParam into tPrompt
   end repeat
   answer file tPrompt
   if the result is "Cancel" then return empty
   return it
end _HCFileName

-- StandardFile(mode[, file types...][, default name]), the XFCN: the path
-- of a file the user picks, or empty if they cancel. A mode that begins
-- "put" is the save dialog (its default name the second parameter),
-- any other the open dialog; a prompt follows the mode after a colon
-- ("get:Open which stack?")
function StandardFile pMode, pDefault
   local tPrompt
   set the itemDelimiter to colon
   put item 2 to -1 of pMode into tPrompt
   if word 1 of item 1 of pMode is "put" then
      if tPrompt is empty then put "Save as:" into tPrompt
      ask file tPrompt with pDefault
   else
      if tPrompt is empty then put "Choose a file:" into tPrompt
      answer file tPrompt
   end if
   if the result is "Cancel" then return empty
   return it
end StandardFile

-- SelectFile([file types,] [prompt]), the XFCN: the path of a file the
-- user picks, or empty if they cancel
function SelectFile
   local tParams, i
   repeat with i = 1 to paramCount()
      put param(i) & return after tParams
   end repeat
   return _HCFileName(tParams)
end SelectFile

-- SelectDir([prompt]), the XFCN: the path of a folder the user picks, or
-- empty if they cancel
function SelectDir pPrompt
   if pPrompt is empty then put "Choose a folder:" into pPrompt
   answer folder pPrompt
   if the result is "Cancel" then return empty
   return it
end SelectDir

-- MultiFinder(), the XFCN: whether the Mac ran more than one application
-- at once, which every system here does
function MultiFinder
   return true
end MultiFinder

-- CapsLock(), the XFCN: whether the caps lock key is down
function CapsLock
   return the capsLockKey is down
end CapsLock

-- FileExists(path[, options]), the XFCN: whether there is such a file or
-- folder (a path here, not a Mac path with colons)
function FileExists pPath
   if pPath is empty then return false
   return there is a file pPath or there is a folder pPath
end FileExists

-- inKey(), the XFCN: the character of a key being held down, or empty if
-- none, which scripts read in a loop ("if inKey() is space then exit
-- repeat")
function inKey
   local tKey
   repeat for each item tKey in the keysDown
      if tKey is an integer and tKey >= 32 and tKey < 127 then return numToChar(tKey)
      if tKey is 65293 then return return
   end repeat
   return empty
end inKey

-- HyperCard's own messages, sent by a script to an object with no handler
-- for them ("send mouseUp to bg btn 3", "send tabKey to this card"):
-- HyperCard took them at the end of the path; this engine stops with
-- "can't find handler". Here they end, as they did, and go on to the
-- engine as they would
on mouseUp
   pass mouseUp
end mouseUp

on mouseDown
   pass mouseDown
end mouseDown

on openCard
   pass openCard
end openCard

on closeCard
   pass closeCard
end closeCard

on openBackground
   pass openBackground
end openBackground

on closeBackground
   pass closeBackground
end closeBackground

on openStack
   pass openStack
end openStack

on closeStack
   pass closeStack
end closeStack

on tabKey
   pass tabKey
end tabKey

on returnKey
   pass returnKey
end returnKey

on enterKey
   pass enterKey
end enterKey

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

-- SpeakString text and Say text, the speech XCMDs stacks carried (The
-- Haunted House speaks with SpeakString): the same
on SpeakString pText
   return _HCSpeak(pText)
end SpeakString

on Say pText
   return _HCSpeak(pText)
end Say

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

-- cHCcolorize and cHCunColorize: the handlers of "Colorizing HyperCard",
-- which a stack that used it called from a shared stack of its own; the
-- colours are the importer's colour layer here, so nothing to do (a stack
-- with these handlers in its own script still runs its own)
on cHCcolorize
   return empty
end cHCcolorize

on cHCunColorize
   return empty
end cHCunColorize

-- volume(level) and SndVolume(level), the XFCNs: the sound volume, 0 to
-- 7, as the Mac's control panel had it. The level is kept, so a script
-- that saves the old level and puts it back sees what it set; the
-- engine's own volume is left alone
local sHCVolume

function volume pLevel
   return _HCVolume(pLevel)
end volume

function SndVolume pLevel
   return _HCVolume(pLevel)
end SndVolume

private function _HCVolume pLevel
   local tOld
   if sHCVolume is empty then put 7 into sHCVolume
   put sHCVolume into tOld
   if pLevel is an integer and pLevel >= 0 and pLevel <= 7 then put pLevel into sHCVolume
   return tOld
end _HCVolume

-- objectExists(description), the XFCN: whether there is such an object
-- ("bg button " & quote & "Next" & quote)
function objectExists pObject
   local tExists
   try
      do "put there is a" && pObject && "into tExists"
   catch tError
      return false
   end try
   return tExists is true
end objectExists

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

-- In a browser (the Stack Player) by the page's speech synthesis, else
-- by revSpeak
private function _HCSpeak pText
   if the platform is "web" then
      try
         do "window.speechSynthesis.speak(new SpeechSynthesisUtterance(" & _HCJavaScriptString(pText) & "))" as "javascript"
      catch tError
         return "Speech is not available"
      end try
      return empty
   end if
   try
      revSpeak pText
   catch tError
      return "Speech is not available"
   end try
   return the result
end _HCSpeak

-- pText as a JavaScript string literal
private function _HCJavaScriptString pText
   replace "\" with "\\" in pText
   replace quote with "\" & quote in pText
   replace return with "\n" in pText
   replace numToChar(13) with "\r" in pText
   return quote & pText & quote
end _HCJavaScriptString
