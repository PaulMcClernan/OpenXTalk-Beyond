script "stack_revSplash"
-- Stack file: ide/Toolset/palettes/splash/revSplash.livecode
-- Object: stack "revSplash"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preopencard
   -- dynamically change title to whatever is in file version file (tperry 26-11-23)
   -- just means it's reading from the same place as the about stack, so one place to change everything when it comes to modifying version
   
   set the itemDelimiter to "/"
   put item 1 to -3 of the filename of stack "home" & "/.version" into tFilePath
   put textDecode(url ("binfile:" & tFilePath), "utf-8") into tVersionNumber
   put line 1 of tVersionNumber into tVersionNumber
   if not isNumber(last char of tVersionNumber) then delete last char of tVersionNumber -- strip CR line endings if present
   put item 1 to -3 of the filename of stack "home" & "/about.dat" into tFilePath
   put textDecode(url ("binfile:" & tFilePath), "utf-8") into tForkName
   replace "%" with return in tForkName
   put line 1 of tForkName into tForkName
   put tForkName & " " & tVersionNumber  into tAboutInfoText
   put tAboutInfoText into cd fld "info"
end preopencard
