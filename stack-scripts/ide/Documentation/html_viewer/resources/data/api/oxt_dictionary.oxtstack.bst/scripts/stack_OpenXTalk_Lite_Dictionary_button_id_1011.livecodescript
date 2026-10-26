script "stack_OpenXTalk_Lite_Dictionary_button_id_1011"
-- Stack file: ide/Documentation/html_viewer/resources/data/api/oxt_dictionary.oxtstack
-- Object: stack "OpenXTalk Lite Dictionary" > card (id 1002) > button "load random" (id 1011)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   lock screen
   send tCloseSearches to this card
   put the long name of this stack into tPath
   if word 1 of tPath is "stack" then delete word 1 of tPath
   replace QUOTE with "" in tPath
   set the itemdelimiter to slash
   delete last item of tPath
   -- conditional part of path, based on what dictionary syntax we select
   if the hilite of cd btn "langxtalk" is true then put "xtalk" into tDef
   if the hilite of cd btn "langbuilder" is true then put "builder" into tDef
   if the hilite of cd btn "langdatagrid" is true then put "datagrid" into tDef
   put tPath & slash & "exports" & slash & tDef & slash & "resaved" & slash into tfilename
   --
   put the DICT_xTalk of fld "tEntries" into tFileList
   filter lines of tFileList without empty
   put the number of lines in tFileList into tDictCount
   put random(tDictCount) into tLine
   put line tLine of tFileList into tShortFilename
   put tfilename & tShortFilename into tfilename
   put tfilename into cd fld "path"
   --
   if there is a file tfilename then
      open file tfilename for "UTF-8" text read -- OXT-Beyond: the install may be read-only, and the entries are UTF-8 (load random)
      read from file tfilename until EOF
      put it into tData
      close file tfilename
      put tData into cd fld "thetext" -- so now we have the data in our card... now comes the formatting
      tFormatEntry
   end if
   unlock screen
end mousedown


