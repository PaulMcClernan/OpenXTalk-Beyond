script "stack_ReleaseNotes"
-- Stack file: ide/Toolset/palettes/updates/ReleaseNotes.oxtstack
-- Object: stack "ReleaseNotes"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on openstack
   -- put wd in middle of screen
   lock screen
   set the itemdelimiter to ","
   put item 3 of the screenrect /2, (item 4 of the screenrect /2) -20 into tWdLoc
   set the loc of this stack to tWdLoc
   --
   if there is a stack "revMenubar" then
      if the top of this stack < the bottom of stack "revMenubar" then
         set the top of this stack to the bottom of stack "revMenubar" + 64
      end if
   end if
   set the cantmodify of this stack to true
   unlock screen
   put "loading..." into cd fld "notes" of this stack
   send tCompileUpdList to me in 20 ticks
end openstack


on tCompileUpdList
   put the defaultFolder into tOldDefaults
   put the effective filename of this stack into tWhereAmI
   replace "ReleaseNotes.oxtstack" with "" in tWhereAmI
   if not (the last char of tWhereAmI) is slash then put tWhereAmI & slash into tWhereAmI
   put tWhereAmI &"updatehistory" & slash into tCheckFolder
   if there is a folder tCheckFolder then
      lock screen
      set the defaultfolder to tCheckFolder
      put the files into tFileListings
      set the defaultfolder to tOldDefaults
      filter lines of tFileListings without ".*"
      filter lines of tFileListings without empty
      sort lines of tFileListings ascending -- newest at top
      put 0 into tCount
      put the number of lines in tFileListings into tTotalUpdateCounts
      set the thumbposition of scrollbar "loadprog" to 0
      set the endvalue of scrollbar "loadprog" to tTotalUpdateCounts
      show scrollbar "loadprog"
      unlock screen
      put "" into line 1 of cd fld "notes"
      lock screen
      put the number of lines in tFileListings into tRptCount
      repeat tRptCount
         add 1 to tcount
         if the last char of tRptCount is "0" then unlock screen
         if tRptCount is "1" then unlock screen
         set the thumbposition of scrollbar "loadprog" to tcount
         put line tcount of tFileListings into tShortFilename
         put tCheckFolder & tShortFilename into tLongFilename
         if not (there is a file tLongFilename) then
            -- ignore, can't read it
         else
            -- found file, read it
            open file tLongFilename
            read from file tLongFilename until EOF
            put it into tTempData
            close file tLongFilename
            put tTempData before line 1 of cd fld "notes"
            put " " & return before line 1 of cd fld "notes"
            set the textStyle of line 2 of cd fld "notes" to "bold,underline"
         end if
         if the lockScreen is false then lock screen
      end repeat
      if line 1 of cd fld "notes" is " " or line 1 of cd fld "notes" is empty then 
         delete line 1 of cd fld "notes"
      end if
      if last line of cd fld "notes" is " " or last line of cd fld "notes" is empty then 
         delete last line of cd fld "notes"
      end if
      set the vscroll of cd fld "notes" to 0
      send tDelayHideProg to me in 20 ticks
   else
      hide scrollbar "loadprog"
      close this stack
   end if
end tCompileUpdList

on tDelayHideProg
   if there is a scrollbar "loadprog" then hide scrollbar "loadprog"
end tDelayHideProg

on closestack
   put "" into cd fld "notes" of stack "ReleaseNotes"
   set the hilite of cd btn "Close" of stack "ReleaseNotes" to false
   hide scrollbar "loadprog"
end closestack
