script "stack_Zip_Archives"
-- Stack file: ide/Resources/Examples/Remastered/Zip Archives.oxtstack
-- Object: stack "Zip Archives"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--Zip Archives: Zip Build Demo and Zip Extract Demo, from OpenXTalk Lite's demos, remastered together for OXT-Beyond in 2026
--Zip Build Sampler and Zip Extract Sampler, version 1.0.0.0: "2006  All rights reserved worldwide" (their standalone settings)

--Each demo is a card now: Zip Build Demo is "Make an Archive", and Zip Extract Demo is "Look Inside".
--What each demo's stack script did, its card's script does; this script starts them both, as the
--demos' stack scripts did, and holds what the remaster added for both cards. The sidebar, the header
--and the panel of scripts are the groups "Frame", "Workbench" and "Scripts", which the script of the
--group "Frame" runs.

on preOpenStack
   -- Initialise the stack, putting empty into the files
   -- list and making sure the instruction field is visible
   -- (remaster: on both cards, which were the demos' card "Main")
   set the text of field "Files" of card "Make an Archive" of me to empty
   set the blendLevel of field "Label" of card "Make an Archive" of me to 0
   set the text of field "Files" of card "Look Inside" of me to empty
   set the blendLevel of field "Label" of card "Look Inside" of me to 0
end preOpenStack

-- (remaster) True if the zip library, revZip, is loaded. The IDE loads it,
-- and the web engine has it built in; without it, its commands would stop
-- the program with an error
function zipLoaded
   local tError
   try
      get revZipOpenArchives()
   catch tError
      return false
   end try
   return true
end zipLoaded

-- (remaster) The size of a file, in bytes, from the detailed list of the
-- files in its folder
function fileSize pPath
   local tFolder, tName, tLine
   set the itemDelimiter to slash
   put item 1 to -2 of pPath into tFolder
   put item -1 of pPath into tName
   if char 1 of pPath is slash and tFolder is empty then put slash into tFolder
   if tFolder is empty then put the defaultFolder into tFolder
   set the itemDelimiter to comma
   repeat for each line tLine in files(tFolder, "detailed")
      if urlDecode(item 1 of tLine) is tName then return item 2 of tLine
   end repeat
   return 0
end fileSize

-- (remaster) A size in words: 18 bytes, 4.2 KB, 12 KB, 1.5 MB
function sizeText pBytes
   if pBytes is not a number then return empty
   if pBytes is 1 then return "1 byte"
   if pBytes < 1024 then return pBytes && "bytes"
   if pBytes < 10 * 1024 then return format("%.1f KB", pBytes / 1024)
   if pBytes < 1024 * 1024 then return round(pBytes / 1024) && "KB"
   if pBytes < 1024 * 1024 * 1024 then return format("%.1f MB", pBytes / (1024 * 1024))
   return format("%.1f GB", pBytes / (1024 * 1024 * 1024))
end sizeText

-- (remaster) "1 file", "3 files"
function plural pCount, pWord
   if pCount is 1 then return "1" && pWord
   return pCount && pWord & "s"
end plural

-- (remaster) pText, shortened at its end with an ellipsis if it is wider
-- than pWidth in pField's font
function nameFit pText, pWidth, pField
   local tText, tTry
   if measureText(pText, pField) <= pWidth then return pText
   put pText into tText
   repeat while the number of chars of tText > 1
      delete the last char of tText
      put tText & numToCodepoint(8230) into tTry
      if measureText(tTry, pField) <= pWidth then exit repeat
   end repeat
   return tText & numToCodepoint(8230)
end nameFit

-- (remaster) The look of a card's list: an icon at the start of each row
-- (a folder's, for a row whose last item ends with a slash), its size in a
-- softer colour, and a scroll bar if the rows do not fit. An empty list
-- has a dashed edge, where files are dropped
command listLook
   local tField, tCount, tIndex, tLine
   put the long id of field "Files" of this card of me into tField
   put the number of lines of the text of tField into tCount
   set the itemDelimiter to tab
   repeat with tIndex = 1 to tCount
      put line tIndex of the text of tField into tLine
      if the last char of item -1 of tLine is slash then
         set the imageSource of char 1 of line tIndex of tField to the id of image "FolderIcon" of this card of me
      else
         set the imageSource of char 1 of line tIndex of tField to the id of image "FileIcon" of this card of me
      end if
      -- (colours of their own: a row chosen keeps them, on a light green)
      set the textColor of line tIndex of tField to "15,23,42"
      set the textColor of item 2 of line tIndex of tField to "100,116,139"
   end repeat
   set the itemDelimiter to comma
   set the vScrollbar of tField to the formattedHeight of tField > the height of tField
   if tCount is 0 then
      set the dashes of graphic "ListBox" of this card of me to "6,4"
      set the foregroundColor of graphic "ListBox" of this card of me to "148,163,184"
   else
      set the dashes of graphic "ListBox" of this card of me to empty
      set the foregroundColor of graphic "ListBox" of this card of me to "226,232,240"
   end if
end listLook

-- (remaster) The count in the header, at its right
command countShow pCount
   set the text of field "Count" of this card of me to pCount
end countShow

-- (remaster) The line under the buttons says what happened: pKind is "ok",
-- "problem" or "tip". With pLook, its button (on Make an Archive, Look
-- inside) shows too
command statusShow pKind, pText, pLook
   local tCard, tBack, tLine, tInk, tRect
   put the long id of this card of me into tCard
   switch pKind
      case "ok"
         put "240,253,244" into tBack
         put "187,247,208" into tLine
         put "21,128,61" into tInk
         break
      case "problem"
         put "254,242,242" into tBack
         put "254,202,202" into tLine
         put "185,28,28" into tInk
         break
      default
         put "248,250,252" into tBack
         put "226,232,240" into tLine
         put "71,85,105" into tInk
   end switch
   lock screen
   set the backgroundColor of graphic "StatusBox" of tCard to tBack
   set the foregroundColor of graphic "StatusBox" of tCard to tLine
   set the visible of image "StatusOk" of tCard to pKind is "ok"
   set the visible of image "StatusProblem" of tCard to pKind is "problem"
   set the visible of image "StatusTip" of tCard to pKind is not "ok" and pKind is not "problem"
   if there is a group "Look" of tCard then
      set the visible of group "Look" of tCard to pLook is true
   end if
   -- (the words end before the Look inside button, when it shows)
   put the rect of field "StatusText" of tCard into tRect
   if pLook is true then
      put the left of group "Look" of tCard - 8 into item 3 of tRect
   else
      put the right of graphic "StatusBox" of tCard - 12 into item 3 of tRect
   end if
   set the rect of field "StatusText" of tCard to tRect
   set the textColor of field "StatusText" of tCard to tInk
   set the text of field "StatusText" of tCard to pText
   -- (one line or two, in the middle of the box: smaller letters for more)
   set the textSize of field "StatusText" of tCard to 12
   if the formattedHeight of field "StatusText" of tCard > 44 then
      set the textSize of field "StatusText" of tCard to 11
   end if
   -- (4 more at the bottom keeps the last line's tails whole: the IDE's
   -- letters reach further down than the line's height says)
   set the height of field "StatusText" of tCard to the formattedHeight of field "StatusText" of tCard + 4
   set the loc of field "StatusText" of tCard to item 1 of the loc of field "StatusText" of tCard, item 2 of the loc of graphic "StatusBox" of tCard
   unlock screen
end statusShow
