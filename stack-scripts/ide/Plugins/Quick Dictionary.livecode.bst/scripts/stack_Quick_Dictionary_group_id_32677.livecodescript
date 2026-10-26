script "stack_Quick_Dictionary_group_id_32677"
-- Stack file: ide/Plugins/Quick Dictionary.livecode
-- Object: stack "Quick Dictionary" > card (id 1002) > group "risultati" (id 32677)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on selectionChanged pHilitedIndex, pPrevHilitedIndex
   local tSelDataA, tName, tType, tID, tSQL, tRecordSet, tError, temp2, temp3, temp4, tSubArray
   put the dgDataOfIndex[pHilitedIndex] of me into tSelDataA
   put textDecode(tSelDataA["Col 1"] ) into tName
   put textDecode(tSelDataA["Col 2"] ) into tType
   put the cConnID of this card into tID --custom property
   put "SELECT entry_data FROM dictionary_data WHERE entry_name='"& tName &"' AND entry_type='"& tType &"' ;" into tSQL
   put revQueryDatabase(tID,tSQL) into tRecordSet  --open database
   put revDatabaseColumnNamed(tRecordSet,"entry_data","tArray") into tError  --tArray contains data, tError contains errors
   if tError <> empty then  --error
      answer "Sorry, there was a problem extracting data from the database." &cr& tError with "OK" titled "Error"
      exit to top
   end if
   revCloseCursor tRecordSet  --close database
   put arrayDecode(tArray) into tArray  --array
   --put keys(tArray)  --keys of array tArray:
   --Display Name,Type,Summary,Syntax,Synonyms,Params,Example,Description,OS,Tags,Platforms,Value,References,Variants,Introduced
   --test here:
   
   
   put "<h2>"& tArray["Display Name"] &"</h2>" after temp2
   put "<h3><i>("& tArray["Type"] &")</i></h3>" after temp2
   put cleanText(tArray["Summary"]) &"<br>" after temp2
   put "<h3>Syntax:</h3>" after temp2
   repeat for each element j in tArray["Syntax"]
      put cleanTags(j) &"<br>----<br>" after temp2
   end repeat
   put "<h3>Synonyms:</h3>" after temp2
   put tArray["Synonyms"] into tSubArray
   put empty into temp3
   repeat for each element j in tSubArray
      put j &", " after temp3
   end repeat
   delete char - 2 to - 1 of temp3
   put temp3 after temp2
   put "<br><h3>Params:</h3>" after temp2
   put "<ul>" after temp2
   repeat for each element j in tArray["Params"]
      put "<li><i>"& j["Name"] &"</i> ("& j["Type"]&" ): "& j["Description"] &"</li>" after temp2
   end repeat
   put "</ul><br>" after temp2
   put "<h3>Examples:</h3>" after temp2
   repeat for each element j in tArray["Example"]
      put cleanTags(j) &"<br>----<br>" after temp2
   end repeat
   put "<h3>Description:</h3>" after temp2
   put cleanText(tArray["Description"]) after temp2
   put "<br><h3>Values:</h3>" after temp2
   put tArray["Value"] into tSubArray
   put empty into temp3
   repeat for each key i in tSubarray
      put tSubArray[i]["description"] &cr after temp3
   end repeat
   put cleanText(temp3) &"<br>" after temp2
   repeat for each key i in tSubArray
      if tSubArray[i]["type"] = "enum" then
         put empty into temp3
         put empty into temp4
         put the keys of tSubArray[i]["enum"] into temp3
         repeat for each line j in temp3
            put tSubArray[i]["enum"][j]["value"] & ": " & tSubArray[i]["enum"][j]["description"] & "<br>" after temp4
         end repeat
         put temp4 after temp2
      end if
   end repeat
   put "<h3>OS:</h3>" after temp2
   repeat for each element j in tArray["OS"]
      put  j & comma after temp2      
   end repeat
   delete char -1 of temp2  --last comma
   set the htmlText of fld "Testo" to temp2  --display
end selectionChanged

function cleanTags pText
   replace "<" with "{" in pText
   replace ">" with "}" in pText
   replace cr with "<br>" in pText
   return pText
end cleanTags

function cleanText pText
   replace "<" with "" in pText
   replace ">" with "" in pText
   replace "."&cr&cr with ".@" in pText
   replace ". "&cr&cr with ".@" in pText
   replace "."&cr&"-" with ".@" in pText
   replace cr with space in pText  --allow wrap
   replace ".@" with ".<br><br>" in pText  --maintain paragraphs
   return pText
end cleanText


