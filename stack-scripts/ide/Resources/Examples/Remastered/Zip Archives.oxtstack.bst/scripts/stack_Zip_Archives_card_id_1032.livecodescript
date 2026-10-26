script "stack_Zip_Archives_card_id_1032"
-- Stack file: ide/Resources/Examples/Remastered/Zip Archives.oxtstack
-- Object: stack "Zip Archives" > card "Look Inside" (id 1032)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- Look Inside: the program of Zip Extract
-- Demo. These handlers were its stack
-- script, and named its card "Main"; the
-- demo is this card now, and they name it
-- "me". What the remaster added is marked
-- (remaster).

-- (remaster) The archive shown, and each of
-- its items' details, by name
local sArchive, sDetails

on preOpenCard
   local tArchive
   if not zipLoaded() then
      -- (remaster) say so at once if the zip library is not loaded here
      statusShow "problem", "The zip library, revZip, is not loaded here, so this card cannot open an archive."
   else if the cJustMade of me is not empty then
      -- (remaster) the archive Make an Archive has just made
      put the cJustMade of me into tArchive
      set the cJustMade of me to empty
      labelHide
      archiveShow tArchive
   else if sArchive is empty then
      -- (remaster) no archive shown, as the stack opens
      archiveForget
      statusShow "tip", "Select the items to take out, or none to take them all."
   else
      -- (remaster) the items selected are let go when the card closes:
      -- the line under the list says so again
      itemDetails
   end if
   pass preOpenCard
end preOpenCard

function archiveReturnContents pArchive
   local tResult, tItems
   if there is no file pArchive then return empty

   -- We need to open the archive first before
   -- we do anything. The archive only needs to be opened
   -- for reading, as we are not going to change it.
   revZipOpenArchive pArchive, "read"
   put the result into tResult

   -- Check the archive has opened correctly
   if tResult is not empty then
      answer "Error opening archive. The zip library answered: " & tResult
      return empty
   end if

   put revZipEnumerateItems(pArchive) into tItems
   return tItems

end archiveReturnContents

-- Given an absolute folder path, returns the name of the folder
function nameFolder pPath
   set the itemDelimiter to slash
   return item -1 of pPath
end nameFolder

-- Given an absoute file path, returns the name of the file
function nameFile pPath
   set the itemDelimiter to slash
   return item -1 of pPath
end nameFile

-- Shows the instruction label with a simple visual effect.
-- This could easily be changed to use one of Revolution's
-- build in visual effects, including quicktime or a MacOS X
-- core image effect.
on labelShow
   local x -- (remaster) declared, for strict compilation
   if the blendLevel of field "Label" of me is 0 then
      exit labelShow
   end if
   repeat with x=100 down to 0 step -2
      set the blendLevel of field "Label" of me to x
   end repeat
end labelShow

-- Hides the instruction label.
on labelHide
   local x -- (remaster) declared, for strict compilation
   if the blendLevel of field "Label" of me is 100 then
      exit labelHide
   end if
   repeat with x=0 to 100 step 2
      set the blendLevel of field "Label" of me to x
   end repeat
end labelHide

-- (remaster) Shows what an archive holds: a line for each item, its name,
-- its size, and after them its name again, out of sight. The archive is
-- open after archiveReturnContents (the demo left it so), so each item's
-- details are read here, and then it is closed
command archiveShow pArchive
   local tItems, tItem, tInfo, tLines, tTotal, tSize, tCount
   put empty into sDetails
   put archiveReturnContents(pArchive) into tItems
   if tItems is empty then
      archiveForget
      if there is not a file pArchive then
         statusShow "problem", "There is no file" && nameFile(pArchive) & "."
      else if pArchive is among the lines of revZipOpenArchives() then
         revZipCloseArchive pArchive
         statusShow "tip", nameFile(pArchive) && "is empty: it holds no files."
      else
         statusShow "problem", nameFile(pArchive) && "is not a zip archive this library can read."
      end if
      labelShow
      exit archiveShow
   end if
   put 0 into tTotal
   put 0 into tCount
   repeat for each line tItem in tItems
      if tItem is empty then next repeat
      -- index, crc, size, time, packed size and method
      put revZipDescribeItem(pArchive, tItem) into tInfo
      put tInfo into sDetails[tItem]
      add item 3 of tInfo to tTotal
      if the last char of tItem is slash then
         put "  " & nameFit(tItem, 150, the long id of field "Files" of me) & tab & tab & tab & tItem & return after tLines
      else
         add 1 to tCount
         put "  " & nameFit(tItem, 150, the long id of field "Files" of me) & tab & sizeText(item 3 of tInfo) & tab & tab & tItem & return after tLines
      end if
   end repeat
   revZipCloseArchive pArchive
   delete the last char of tLines
   put pArchive into sArchive
   lock screen
   put tLines into field "Files" of me
   set the vScroll of field "Files" of me to 0
   listLook
   countShow tCount
   set the text of field "ArchiveName" of me to nameFit(toUpper(nameFile(pArchive)), 170, the long id of field "ArchiveName" of me)
   set the text of field "ArchiveSummary" of me to plural(tCount, "file") && numToCodepoint(183) && sizeText(tTotal)
   itemDetails
   put fileSize(pArchive) into tSize
   if tSize > 0 and tSize < tTotal then
      statusShow "ok", "Opened" && nameFile(pArchive) & ":" && sizeText(tTotal) && "of files, packed into" && sizeText(tSize) & "."
   else
      statusShow "ok", "Opened" && nameFile(pArchive) & ":" && plural(tCount, "file") & "," && sizeText(tTotal) & "."
   end if
   unlock screen
