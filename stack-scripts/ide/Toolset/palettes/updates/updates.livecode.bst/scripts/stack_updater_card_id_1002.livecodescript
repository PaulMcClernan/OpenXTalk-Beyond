script "stack_updater_card_id_1002"
-- Stack file: ide/Toolset/palettes/updates/updates.livecode
-- Object: stack "updater" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

-- updates stack, mostly rewritten (to try and keep it simple) - tperry 23-12-23
on opencard
   set the hideconsolewindows to true
   put "" into cd fld "status"
   -- before we do anything, check if we are on linux, and check curl status
   if the platform contains "lin" then
      put shell("dpkg -s " & "curl") into tTermOut
      if tTermOut contains "is not installed" then
         -- not installed
         put "Curl is not installed. Please install Curl via your package manager." into cd fld "status"
         exit opencard
      else
         -- is installed
         -- happy :)
      end if
   end if
   -- curl check on linux complete
   set the textsize of fld "status" of cd 1 of stack "updater" to "" -- reset text formatting
   -- get the version
   set the itemdelimiter to "/"
   put item 1 to -3 of the filename of stack "home" & "/.buildnumber" into tFilePath
   put textDecode(url ("binfile:" & tFilePath), "utf-8") into tBuildNumber
   put line 1 of tBuildNumber into tBuildNumber
   put line 1 of tBuildNumber into fld "tversfooter" of this card
   hide cd btn "redolast" of cd 1 of stack "updater"
   --
   -- set up an error watcher
   put "false" into tUpdError
   put "Checking for updates..." into cd fld "status"
   hide cd btn "whatschanged"
   -- clear text colour
   set the foregroundColor of cd fld "status" to ""
   -- set up default URL
   put "https://www.openxtalk.net/openxtalk-lite-updates/" into tBaseUrl -- I use tBaseUrl further down
   put tBaseUrl & "version_1_1.txt" into tUrl -- version 1 x update series
   /*
   -- not using insecure http mode (this was really only for MacOS 10.9)
   if the hilite of btn "insecure" of cd 1 of stack "updater" is true then
      replace "https://" with "http://" in tBaseURL -- drop back to using http mode (mainly for Mac OS X 10.9)
   end if
   */
   if the shiftkey is down then put tBaseUrl & "testing.txt" into tUrl -- uncomment to use testing branch
   put URL tUrl into myUpdateData
   if myUpdateData is "" then
      -- attempt with curl
      put QUOTE & tUrl & QUOTE into tCurlTmpCmd
      set hideconsolewindows to true
      get shell(tCurlTmpCmd)
      put it into myUpdateData
   end if
   put myUpdateData into cd fld "result"
   if cd fld "result" is "" then
      put "error. can't download update information" into tUpdError
      put tUpdError into cd fld "status"
      send tBtnInit to cd btn "tBtnDo" of this card
      show cd btn "insecure" of cd 1 of stack "updater"
      send hDismissOrShowUpd to this card in 1 millisecond -- should we close or show this stack?
      exit opencard
   end if
   -- read info from prefs as to current version
   if not (there is a fld "tPrefFootnote" of cd "Automatic Updates" of stack "revPreferencesGUI") then
      put "error. expected component not found" into tUpdError
      put tUpdError into cd fld "status"
      send tBtnInit to cd btn "tBtnDo" of this card
      send hDismissOrShowUpd to this card in 1 millisecond -- should we close or show this stack?
      exit opencard
   end if
   put fld "tPrefFootnote" of cd "Automatic Updates" of stack "revPreferencesGUI" into tVersInfo
   put the last word of line 1 of tVersInfo into tVers
   if not (isNumber(tVers)) then
      -- invalid version number
      put "error. current version number cannot be obtained" into tUpdError
      put tUpdError into cd fld "status"
      send tBtnInit to cd btn "tBtnDo" of this card
      send hDismissOrShowUpd to this card in 1 millisecond -- should we close or show this stack?
      exit opencard
   end if
   put line 2 of tVersInfo into tBuild
   -- check if we are retrying an update
   if the hilite of btn "redolast" of this card is true then
      put tBuild -1 into tBuild
      put tBuild into cd fld "tversfooter" of this card
      set the hilite of cd btn "redolast" to false
   end if
   if not (isNumber(tBuild)) then
      -- invalid build number
      put "error. current build number cannot be obtained" into tUpdError
      put tUpdError into cd fld "status"
      send tBtnInit to cd btn "tBtnDo" of this card
      send hDismissOrShowUpd to this card in 1 millisecond -- should we close or show this stack?
      exit opencard
   end if
   -- okay, we might have something 
   tLastChecked -- update last time checked
   -- filter down
   filter lines of cd fld "result" with (tVers & "*")
   filter lines of cd fld "result" without empty
   -- we should now be left with a list of anything useful to get
   if cd fld "result" is "" then
      -- invalid version number
      put "No updates available." into tUpdError
      put tUpdError into cd fld "status"
      send tBtnInit to cd btn "tBtnDo" of this card
      -- show cd btn "insecure" of cd 1 of stack "updater" -- shouldn't really support https updates these days
      put "Closing window in 5 seconds..." into line 2 of field "status"
      send closeUpdWindow to this card in 1 second
      exit opencard
   end if
   -- there's something there.
   hide cd btn "insecure" of cd 1 of stack "updater"
   put "Determining updates..." into cd fld "status"
   sort lines of cd fld "result" ascending numeric by word 2 of each
   -- strip out older updates that are not relevant
   put 0 into tcount
   repeat the number of lines in cd fld "result"
      add 1 to tcount
      -- the +1 on the next line is to look for anything higher than this current build and consider it
      if word 2 of line tcount of cd fld "result" < (tBuild +1) then
         delete line tcount of cd fld "result"
         subtract 1 from tcount
      end if
   end repeat
   if cd fld "result" is "" then
      -- nothing new found
      hide cd btn "insecure" of cd 1 of stack "updater"
      put "No updates available. You are already up to date." into tUpdError
      put tUpdError into cd fld "status"
      if tUpdError contains "already up to date" then
         put "Closing this window in 5 seconds..." into line 2 of cd fld "status"
         send tCountdownClose to btn "tBtnDo" in 1 second
      end if
      send tBtnInit to cd btn "tBtnDo" of this card
      hide cd btn "insecure" of cd 1 of stack "updater"
      show cd btn "redolast" of cd 1 of stack "updater"
      send hDismissOrShowUpd to this card in 1 millisecond -- should we close or show this stack?
      exit opencard
   end if
   -- we have an update pending
   put word 2 of line 1 of cd fld "result" into tNewBuild
   put word 1 of line 1 of cd fld "result" into tNewVers
   put tBaseUrl & "updatepackage/" & tNewBuild & "/" into tUrl -- this is the root of our update package
   -- lets reuse the result field
   put tUrl & "listing" into tUrl
   put URL tUrl into myUpdateData
   put myUpdateData into cd fld "result"
   if cd fld "result" is "" then
      put "error. update did not make sense" into tUpdError
      put tUpdError into cd fld "status"
      send tBtnInit to cd btn "tBtnDo" of this card
      show cd btn "insecure" of cd 1 of stack "updater"
      send hDismissOrShowUpd to this card in 1 millisecond -- should we close or show this stack?
      exit opencard
   end if
   -- update listing received and does make sense
   set the itemdelimiter to "/"
   put item 1 to -3 of the filename of stack "home" into tAppPath
   -- make sure we have a trailing slash at our root prog path
   /*
   if the platform contains "win" then
      put "\" into tFoldSep
   else
      put "/" into tFoldSep
   end if
   */
   put "/" into tFoldSep
   if not (the last char of tAppPath contains tFoldSep) then put tAppPath & tFoldSep into tAppPath
   replace "[**basepath**]/" with tAppPath in fld "result"
   -- so now we have our list of files and know where they need installing to
   -- we now need somewhere to temporarily download the files to...
   put "xtalk" into tXSubFolder
   if the platform contains "linux" then
      put specialFolderPath("Home") & "/." & tXSubFolder into tFolderSupport
   end if
   if the platform contains "mac" then
      put specialFolderPath("Preferences") & "/" & tXSubFolder into tFolderSupport
   end if
   if the platform contains "win" then
      --put specialFolderPath(0x001c) & "/" & tXSubFolder into tFolderSupport
      put specialFolderPath("Documents") & "/" & tXSubFolder into tFolderSupport
   end if
   create folder tFolderSupport
   
   put "/" & "updatecache" after tFolderSupport
   if there is not a folder tFolderSupport then create folder tFolderSupport
   if there is not a folder tFolderSupport then
      put "error. unable to create a place to store the updates" into tUpdError
      put tUpdError into cd fld "status"
      send tBtnInit to cd btn "tBtnDo" of this card
      if the cUpdateCheckSilent of stack "revPreferences" is true then close this stack -- we hit an error in silent mode, so close
      exit opencard
   end if
   if not (the last char of tFolderSupport contains tFoldSep) then put tFolderSupport & tFoldSep into tFolderSupport
   -- we now have somewhere to store our stuff
   -- write the update.log to file
   put cd fld "result" into tUpdLog
   put tFolderSupport & "update.log" into tLongFilename
   delete file tLongFilename -- make sure we clear out any stray files
   open file tLongFilename
   write tUpdLog to file tLongFilename
   close file tLongFilename
   --
   if not (there is a file tLongFilename) then
      put "error. unable to write to the temp folder" into tUpdError
      put tUpdError into cd fld "status"
      send tBtnInit to cd btn "tBtnDo" of this card
      send hDismissOrShowUpd to this card in 1 millisecond -- should we close or show this stack?
      exit opencard
   end if
   put tLongFilename into tUpdLogFile -- store a reference to our update.log
   --
   put tUpdLog into tFileCount
   filter lines of tFileCount with ("file: " & "*")
   if the number of lines of tFileCount <1 then
      put "error. no valid files specified in the update information" into tUpdError
      put tUpdError into cd fld "status"
      send tBtnInit to cd btn "tBtnDo" of this card
      show cd btn "insecure" of cd 1 of stack "updater"
      send hDismissOrShowUpd to this card in 1 millisecond -- should we close or show this stack?
      exit opencard
   end if
   --
   replace "file: " with "" in tFileCount
   put 0 into tcount
   -- set up progress bar
   set the thumbPosition of scrollbar "tProgBar" to 0
   set the endValue of scrollbar "tProgBar" to the number of lines of tFileCount
   show scrollbar "tProgBar"
   --
   set the itemdelimiter to "/"
   put "Preparing to download..." into cd fld "status"
   put the number of lines of tFileCount into tTotalDownloads
   repeat tTotalDownloads 
      add 1 to tcount
      put "Downloading file " & tcount & " of " & tTotalDownloads into cd fld "status"
      put line tcount of tFileCount into tFileToDownload
      if there is a file (tFolderSupport & tFileToDownload) then
         -- clear out old file if it exists
         delete file (tFolderSupport & tFileToDownload)
      end if
      -- 
      put (QUOTE & tFolderSupport & QUOTE) into tSaveAsFile 
      --
      put tURL into tDownloadURL
      if the last item of tDownloadURL contains "listing" then delete last item of tDownloadURL
      if not (the last char of tDownloadURL is "/") then put tDownloadURL & "/" into tDownloadURL
      put (QUOTE & tDownloadURL & tFileToDownload & QUOTE) into tDownloadURL
      --
      -- check to see if the file has any spaces
      put false into tRenamedDueToSpace
      if tDownloadURL contains "-SPACE-" then
         put true into tRenamedDueToSpace
      end if
      --
      -- this is now using curl
      if the platform contains "win" then 
         put "chdir" into tChFold
      else
         put "cd" into tChFold
      end if
      put tChFold & " " & QUOTE & tSaveAsFile & QUOTE & " && curl -O " & QUOTE & tDownloadURL & QUOTE into tDLCmd
      get shell(tDLCmd) -- built the download command above, this executes it
      --
      -- if we had to rename because of "-SPACE-", now put " " back in!
      if tRenamedDueToSpace is true then
         put (tFolderSupport & tFileToDownload) into tPercTwentyFile
         put tFileToDownload into tFileRenamedToDownload
         replace "-SPACE-" with " " in tFileRenamedToDownload
         put (tFolderSupport & tFileRenamedToDownload) into tNewFileNameWithPath
         --answer "rename:" & return & (tPercTwentyFile) & return & "to:" & return & tFileRenamedToDownload
         rename file (tPercTwentyFile) to (tNewFileNameWithPath)
         replace "-SPACE-" with " " in tFileToDownload
      end if
      --
      if there is a file (tFolderSupport & tFileToDownload) then
         -- download succeeded
         unlock screen
         set cursor to busy
         show scrollbar "tProgBar"
         set the left of scrollbar "tProgBar" to 10
         set the thumbPosition of scrollbar "tProgBar" to tcount -- increment progress bar
      else
         -- download did not work
         -- last resort - try rev method
         
         put ("libURLDownloadToFile " & tDownloadURL & ", " & QUOTE & tFolderSupport & tFileToDownload & QUOTE) into tCmd
         try
            set cursor to busy
            do tCmd
            set the thumbPosition of scrollbar "tProgBar" to tcount -- increment progress bar
         catch e
         end try
         /*
         if there is a file (QUOTE & tFolderSupport & tFileToDownload & QUOTE) then
            -- amazingly, we might have downloaded it!
         else
            put "error. could not download file '" & tFileToDownload & "'" into tUpdError
            put tUpdError & return & "(while trying to download from " & tDownloadURL & ")" into cd fld "status"
            send tBtnInit to cd btn "tBtnDo" of this card
            send hDismissOrShowUpd to this card in 1 millisecond -- should we close or show this stack?
            exit opencard
         end if
         */
      end if
   end repeat
   -- we now have a local copy of all our files to be updated (good!)
   put "" into tplural -- in the interest of good grammar!
   if tTotalDownloads >1 then put "s" into tplural
   if the cUpdateCheckSilent of stack "revPreferences" is true then
      put "There are updates available. The " & tTotalDownloads & " file" &  tplural & " have already been downloaded." into cd fld "status"
   else
      put tTotalDownloads & " download" & tplural & " complete" into cd fld "status"
   end if
   hide scrollbar "tProgBar"
   --
   
   -- we can't use terminal now, due to all the roadblocks that zsh and sip put in the way on MacOS.
   -- so can we do it from within the IDE (for all platforms)?
   put "checking for write access..." into line 2 of cd fld "status"
   put tAppPath & tFoldSep & "testwrite" into tTestFile
   open file tTestFile
   close file tTestFile
   if there is a file (tTestFile) then
      -- all good
      -- we have to mac allowances for modern MacOS (what a pain!)
      put tUpdLog into myManualMacCommands
      put 0 into macCount
      repeat the number of lines in myManualMacCommands
         add 1 to macCount
         put line macCount of myManualMacCommands into myFile
         if myFile is "" then
            -- skip
         else
            replace "file: " with "" in myFile
            add 1 to macCount
            put line macCount of myManualMacCommands into myDestFolder
            put "copying: " & myFile into line 2 of cd fld "status"
            delete file (myDestFolder & myFile) -- destructive!
            revCopyFile (tFolderSupport & myFile),myDestFolder
         end if
      end repeat
      delete file tTestFile -- clean up testwrite
      
      -- update version and build numbers
      --
      put tAppPath & ".buildnumber" into myFile
      delete file myFile
      open file myFile
      write tNewBuild to file myFile
      close file myFile
      --
      put tAppPath & ".version" into myFile
      delete file myFile
      open file myFile
      write tNewVers to file myFile
      close file myFile
      
      --delete file tUpdLogFile -- don't clean up update log
      put "Updates applied." into line 2 of cd fld "status"
      set the label of btn "tBtnDo" of stack "updater" to "Relaunch"
      show this stack -- because we found something that needs the user's attention
      set the tLogData of this card to tUpdLogFile -- set the update log file as a custom property
      show btn "whatschanged"
      exit opencard
   else
      -- update version and build numbers
      --
      put tAppPath & ".buildnumber" into myFile
      delete file myFile
      open file myFile
      write tNewBuild to file myFile
      close file myFile
      --
      put tAppPath & ".version" into myFile
      delete file myFile
      open file myFile
      write tNewVers to file myFile
      close file myFile
      
      answer "Can't copy the files where they need to be. I can show you where they go though!"
      if the platform contains "mac" then get shell("open '" & tFolderSupport & "'")
      if the platform contains "win" then get shell("explorer '" & tFolderSupport & "'")
      if the platform contains "lin" then get shell("xdg-open '" & tFolderSupport & "'")
   end if
   -- hopefully, we managed to copy things using the old revCopyFile method!
   show this stack -- because we found something that needs the user's attention
   set the tLogData of this card to tUpdLogFile -- set the update log file as a custom property
   send tBtnInit to cd btn "tBtnDo" of this card
