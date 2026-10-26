script "stack_Zip_Archives_card_id_1031"
-- Stack file: ide/Resources/Examples/Remastered/Zip Archives.oxtstack
-- Object: stack "Zip Archives" > card "Make an Archive" (id 1031)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- Make an Archive: the program of Zip Build
-- Demo. These handlers were its stack
-- script, and named its card "Main"; the
-- demo is this card now, and they name it
-- "me". What the remaster added is marked
-- (remaster).

on preOpenCard
   if not zipLoaded() then
      -- (remaster) say so at once if the zip library is not loaded here
      statusShow "problem", "The zip library, revZip, is not loaded here, so this card cannot make an archive."
   else if the text of field "Files" of me is empty then
      -- (remaster) an empty list, as the stack opens: nothing to count yet
      filesSummary
      statusShow "tip", "Add the files you want to pack, then make one zip of them all."
   end if
   pass preOpenCard
end preOpenCard

on archiveCreate pArchive, pFilelist
   -- It is useful to keep track of the contents of the result
   -- global property when using external library commands
   local tResult
   local tFile -- (remaster) declared, for strict compilation

   -- Check that the list of files to include is not empty
   -- (remaster: this check came after the archive was opened, and left
   -- it open; it comes first now. And "choosen" was a typo)
   if pFilelist is empty then
      answer "No files chosen!"
      statusShow "tip", "Add some files first: drop them on the list, or use Add files."
      exit archiveCreate
   end if

   -- Open the archive for write, this will fail if the
   -- archive already exists
   revZipOpenArchive pArchive, "write"
   put the result into tResult

   if tResult is not empty then
      -- The archive cannot be created.
      answer "Couldn't create archive, try another name"
      statusShow "problem", "Couldn't make" && nameFile(pArchive) & ":" && item 2 to -1 of tResult & ". Try another name."
      exit archiveCreate
   end if

   -- Loop through the files and add them to the archive.
   -- Note that the name of each file in the archive is the
   -- the last part of the file's name. This is returned by
   -- the nameFile() function, further down this script
   repeat for each line tFile in pFilelist
      revZipAddItemWithFile pArchive, nameFile(tFile), tFile
   end repeat

   -- Now close the archive. This will write the zip file
   -- to disk.
   revZipCloseArchive pArchive
   put the result into tResult

   -- As a lot of the work is done on closing the archive,
   -- it is worth checking the result at this stage to make
   -- sure no errors have ocurred.
   if tResult is not empty then
      answer "There was an error writing the archive, the zip library returned: " & tResult
      statusShow "problem", "The zip library could not write" && nameFile(pArchive) & ":" && item 2 to -1 of tResult & "."
      exit archiveCreate
   end if

   -- (remaster) say what was made
   archiveMade pArchive, pFilelist
end archiveCreate

function filesList
   local tFiles, tFormattedFiles
   local tLine, tPath -- (remaster) declared, for strict compilation

   -- Get the list of files that the user has dragged onto the field
   put the text of field "Files" of me into tFiles

   -- We are going to format the list of files, by going through them
   -- one by one and putting all the good ones into a new variable.
   -- In this case, all the lines that are files and exist are kept,
   -- folders and anything else are discarded.
   -- (remaster: a line of the list shows a file's name and size, and
   -- its path is the line's last item, after a tab, out of sight)
   set the itemDelimiter to tab
   repeat for each line tLine in tFiles
      put item -1 of tLine into tPath
      if there is a folder tPath then next repeat
      if there is a file tPath then put tPath & return after tFormattedFiles
   end repeat

   -- Remove the trailing return character
   delete the last char of tFormattedFiles

   -- Return the formatted list of files
   return tFormattedFiles
end filesList

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

-- (remaster) Adds files to the list, a line each: its name, its size, and
-- after them its path, out of sight. A file the list has already, or a
-- folder, is left out
command filesAdd pFiles
   local tFile, tNew, tCount
   set the itemDelimiter to tab
   put 0 into tCount
   repeat for each line tFile in pFiles
      -- (Linux can give a dropped file as a file:// address, whose
      -- special characters are %-coded; a + in it is a +)
      if tFile begins with "file://" then
         delete char 1 to 7 of tFile
         replace "+" with "%2B" in tFile
         put urlDecode(tFile) into tFile
      end if
      if tFile is empty or there is not a file tFile then next repeat
      if (tab & tFile & return) is in (the text of field "Files" of me & return & tNew) then next repeat
      put "  " & nameFit(nameFile(tFile), 150, the long id of field "Files" of me) & tab & sizeText(fileSize(tFile)) & tab & tFile & return after tNew
      add 1 to tCount
   end repeat
   delete the last char of tNew
   if tNew is empty then
      if the text of field "Files" of me is empty then labelShow
      exit filesAdd
   end if
   lock screen
   labelHide
   if the text of field "Files" of me is empty then
      put tNew into field "Files" of me
   else
      put return & tNew after field "Files" of me
   end if
   listLook
   filesSummary
   statusShow "tip", plural(the number of lines of the text of field "Files" of me, "file") && \
         "ready. Create archive packs them into one zip."
   unlock screen
end filesAdd

-- (remaster) How many files the list has, and their size all together
command filesSummary
   local tFiles, tFile, tTotal, tCount
   put filesList() into tFiles
   put 0 into tTotal
   put 0 into tCount
   repeat for each line tFile in tFiles
      add fileSize(tFile) to tTotal
      add 1 to tCount
   end repeat
   countShow tCount
   if tCount is 0 then
      set the text of field "ListSummary" of me to empty
   else
      set the text of field "ListSummary" of me to plural(tCount, "file") && numToCodepoint(183) && sizeText(tTotal)
   end if
   listLook
end filesSummary

-- (remaster) Says what was made. In a browser, a file the engine writes
-- in the downloads folder downloads; the zip library writes the archive
-- itself, so it is written again here, through the engine
command archiveMade pArchive, pFiles
   local tName, tCount
   -- (a long name is shortened: the words share the line with a button)
   put nameFit(nameFile(pArchive), 100, the long id of field "StatusText" of me) into tName
   put the number of lines of pFiles into tCount
   if the platform is "HTML5" then
      put url ("binfile:" & pArchive) into url ("binfile:" & pArchive)
      statusShow "ok", "Made" && tName & ": see your downloads.", true
   else
      statusShow "ok", "Made" && tName & ":" && plural(tCount, "file") & "," && sizeText(fileSize(pArchive)) & ".", true
   end if
   -- (Look inside shows it)
   set the cJustMade of card "Look Inside" of this stack to pArchive
end archiveMade