end archiveShow

-- (remaster) Forgets the archive shown
command archiveForget
   put empty into sArchive
   put empty into sDetails
   put empty into field "Files" of me
   listLook
   countShow 0
   set the text of field "ArchiveName" of me to "NO ARCHIVE OPEN"
   set the text of field "ArchiveSummary" of me to empty
   set the text of field "Details" of me to empty
end archiveForget

-- (remaster) The archive shown, for the buttons
function archiveShown
   return sArchive
end archiveShown

-- (remaster) The names of the items chosen in the list, or of them all if
-- none is chosen
function itemsChosen
   local tLines, tLine, tText, tItem, tName, tSeen, tOut
   set the caseSensitive to true
   put the text of field "Files" of me into tText
   put the hilitedLines of field "Files" of me into tLines
   if tLines is empty then
      repeat with tLine = 1 to the number of lines of tText
         put tLine & comma after tLines
      end repeat
   end if
   repeat for each item tLine in tLines
      set the itemDelimiter to tab
      put item -1 of line tLine of tText into tItem
      set the itemDelimiter to comma
      if tItem is empty or tSeen[tItem] is true then next repeat
      put true into tSeen[tItem]
      put tItem & return after tOut
      -- a folder chosen brings out what is in it too
      if the last char of tItem is slash then
         repeat for each key tName in sDetails
            if char 1 to (the number of chars of tItem) of tName is tItem and tSeen[tName] is not true then
               put true into tSeen[tName]
               put tName & return after tOut
            end if
         end repeat
      end if
   end repeat
   delete the last char of tOut
   return tOut
end itemsChosen

-- (remaster) Says what the item chosen is: its size, how small the zip
-- made it, and its date
command itemDetails
   local tLines, tItem, tInfo, tText, tDate
   put the hilitedLines of field "Files" of me into tLines
   if sArchive is empty then
      put empty into tText
   else if tLines is empty then
      put "Nothing selected: Take files out takes them all." into tText
   else if the number of items of tLines > 1 then
      put the number of items of tLines && "items selected." into tText
   else
      set the itemDelimiter to tab
      put item -1 of line (item 1 of tLines) of the text of field "Files" of me into tItem
      set the itemDelimiter to comma
      put sDetails[tItem] into tInfo
      put item 4 of tInfo into tDate
      convert tDate from seconds to dateItems
      if the last char of tItem is slash then
         put "A folder: what is in it comes out with it." into tText
      else
         if item 6 of tInfo is "deflate" then
            put sizeText(item 3 of tInfo) & ", packed into" && sizeText(item 5 of tInfo) into tText
         else
            put sizeText(item 3 of tInfo) & ", stored as it is" into tText
         end if
         put "  " & numToCodepoint(183) & "  " & item 3 of tDate && line (item 2 of tDate) of the abbreviated monthNames && \
               item 1 of tDate & "," && format("%02d:%02d", item 4 of tDate, item 5 of tDate) after tText
      end if
   end if
   set the text of field "Details" of me to tText
end itemDetails

