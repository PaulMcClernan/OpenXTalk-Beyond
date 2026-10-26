script "stack_aboutstack"
-- Stack file: ide/Toolset/palettes/about.oxtstack
-- Object: stack "aboutstack"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preopenstack
   if the name of this stack contains "about" then
      go cd 1 of this stack
      set the icon of button "Icon" to "210112" -- gREVAppIcon (large app icon)
      
      -- load in the fork, build, and version text
      -- This is reading from the same place as the splash stack, so one place to change everything when it comes to modifying version
      set the itemDelimiter to "/"
      put item 1 to -3 of the filename of stack "home" & "/.version" into tFilePath
      put textDecode(url ("binfile:" & tFilePath), "utf-8") into tVersionNumber
      put line 1 of tVersionNumber into tVersionNumber
      put item 1 to -3 of the filename of stack "home" & "/.buildnumber" into tFilePath
      put textDecode(url ("binfile:" & tFilePath), "utf-8") into tBuildNumber
      put line 1 of tBuildNumber into tBuildNumber
      if not isNumber(last char of tVersionNumber) then delete last char of tVersionNumber -- strip CR line endings if present
      put item 1 to -3 of the filename of stack "home" & "/about.dat" into tFilePath
      put textDecode(url ("binfile:" & tFilePath), "utf-8") into tAboutText
      put tAboutText into tForkName
      put line 1 of tForkName into tForkName
      replace "%" with return in tForkName
      put line 1 of tForkName into tForkName
      replace "%" with return in tAboutText
      -- now loaded everything, fill out fields
      put tForkName & " " & tVersionNumber  into fld "forkfield"
      put "build: " & tBuildNumber into tBuildLine
      put item 1 to -3 of the filename of stack "home" & "/.codename" into tFilePath
      if there is a file tFilePath then
         put word 1 to -1 of line 1 of textDecode(url ("binfile:" & tFilePath), "utf-8") into tCodename
         if tCodename is not empty then put numToCodepoint(0x201C) & tCodename & numToCodepoint(0x201D) & " " & numToCodepoint(0x00B7) & " " before tBuildLine
      end if
      put tBuildLine into fld "buildfield"
      put "  engine: " & version() into fld "enginefield"
      -- id 205303
      set the imagesource of char 1 of line 1 of field "enginefield" to 205303
      delete line 1 of tAboutText
      put tAboutText into fld "tText"
      tSetLink -- make links
      
      -- put wd in middle of screen
      set the itemdelimiter to ","
      put item 3 of the screenrect /2, (item 4 of the screenrect /2) -20 into tAboutWdLoc
      set the loc of this stack to  tAboutWdLoc
      
      -- check  theming hasn't done weird stuff to the icon (mac / win)
      set the opaque of btn "icon"to false
      set the cantmodify of this stack to true
   end if
   pass preopenstack
end preopenstack


on tSetLink
   -- set colour of links
   put the cREVHelpHiliteColor of stack "revPreferences" into tNavLinkColour
   set the linkColor of this stack to tNavLinkColour
   set the linkVisitedColor of this stack to tNavLinkColour
   --
   put 0 into tIMCount
   repeat the number of lines of fld "tText"
      add 1 to tLNCount
      put 0 into tPrefixspaces
      if line tLNCount of fld "tText" contains "<ln>" then
         put line tLNCount of fld "tText" into tLNline
         if char 1 of tLNline is " " then
            repeat until char 1 of tLNline is not " "
               delete char 1 of tLNline
               add 1 to tPrefixspaces
            end repeat
         end if
         if the last char of tLNline is " " then
            repeat until the last char of tLNline is not " "
               delete last char of tLNline
            end repeat
         end if
         --
         -- set the link
         -- put tLNCount & return & tLNline -- debug
         replace "<ln>" with "" in line tLNCount of field "tText"
         replace "<ln>" with "" in tLNline
         put the number of chars in tLNline + tPrefixspaces into tToChars
         
         set the linkText of line tLNCount of field "tText" to tLNline
         set the TextStyle of char tPrefixspaces to tToChars of line tLNCount of field "tText" to "link"
      end if
   end repeat
end tSetLink


on closestack
   -- just makes sure this stack is removed from memory
   put the title of this stack into tStackTitle
   if tStackTitle contains "about" then
      set the destroyStack of this stack to true
      pass closestack
   end if
end closestack
