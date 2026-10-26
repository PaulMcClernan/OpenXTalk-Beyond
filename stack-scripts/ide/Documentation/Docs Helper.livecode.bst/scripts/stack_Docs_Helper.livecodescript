script "stack_Docs_Helper"
-- Stack file: ide/Documentation/Docs Helper.livecode
-- Object: stack "Docs Helper"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
   dispatch "setAsBehavior" to revIDEFrameBehavior() with the long id of me
   
   ### Header
   addFrameItem "open","header", "action", "Open a text file", "folder open", "folder open","headerActionOpenFile", the long id of me
   
   send "resizeStack" to me
   
   start using stack "revDocsParser"
   
   put "No lcdoc file loaded" into field "loaded"
   set the backcolor of button "test" to empty
   put empty into field 1
   put empty into field 2
end preOpenStack

local sCurFile
on headerActionOpenFile
   answer file "Please select an lcdoc file" with type "LCDoc|lcdoc"
   
   if the result is "cancel" then exit headerActionOpenFile
   if there is not a file it then exit headerActionOpenFile
   
   put revIDEUTF8FileContents(it) into field "Text"
   put it into sCurFile
   put it into field "loaded"
   set the backcolor of button "Test" to empty
end headerActionOpenFile

on saveText
   if sCurFile is empty then
      exit saveText
   end if
   answer "Overwrite" && sCurFile & "?"
   if it is "OK" then
      revIDESetUTF8FileContents sCurFile, field "Text"
   end if
end saveText

private command addErrorList @xOutput, pName, pValue
   put "<ul>" after xOutput
   repeat for each element tElement in pValue
      put "<li>" & tElement & "</li>" after xOutput
   end repeat
   put "</ul>" after xOutput
end addErrorList

private command addError @xOutput, pName, pValue
   if xOutput is empty then
      put "<ul>" into xOutput
   end if
   
   put "<li>" & pName after xOutput
   
   if pValue["general"] is not empty then 
      put "- " & pValue["general"][1] after xOutput
   end if
   
   if pValue["array"] is not empty then
      local tOutput
      repeat for each key tName in pValue["array"]
         addErrorList xOutput, tName, pValue["array"][tName]
      end repeat
   end if
   
   put "</li><br>" & return after xOutput
end addError

on showErrors pArray
   local tOutput
   if pArray is empty then 
      set the backcolor of button "Test" to "green"
      put "No errors" into field "Corrections"
      exit showErrors
   end if
   
   set the backcolor of button "Test" to "red"
   
   repeat for each key tElName in pArray
      addError tOutput, tElName, pArray[tElName]
   end repeat
   set the htmltext of field "Corrections" to tOutput
end showErrors

on previewText pText
   
   -- find id : "(number)" before name: "(name)"
   -- on line x
   -- find id : "number + 1"
   -- on line y
   -- replace line x to line y-2 with bracket content
   
   local tLibraryA
   put revDocsParseDocTextToLibraryArray("", pText, "", "") into tLibraryA
   
   local tDoc, tName
   put tLibraryA["doc"][1] into tDoc
   put revDocsModifyForURL(tDoc["display name"]) into tName
   
   local tMatch
   put quote & "id" & quote & colon & quote & "([0-9]+)" & quote & comma into tMatch
   
   local tDataPath, tData
   put revIDESpecialFolderPath("documentation cache") & slash & "built_api.js" into tDataPath
   put revIDEUTF8FileContents(tDataPath) into tData
   
   local tIDLineNumber, tNextIDLineNumber, tCheckName, tMatchedName, tID, tNextID, tCount
   put false into tCheckName
   put false into tMatchedName
   put 0 into tCount
   repeat for each line tLine in tData
      add 1 to tCount
      if tCheckName then
         if  word 1 to -1 of tLine is \
               quote & "name" & quote & colon & quote & tName & quote & comma then
            put tNextID into tID
            put tNextIDLineNumber into tIDLineNumber
            put true into tMatchedName
         end if
         put false into tCheckName
      end if
      if matchText(word 1 to -1 of tLine, tMatch, tNextID) then
         put tCount into tNextIDLineNumber
         if tMatchedName then
            exit repeat
         else
            put true into tCheckName
         end if
      end if
   end repeat
   
   local tAPI
   put revDocsFormatLibraryDataAsJSON(tID, tDoc) into tAPI
   
   put line 2 to -2 of tAPI into line tIDLineNumber to tNextIDLineNumber - 2 of tData
   
   put revIDESpecialFolderPath("documentation cache") & slash & "preview_api.js" into tDataPath
   revIDESetUTF8FileContents tDataPath, tData
   
   local tGeneratedHTMLFile
   put revIDESpecialFolderPath("documentation cache") & slash & "preview.html" into tGeneratedHTMLFile
   
   local tLibraryName, tEntryName, tEntryType
   put "LiveCode Script" into tLibraryName
   put tDoc["display name"] into tEntryName
   put tDoc["type"] into tEntryType
   
   local tDocsBase
   put revIDESpecialFolderPath("documentation") & slash & "html_viewer" into tDocsBase
   
   local tDocsCSSFolder, tDocsJSFolder
   put tDocsBase & slash & "css" into tDocsCSSFolder
   put tDocsBase & slash & "js" into tDocsJSFolder
   
   local tIDEGuidesFolder, tRepoGuidesFolder
   put revIDESpecialFolderPath("ide guides") into tIDEGuidesFolder
   put revIDESpecialFolderPath("repo guides") into tRepoGuidesFolder
   
   local tTemplate
   try
      put revIDEUTF8FileContents(revIDEGetDictionaryHTMLTemplate("api")) into tTemplate
   catch tError
      put url ("https://raw.githubusercontent.com/livecode/livecode-ide/develop/Documentation/html_viewer/api.html.template") into tTemplate
   end try
   put merge(tTemplate) into tTemplate
   revIDESetUTF8FIleContents tGeneratedHTMLFile, tTemplate
   local tUrl
   put "file://" & tGeneratedHTMLFile into tUrl
   launch url tUrl
end previewText