-- (remaster) Takes items out of an archive, into a new folder in pFolder
-- named after the archive. An item whose name would put it outside that
-- folder stays in (see itemSafe). In a browser, each file goes to the
-- downloads folder, and so downloads
command archiveExtract pArchive, pItems, pFolder
   local tResult, tTarget, tItem, tFile, tData, tCount, tFolders, tLeft, tFailed
   if the platform is "HTML5" then
      put pFolder into tTarget
   else
      put folderNew(pFolder, nameFile(pArchive)) into tTarget
      if tTarget is empty then
         statusShow "problem", "Couldn't make a folder for the files in" && nameFolder(pFolder) & "."
         exit archiveExtract
      end if
   end if
   revZipOpenArchive pArchive, "read"
   put the result into tResult
   if tResult is not empty then
      statusShow "problem", "Couldn't open" && nameFile(pArchive) & ":" && item 2 to -1 of tResult & "."
      exit archiveExtract
   end if
   put 0 into tCount
   put 0 into tFolders
   put 0 into tLeft
   put 0 into tFailed
   repeat for each line tItem in pItems
      if tItem is empty then next repeat
      if not itemSafe(tItem) then
         add 1 to tLeft
         next repeat
      end if
      if the last char of tItem is slash then
         if the platform is not "HTML5" then
            folderMake tTarget & slash & char 1 to -2 of tItem
            add 1 to tFolders
         end if
         next repeat
      end if
      if the platform is "HTML5" then
         revZipExtractItemToVariable pArchive, tItem, "tData"
         if the result is empty then
            put tData into url ("binfile:" & tTarget & slash & nameFile(tItem))
         end if
      else
         put tTarget & slash & tItem into tFile
         set the itemDelimiter to slash
         folderMake item 1 to -2 of tFile
         set the itemDelimiter to comma
         revZipExtractItemToFile pArchive, tItem, tFile
      end if
      if the result is empty then
         add 1 to tCount
      else
         add 1 to tFailed
      end if
   end repeat
   revZipCloseArchive pArchive
   if tCount is 0 and tFolders is 0 then
      -- nothing came out: the new folder goes again (it is empty)
      if the platform is not "HTML5" then delete folder tTarget
      put "Nothing came out of" && nameFile(pArchive) & "." into tResult
   else if tCount is 0 then
      put "Took" && plural(tFolders, "empty folder") && "out, into the folder" && nameFolder(tTarget) & "." into tResult
   else if the platform is "HTML5" then
      put "Took" && plural(tCount, "file") && "out: see your downloads." into tResult
   else
      put "Took" && plural(tCount, "file") && "out, into the folder" && nameFolder(tTarget) & "." into tResult
   end if
   if tLeft is 1 then
      put " 1 stayed in: its name leads out of the folder." after tResult
   else if tLeft > 1 then
      put space & tLeft && "stayed in: their names lead out of the folder." after tResult
   end if
   if tFailed > 0 then
      put space & plural(tFailed, "item") && "could not be taken out." after tResult
   end if
   if tCount is 0 and tFolders is 0 then
      statusShow "problem", tResult
   else
      statusShow "ok", tResult
   end if
end archiveExtract

-- (remaster) Makes a new folder in pFolder for an archive's files: the
-- archive's name without .zip, and a number after it if that is taken.
-- Empty if it cannot be made
function folderNew pFolder, pName
   local tName, tPath, tNumber
   put pName into tName
   if char -4 to -1 of tName is ".zip" then delete char -4 to -1 of tName
   if tName is empty then put "Archive" into tName
   put pFolder & slash & tName into tPath
   put 1 into tNumber
   repeat while there is a folder tPath or there is a file tPath
      add 1 to tNumber
      put pFolder & slash & tName && tNumber into tPath
   end repeat
   create folder tPath
   if there is not a folder tPath then return empty
   return tPath
end folderNew

-- (remaster) Makes a folder, and the folders it is in, if they are not
-- there yet
command folderMake pPath
   local tIndex, tPath
   set the itemDelimiter to slash
   repeat with tIndex = 1 to the number of items of pPath
      put item 1 to tIndex of pPath into tPath
      if tPath is empty or there is a folder tPath then next repeat
      create folder tPath
   end repeat
end folderMake

-- (remaster) False for an item whose name would put it outside the folder
-- it is taken out into: one that begins with a slash, or climbs out with ..
-- (Windows reads a backslash in a path as a slash)
function itemSafe pItem
   local tPart
   replace backslash with slash in pItem
   if char 1 of pItem is slash then return false
   set the itemDelimiter to slash
   repeat for each item tPart in pItem
      if tPart is ".." then return false
   end repeat
   return true
end itemSafe