end opencard

on tLastChecked
   put the seconds into tTheSecondsNow
   set the tAutoUpdatesLastChecked of stack "revPreferences" to tTheSecondsNow -- store that we've checked for updates now, in the prefs
   -- human readable version (write this back to prefs window)
   convert tTheSecondsNow to dateitems
   if item 5 of tTheSecondsNow <10 then put "0" & item 5 of tTheSecondsNow into item 5 of tTheSecondsNow -- make sure mins have a 0 prefix if needed
   put item 4 of tTheSecondsNow & ":" & item 5 of tTheSecondsNow & ",  " & item 3 of  tTheSecondsNow & "/" &  item 2 of  tTheSecondsNow & "/" &  item 1 of  tTheSecondsNow into tHumanReadableDate
   put "Last checked for updates:" & return & tHumanReadableDate into fld "tlastchecked" of cd "Automatic Updates" of stack "revPreferencesGUI"
end tLastChecked


on hDismissOrShowUpd
   -- should we show the error or dismiss silently in the background
   if the cUpdateCheckSilent of stack "revPreferences" is true then
      close this stack -- we hit an error in silent mode, so close
   else
      show this stack
   end if
end hDismissOrShowUpd

on closeUpdWindow
   put word 4 of line 2 of field "status" into myCountDownClose
   if isNumber(myCountDownClose) then
      subtract 1 from myCountDownClose
      if myCountDownClose > 1 then
         put myCountDownClose into word 4 of line 2 of field "status"
         send closeUpdWindow to this card in 1 second
      end if
      if myCountDownClose is "1" then
         put myCountDownClose into word 4 of line 2 of field "status"
         put "second..." into word 5 of line 2 of field "status"
         send closeUpdWindow to this card in 1 second
      end if
      if myCountDownClose is "0" then
         if the shiftkey is up then close this wd
      end if
   end if
end closeUpdWindow
