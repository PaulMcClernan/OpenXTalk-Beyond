script "stack_CustomScriptCol_button_id_1005"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > substack "CustomScriptCol" > card (id 1002) > group (id 1009) > button "update" (id 1005)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   set the name of me to "update"
   -- I still don't know how this works!
   -- Many thanks to Paul McClernan for this script.
   -- (way back when)
   set cursor to busy
   put the customProperties of stack "revpreferences" into tProps
   put displayArrayData(tProps,".") into tDatRtrn
   filter lines of tDatRtrn with"..*"
   replace (".."&tab) with "" in tDatRtrn
   sort lines of tDatRtrn ascending
   -- okay, now we have something usable! TEXT!!!!
   filter lines of tDatRtrn with "*cScriptEditor*"
   -- now we can whittle it down further
   put "" into field "importantBits"
   put "cScriptEditor,editor,font" & return &¬
   "cScriptEditor,editor,fontsize" & return &¬
   "cScriptEditor,editor,backgroundcolor" into myPropsToGather
   repeat the number of lines in myPropsToGather
      put line 1 of myPropsToGather into getThisProp
      delete line 1 of myPropsToGather
      put tDatRtrn into myImportantInfo
      filter myImportantInfo with "*" & getThisProp & "*"
      put line 1 of myImportantInfo into myImportantInfo
      replace "=> " with return in myImportantInfo
      put last line of myImportantInfo into myImportantInfo
      put myImportantInfo into line (the number of lines of field "importantBits" of stack "CustomScriptCol" +1) of field "importantBits" of stack "CustomScriptCol"
   end repeat
   local mySECols
   -- read custom colour scheme
   local sFilePath
   --
   if the platform contains "win" then
      put specialFolderPath(0x001a) & "/" & xtalk & "/Preferences/" into sFilePath
      create folder sFilePath
   end if
   if the platform contains "mac" then
      put specialFolderPath("Preferences") & "/" & xtalk & "/Preferences/" into sFilePath
      create folder sFilePath
   end if
   if the platform contains "lin" then
      put specialFolderPath("Home") & slash & ".runrev/" into sFilePath
      create folder sFilePath
      put specialFolderPath("Home") & slash & ".runrev/xtalk/" into sFilePath
      create folder sFilePath
      put specialFolderPath("Home") & slash & ".runrev/xtalk/Preferences" into sFilePath
      create folder sFilePath
   end if
   --
   local myTmpVar
   put sFilePath & "customScriptColours.dat" into myTmpVar 
   open file myTmpVar
   read from file myTmpVar until EOF
   put it into mySECols
   close file myTmpVar
   if the number of lines in mySECols <3 then
      -- use default properties
      put fld "defaultCustom" into mySECols
      -- write the file
      put sFilePath & "customScriptColours.dat" into myTmpVar 
      delete file myTmpVar
      open file myTmpVar
      write mySECols to file myTmpVar
      close file myTmpVar
      -- finished writing
      revIDESetPreference "cScriptEditor," & "colorization,scheme", "Custom"
      updateOpenScriptEditors
      send colourScript to button "update" of stack "CustomScriptCol"
   else
      -- defeated the null properties!
      local myKeep
      put line 1 to 3 of field "importantBits" of stack "CustomScriptCol" into myKeep
      put myKeep & return & mySECols into field "importantBits" of stack "CustomScriptCol"
   end if
   -- now do meaningful stuff!
   set the textfont of field "scriptPreview" to line 1 of field "importantBits" of stack "CustomScriptCol"
   set the textsize of field "scriptPreview" to line 2 of field "importantBits" of stack "CustomScriptCol"
   set the backgroundColor of field "scriptPreview" to line 3 of field "importantBits" of stack "CustomScriptCol"
   lock screen
   colourScript
   colourSEelements
   getSEBkgndCol
   unlock screen
   send clickMe(1) to field "iHateArrays" in 10 milliseconds
end mousedown

on getSEBkgndCol
   local pBkgndCol
   put revIDEGetPreference("cScriptEditor,editor,backgroundColor") into pBkgndCol
   put pBkgndCol into field "bkgndValue"
   set the backgroundColor of graphic "bkgndSwatch" to pBkgndCol
   set the backgroundColor of field "scriptPreview" to pBkgndCol
end getSEBkgndCol
on colourScript
   -- use revSEUtilities to colour the script
   local tEndChar
   put the num of chars of fld "scriptPreview" of this stack into tEndChar 
   dispatch "revSEColorizeField" to stack "revseutilities" with the long id of field "scriptPreview" of this stack, 1, tEndChar
   set the vScroll of field "scriptPreview" to 0
end colourScript

on colourSEelements
   -- colour each item in list based on property
   local mySECols,thisSECol,tCount,myTmpVar,myTmpData,sFilePath
   -- ugh, done
   if the platform contains "win" then
      put specialFolderPath(0x001a) & "/" & xtalk & "/Preferences/" into sFilePath
      create folder sFilePath
   end if
   if the platform contains "mac" then
      put specialFolderPath("Preferences") & "/" & xtalk & "/Preferences/" into sFilePath
      create folder sFilePath
   end if
   if the platform contains "lin" then
      put specialFolderPath("Home") & slash & ".runrev/" into sFilePath
      create folder sFilePath
      put specialFolderPath("Home") & slash & ".runrev/xtalk/" into sFilePath
      create folder sFilePath
      put specialFolderPath("Home") & slash & ".runrev/xtalk/Preferences" into sFilePath
      create folder sFilePath
   end if
   --
   put sFilePath & "customScriptColours.dat" into myTmpVar 
   open file myTmpVar
   read from file myTmpVar until EOF
   put it into mySECols
   close file myTmpVar
   if the number of lines in mySECols <3 then
      -- use default properties
      put fld "defaultCustom" into mySECols
      -- write the file
      put sFilePath & "customScriptColours.dat" into myTmpVar 
      delete file myTmpVar
      open file myTmpVar
      write mySECols to file myTmpVar
      close file myTmpVar
      -- finished writing
      revIDESetPreference "cScriptEditor," & "colorization,scheme", "Custom"
      updateOpenScriptEditors
      send colourScript to button "update" of stack "CustomScriptCol"
   else
      -- defeated the null properties!
      local myKeep
      put line 1 to 3 of field "importantBits" of stack "CustomScriptCol" into myKeep
      put myKeep & return & mySECols into field "importantBits" of stack "CustomScriptCol"
   end if
   
   filter mySECols without empty
   put 1 into tcount
   repeat the number of lines in mySECols
      set cursor to busy
      set the itemdelimiter to " "
      put last item of line 1 of mySECols into thisSECol
      delete line 1 of mySECols
      set the itemdelimiter to ","
      if isNumber(item 1 of thisSECol) then
         try
            set the textColor of line tCount of field "iHateArrays" to thisSECol
         catch e
            -- ignore error
         end try
      else
         -- wasn't number, skip
      end if
      add 1 to tCount
   end repeat
   set the vScroll of field "iHateArrays" to 0
end colourSEelements



function displayArrayData pArray, pIndent
   # create the variable that loops through the keys in the array
   local tKey
   if pArray is an array then
      # print information to indicate that we are entering a new nested level of the array
      get "Array" & return
      # print full stops that allow the reader to track the depth of an element
      put "." after pIndent
      # create the indentation
      put tab after pIndent
      repeat for each key tKey in pArray
         # call displayArrayData with a nested array
         put format("%s[%s] => %s\n", pIndent, tKey, displayArrayData (pArray[tKey], pIndent)) after it
      end repeat
      delete the last char of it
      return it
   else
      return pArray
   end if 
end displayArrayData
   