on tFormatEntry
   set cursor to busy
   -- style search button
   put the ID of image "watch-off.png" of cd 1 of stack "revIcons" into tImageSourceID
   set the icon of btn "searchBtn" to tImageSourceID
   -- formats the text to look nice for this dictionary entry
   put "thetext" into tFldName -- unstyled field
   put "styledTextField" into tSFldName -- styled field
   if not(there is a field tSFldName of this card) then
      create field tSFldName in this card
      set the vScrollbar of fld tSFldName of this card to true
   end if
   put line 1 of field tFldName into cd fld "searchFld"
   --
   -- I make some assumptions here about formatting.
   -- (this may prove to be right or wrong!)
   put "" into cd fld tSFldName
   put line 1 of cd fld tFldName into tTitle -- the entry we are viewing
   -- start of the function and the icon
   put line 2 of cd fld tFldName into tType -- the type of the dictionary entry
   put "revIcons" into tIconSourceStack -- where we are pulling the icons from
   put "  " & tType into  line 2 of cd fld tSFldName
   if tType is "(command)" then put the ID of image "Command-Icon" of cd 1 of this stack into tImageSourceID
   if tType is "(constant)" then put the ID of image "Constant-Icon" of cd 1 of this stack into tImageSourceID
   if tType is "(control)" then put the ID of image "Graphic-Icon" of cd 1 of this stack into tImageSourceID
   if tType is "(expression)" then put the ID of image "Text-Icon" of cd 1 of this stack into tImageSourceID
   if tType is "(function)" then put the ID of image "Function-Icon" of cd 1 of this stack into tImageSourceID
   if tType is "(glossary)" then put the ID of image "General-icon" of cd 1 of this stack into tImageSourceID
   if tType is "(handler)" then put the ID of image "handler.png" of cd 1 of this stack into tImageSourceID
   if tType is "(iterator)" then put the ID of image "down-on.png" of cd 1 of this stack into tImageSourceID
   if tType is "(keyword)" then put the ID of image "Keyword-Icon" of cd 1 of this stack into tImageSourceID
   if tType is "(library)" then put the ID of image "Share-stack" of cd 1 of this stack into tImageSourceID
   if tType is "(message)" then put the ID of image "Messages-Icon" of cd 1 of this stack into tImageSourceID
   if tType is "(object)" then put the ID of image "Object-Icon" of cd 1 of this stack into tImageSourceID
   if tType is "(operator)" then put the ID of image "Operator-Icon" of cd 1 of this stack into tImageSourceID
   if tType is "(property)" then put the ID of image "global-properties.png" of cd 1 of this stack into tImageSourceID
   if tType is "(statement)" then put the ID of image "next-statement-on.png" of cd 1 of this stack into tImageSourceID
   if tType is "(type)" then put the ID of image "Plugin-icon" of cd 1 of this stack into tImageSourceID
   if tType is "(control structure)" then put the ID of image "Graphic-icon" of cd 1 of this stack into tImageSourceID
   set the imagesource of char 1 of line 2 of field tSFldName to tImageSourceID
   -- end of the function and the icon
   -- start of title size
   put tTitle into line 1 of fld tSFldName
   set the textSize of line 1 of fld tSFldName to 18
   set the textStyle of line 1 of fld tSFldName to bold
   -- end of title size
   -- now for the dynamic bits
   -- start of synopsis
   put 3 into tCount
   repeat until the number of words of line tCount of fld tFldName is 1
      add 1 to tcount
   end repeat
   put tcount into tLine
   put line 3 to tLine of fld tFldName into tSynopsis
   if the last line of tSynopsis contains ":" then delete last line of tSynopsis
   filter lines of tSynopsis without empty
   if tSynopsis  is not "" then put tSynopsis into line 4 of fld tSFldName
   put 4 into tSynStart
   put 4 + the number of lines in tSynopsis into tSynEnd -- keep track of how many lines synopsis takes up
   -- end synopsis
   -- start PARAMS listing
   put line tLine to (the number of lines in fld tFldName) of fld tFldName into tDoParams
   if tDoParams contains return & "Params:" & return then
      repeat the number of lines of tDoParams
         if line 1 of tDoParams contains "Params:" then 
            exit repeat
         else
            delete line 1 of tDoParams
         end if
      end repeat
      put 2 into myCount
      repeat the number of lines of tDoParams
         add 1 to myCount
         if the last char of line myCount of tDoParams is ":" then
            -- we reached the end of the params chunk
            exit repeat
         end if
      end repeat
      delete line myCount to the number of lines of tDoParams of tDoParams
   end if
   -- end PARAMS listing
   
   -- start an example listing if there's one available
   put line tLine to (the number of lines in fld tFldName) of fld tFldName into tDoExample
   put 0 into xCount
   put false into tIsFound
   put 0 into tExampleFromLine
   repeat the number of lines of tDoExample
      add 1 to xCount
      if word 1 of line xCount of tDoExample contains "Example" then 
         if tIsFound is false then
            put true into tIsFound
            put (xCount + tLine) into tExampleFromLine
         end if
      end if
      if tIsFound is true then
         -- now looking for end of example chunk
         if word 1 of line xCount +1 of tDoExample contains ":" then
            -- we reached the end of the chunk
            put (xCount+1 + tLine) into tExampleToLine
            exit repeat
         end if
      end if
   end repeat
   
   -- now we put it all together
   
   -- this adds the "Params:" part
   if the number of lines in tDoParams >1 then
      put the number of lines in fld tSFldName into tCurLine
      put tDoParams into line tCurLine of fld tSFldName -- params added
      /*
      put line 1 to tCurLine of fld tSFldName into tCharCalcA
      put the number of chars in tCharCalcA +1 into tCharCalcA
      put tCharCalcA + the number of chars in tDoParams into tCharCalcB
      dispatch "revSEColorizeField" to stack "revseutilities" with the long id of field "styledTextField", tCharCalcA, tCharCalcB
      */
      set the textStyle of line tCurLine of fld tSFldName to bold
   end if
   
   
   -- now we do examples
   if word 1 of line tExampleFromLine of fld tFldName contains ":" then
      put the number of lines in fld tSFldName +2 into tCurLine
      put "Example usage:" & return & "none" into line tCurLine of fld tSFldName -- no example code given
   else
      put the number of lines in fld tSFldName +2 into tCurLine
      put line tExampleFromLine to tExampleToLine -2 of fld tFldName into tExampleScript
      filter lines of tExampleScript without empty
      filter lines of tExampleScript without "---*"
      --
      put "Example usage:" & return & tExampleScript into line tCurLine of fld tSFldName -- we have example code
      put line 1 to tCurLine of fld tSFldName into tCharCalcA
      put the number of chars in tCharCalcA +1 into tCharCalcA
      put tCharCalcA + the number of chars in tExampleScript into tCharCalcB
      dispatch "revSEColorizeField" to stack "revseutilities" with the long id of field "styledTextField", tCharCalcA, tCharCalcB
   end if
   -- end example section
   -- start values section
   if fld tFldName contains ("Values:" & return) then
      put lineOffset("Values:" & return,fld tFldName) into tVALine
      if isNumber(tVALine) then
         put line (tVALine +1) of fld tFldName into tValueString
         if tValueString is not "" then
            put the number of lines of fld tSFldName into tVALine
            put "Values: " & return & tValueString into line tVALine +2 of fld tSFldName
            set the textColor of line tVALine+2 of fld tSFldName to "" -- apply no colours
            set the textColor of line tVALine+3 of fld tSFldName to "" -- apply no colours
            set the textStyle of line tVALine+2 of fld tSFldName to bold -- apply bold style the values header line
            set the textStyle of line tVALine+3 of fld tSFldName to plain -- apply plain style to the value text
         end if
      else
         -- dont put value information
      end if
      -- does not contains "Values:" section
   end if
   -- end valuessection
   -- start description section
   put the number of lines in fld tSFldName +2 into tDescriptionLine
   put "Description:" into line tDescriptionLine of fld tSFldName
   if the last line of fld tSFldName is "" then delete last line of fld tSFldName
   set the textColor of line tCurLine of fld tSFldName to "" -- go back and apply no colours the example usage line
   set the textStyle of line tCurLine of fld tSFldName to bold -- go back and bold the example usage line
   set the textColor of line tDescriptionLine of fld tSFldName to "" -- apply no colours the description line
   set the textStyle of line tDescriptionLine of fld tSFldName to plain -- apply no style the description line
   put fld tFldName into tDescrText
   put 0 into xCount
   repeat the number of lines of tDescrText
      add 1 to xCount
      if word 1 of line xCount of tDescrText contains "Description:" then
         delete line 1 to xCount of  tDescrText
         put 0 into xCount
         repeat the number of lines of tDescrText
            add 1 to xCount
            if word 1 of line xCount of tDescrText contains ":" then
               delete line xCount to (the number of lines of tDescrText) of tDescrText
            end if
         end repeat
         exit repeat
      end if
   end repeat
   if line 1 of tDescrText is empty then delete line 1 of tDescrText
   put tDescrText into line (the number of lines in fld tSFldName +1) of fld tSFldName -- put the description text chunk in
   set the textStyle of line tDescriptionLine of fld tSFldName to bold -- apply bold style the description header
   set the textColor of line tDescriptionLine to (the number of lines in fld tSFldName) of fld tSFldName to ""
   --
   get tSetLink(tSFldName)
   
   -- end description section
   -- start OS section
   if fld tFldName contains ("OS:" & return) then
      put lineOffset("OS:" & return,fld tFldName) into tOSLine
      if isNumber(tOSLine) then
         put line (tOSLine +1) of fld tFldName into tOSSupport
         put the number of lines of fld tSFldName into tOSLine
         put "Operating system support: " & return & tOSSupport into line tOSLine +2 of fld tSFldName
         set the textStyle of line tOSLine+2 of fld tSFldName to bold -- apply bold style the OS support line
      else
         -- dont put OS information
      end if
      -- does not contains "OS:" section
   end if
   -- end OS section
   
   -- now we sort out links
   --tTidyField
end tFormatEntry

function tSetLink tSFldName
   if there is a fld tSFldName then
      put the text of fld tSFldName into tText
      if tText is "" then exit tSetLink
      -- set colour of links
      put the cREVHelpHiliteColor of stack "revPreferences" into tNavLinkColour
      set the linkColor of this stack to tNavLinkColour
      set the linkVisitedColor of this stack to tNavLinkColour
      --
      put 0 into tIMCount
      put "" into tMatchCharList
      if tText contains "|" then
         put tText into tString
         put the length of tString into tLength
         replace "|" with empty in tString
         put tLength - the length of tString into tMatchesNumber
         --put tMatchesNumber -- number of "|" to format in the text
         put 0 into tCount
         repeat tMatchesNumber
            find string "|" in field tSFldName
            put the charIndex of the foundChunk into tFoundCharOfChunk
            put the number of words of char 1 to (tFoundCharOfChunk -1) of tText into tWordNumber
            -- just test either side of this word, to check it extends
            put tWordNumber -1 into tMinusWordNumber
            put word tMinusWordNumber of tText into tBeforeText
            put tWordNumber into tPlusWordNumber
            put word tPlusWordNumber of tText into tAfterText
            replace "|" with return in tAfterText
            put line 2 of tAfterText into tAfterText
            replace "," with "" in tAfterText
            if tAfterText is tBeforeText  then
               -- extend selection
               put the number of chars in tAfterText +1 into tCharExtends
            else
               -- do not extend selection
               put 0 into tCharExtends
               put "" into tBeforeText
            end if
            
            put word tWordNumber of tText into tWordToLink
            if tWordToLink contains "|" then replace "|" with " > " in tWordToLink
            if tWordToLink contains "," then replace "," with "" in tWordToLink
            put tWordToLink into tJustWord
            replace " > " with return in tJustWord
            put line 2 of tJustWord into tGoLink
            put line 1 of tJustWord into tJustWord
            put the number of chars in tJustWord into tCharMinus
            put the number of chars in tGoLink into tCharPlus
            --
            put "128,126,128" into tDelColour
            set the textColor of char (tFoundCharOfChunk - (tCharMinus) - tCharExtends) to (tFoundCharOfChunk -1) of fld tSFldName to tDelColour -- colour the link as discard
            put char (tFoundCharOfChunk - (tCharMinus) - tCharExtends) to (tFoundCharOfChunk -1) of fld tSFldName into tSetLinkName
            --
            if char 1 of tBeforeText is " " then delete char 1 of tBeforeText
            put tFoundCharOfChunk - (tCharMinus) - tCharExtends  & " > "  & tFoundCharOfChunk -1 & " " & tBeforeText & " " & tWordToLink into line (the number of lines in tMatchCharList +1) of tMatchCharList
            
            -- OXT-Beyond: the link is the text after the bar, one word or, for
            -- a link of two words, two, without the punctuation after it
            put char (tFoundCharOfChunk + 1) to (tFoundCharOfChunk + 200) of tText into tLinkShown
            if char 1 of tLinkShown is among the chars of (space & tab & return) then
               put empty into tLinkShown
            else if tCharExtends > 0 then
               put word 1 to 2 of tLinkShown into tLinkShown
            else
               put word 1 of tLinkShown into tLinkShown
            end if
            repeat while the number of chars in tLinkShown > 1
               put the last char of tLinkShown into tLinkLast
               if tLinkLast is among the chars of ".,;:!?" or (tLinkLast is ")" and "(" is not in tLinkShown) or (tLinkLast is quote and offset(quote, tLinkShown) is the number of chars in tLinkShown) then
                  delete the last char of tLinkShown
               else
                  exit repeat
               end if
            end repeat
            if tLinkShown is not empty then
               set the textStyle of char (tFoundCharOfChunk + 1) to (tFoundCharOfChunk + the number of chars in tLinkShown) of fld tSFldName to "link" -- make it a link
               set the linkText of char (tFoundCharOfChunk + 1) to (tFoundCharOfChunk + the number of chars in tLinkShown) of fld tSFldName to tSetLinkName -- define the link
            end if
            
            add 1 to tcount
         end repeat
         find string ("*" & the seconds & "*") in field tSFldName -- not going to find this of course!
         set the vScroll of fld tSFldName to 0
         
         repeat with i = 1 to (the number of chars in fld tSFldName)
            if the textcolor of char i of fld tSFldName is tDelColour then
               delete char i of fld tSFldName
               subtract 1 from i
            end if
            if char i of fld tSFldName is "|" then
               delete char i of fld tSFldName
               subtract 1 from i
            end if
         end repeat
         
         --put tMatchCharList -- debug out
         --set the tProcLinks of fld tSFldName to tMatchCharList
         
      end if
   end if
end tSetLink

