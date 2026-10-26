script "stack_revSearch_button_id_1239"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002) > group "Controls" (id 1149) > button "Replace" (id 1239)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

global gREVCaseSensitive,gREVRegEx,gREVSearchTerm,gREVSearchIn,gREVShowStacks
global gREVName,gREVFieldText,gREVButtonContents,gREVScript
global gREVOtherProperties,gREVOtherPropertiesSearchType,gREVSpecificProperty
global gREVCustomProperties

on mouseUp
   -- MM-2011-08-08: Allow replace to replace with the empty string
   --  if fld "replace" of stack "revSearch" is empty then
   --    answer "Please enter a replace term in the replace field."
   --    exit mouseUp
   --  end if
   local tReplaceTerm, tObjectList
   put the text of fld "replace" of stack "revSearch" into tReplaceTerm
   put the text of fld "stack" of stack "revSearch" into tObjectList
   if gREVSearchIn is "global variable contents" then
      
      
      do "global"&&the globals
      if gREVCaseSensitive then set the caseSensitive to true
      
      repeat for each item i in the globals
         if not gREVShowStacks then
            if char 1 to 4 of i is "gREV" or i is "msg" or i is "each" then
               next repeat
            end if
         end if
         
         if gREVRegEx then--REGEX MATCHING ON GLOBALS CONTENTS
            local tGlobalMatch, tContents
            do "put matchText("&i,"gREVSearchTerm) into tGlobalMatch"
            if tGlobalMatch then
               do "put"&&i&&"into tContents"
               put replaceText(tContents,gREVSearchTerm,tReplaceTerm) into tContents
               do "put"&&tContents&&"into"&&i
            end if
         else
            
            do "put"&&quote&gREVSearchTerm&quote&&"is in"&&i&&"into tGlobalMatch"--GLOBALS CONTENTS MATCHING
            if tGlobalMatch then
               do "put"&&i&&"into tContents"
               replace gREVSearchTerm with tReplaceTerm in tContents
               do "put"&&tContents&&"into"&&i
            end if
         end if
      end repeat
      disable me
      disable fld "replace" of stack "revSearch"
      send "mouseUp" to fld "stack" of stack "revSearch"
      exit mouseUp
   end if
   
   set the itemDel to tab
   local tObjectPaths, tReturnAddressing, tStackName
   repeat for each line l in tObjectList
      put item 2 of l & cr after tObjectPaths
   end repeat
   if the last char in tObjectPaths is cr then delete last char in tObjectPaths
   set the itemDel to comma
   
   repeat for each line l in tObjectPaths
      if tReturnAddressing is not empty then set the hcAddressing of stack tStackName to tReturnAddressing
      put the short name of revIDEStackOfObject(l) into tStackName
      put the hcAddressing of stack tStackName into tReturnAddressing
      set the hcAddressing of stack tStackName to false
      
      if there is a l then
         revIDESetEdited tStackName
         
         local tModName, tModText, tModScript, tPropList
         local tModOtherProp, tModSpecificProp, nMod
         local tTempSet, tKeys, tName, tLine, tSets, tCurrentName, tSet
         
         if gREVCaseSensitive then set the caseSensitive to true
         if not gREVRegEx then
            
            if gREVName then--NAME
               if gREVSearchTerm is in the short name of l then
                  put the short name of l into tModName
                  replace gREVSearchTerm with tReplaceTerm in tModName
                  set the name of l to tModName
               end if
            end if 
            
            if gREVFieldText and word 1 of l is "field" then--FIELD TEXT
               if gREVSearchTerm is in the text of l then
                  put the text of l into tModText
                  replace gREVSearchTerm with tReplaceTerm in tModText
                  set the text of l to tModText
               end if
            end if
            
            if gREVButtonContents and word 1 of l is "button" then--BUTTON CONTENTS
               if gREVSearchTerm is in the text of l then
                  put the text of l into tModText
                  replace gREVSearchTerm with tReplaceTerm in tModText
                  set the text of l to tModText
               end if
            end if
            
            if gREVScript then--SCRIPT
               if gREVSearchTerm is in the script of l then
                  put the script of l into tModScript
                  replace gREVSearchTerm with tReplaceTerm in tModScript
                  set the script of l to tModScript
               end if
            end if
            
            if gREVOtherProperties then--OTHER PROPERTIES
               switch gREVOtherPropertiesSearchType
                  case "all other object properties"--ALL OTHERS
                     put "cREV" & word 1 of l & "PropertyNames" into tPropList
                     repeat for each line n in the tPropList of stack "revSearch"
                        if gREVSearchTerm is in the n of l then
                           put the n of l into tModOtherProp
                           replace gREVSearchTerm with tReplaceTerm in tModOtherProp
                           set the n of l to tModOtherProp
                        end if
                     end repeat
                     break
                  case "specific property"--SPECIFIC
                     put "cREV" & word 1 of l & "PropertyNames" into tPropList
                     if gREVSpecificProperty is in the tPropList of stack "revSearch" then
                        if gREVSearchTerm is in the gREVSpecificProperty of l then
                           put the gREVSpecificProperty of l into tModSpecificProp
                           replace gREVSearchTerm with tReplaceTerm in tModSpecificProp
                           set the gREVSpecificProperty of l to tModSpecificProp
                        end if
                     end if
                     break
               end switch
            end if
            
            if gREVCustomProperties then--CUSTOM PROPERTIES - SET NAMES, KEYS NAMES, CONTENTS
               
               repeat for each line n in the customKeys of l--DEFAULT SET KEY NAMES
                  if gREVSearchTerm is in n then
                     put n into nMod
                     replace gREVSearchTerm with tReplaceTerm in nMod
                  else
                     put n into nMod
                  end if
                  put the n of l into tTempSet[nMod]  
               end repeat
               set the customKeys of l to empty
               put keys(tTempSet) into tKeys
               repeat for each line o in tKeys
                  set the o of l to tTempSet[o]
               end repeat
               
               repeat for each line customKeyLine in the customKeys of l--DEFAULT SET KEY CONTENTS
                  if gREVSearchTerm is in the customKeyLine of l then
                     put the customKeyLine of l into tContents
                     replace gREVSearchTerm with tReplaceTerm in tContents
                     set the customKeyLine of l to tContents
                  end if
               end repeat
               
               repeat for each line customPropertySetLine in the customPropertySets of l--SET NAMES
                  if gREVSearchTerm is in customPropertySetLine then
                     put customPropertySetLine into tName
                     replace gREVSearchTerm with tReplaceTerm in tName
                     put customPropertySetLine into tLine
                     
                     set the customProperties[tName] of l to the customProperties[tLine] of l
                     put the customPropertySets of l into tSets
                     set the wholeMatches to true
                     delete line lineOffset(tLine,tSets) of tSets
                     set the customPropertySets of l to tSets
                  end if
               end repeat
               
               repeat for each line customPropertySetLine in the customPropertySets of l--KEY NAMES INSIDE SETS
                  repeat for each line n in customKeys[customPropertySetLine] of l
                     put n into tCurrentName
                     put n into tName
                     if gREVSearchTerm is in tName then
                        replace gREVSearchTerm with tReplaceTerm in tName
                     else
                        next repeat
                     end if
                     put customPropertySetLine into tLine
                     do "set the" && tLine & "[" & quote & tName & quote & "] of l to the" && tLine & "[" & quote & tCurrentName & quote & "] of l"
                     put the customKeys[tLine] of l into tSets
                     set the wholeMatches to true
                     delete line lineOffset(tCurrentName,tSets) of tSets
                     set the customKeys[tLine] of l to tSets
                  end repeat
               end repeat
               
               repeat for each line customPropertySetLine in the customPropertySets of l--CONTENTS OF KEYS INSIDE SETS
                  repeat for each line customKeyLine in customKeys[customPropertySetLine] of l
                     do "put the" && customPropertySetLine &"[" & customKeyLine & "] of l into tContents"
                     if gREVSearchTerm is in tContents then
                        replace gREVSearchTerm with tReplaceTerm in tContents
                     else
                        next repeat
                     end if
                     put customKeyLine into tLine
                     put customPropertySetLine into tSet
                     do "set the" && tSet & "[" & quote & tLine& quote & "] of l to" && quote&tContents&quote
                  end repeat
               end repeat
               
            end if
            
         else--TERM IS A REGULAR EXPRESSION
            
            if gREVName then--NAME
               if matchText(the short name of l,gREVSearchTerm) then
                  put replaceText(the short name of l,gREVSearchTerm,tReplaceTerm) into tModName
                  set the name of l to tModName
               end if
            end if 
            
            if gREVFieldText and word 1 of l is "field" then--FIELD TEXT
               if matchText(the text of l,gREVSearchTerm) then
                  put replaceText(the text of l,gREVSearchTerm,tReplaceTerm) into tModText
                  set the text of l to tModText
               end if
            end if
            
            if gREVButtonContents and word 1 of l is "button" then--BUTTON CONTENTS
               if matchText(the text of l,gREVSearchTerm) then
                  put replaceText(the text of l,gREVSearchTerm,tReplaceTerm) into tModText
                  set the text of l to tModText
               end if
            end if
            
            if gREVScript then--SCRIPT
               if matchText(the script of l,gREVSearchTerm) then
                  put replaceText(the script of l,gREVSearchTerm,tReplaceTerm) into tModScript
                  set the script of l to tModScript
               end if
            end if
            
            if gREVOtherProperties then--OTHER PROPERTIES
               switch gREVOtherPropertiesSearchType
                  case "all other object properties"--ALL OTHERS
                     put "cREV" & word 1 of l & "PropertyNames" into tPropList
                     repeat for each line n in the tPropList of stack "revSearch"
                        if matchText(the n of l,gREVSearchTerm) then
                           put replaceText(the n of l,gREVSearchTerm,tReplaceTerm) into tModOtherProp
                           set the n of l to tModOtherProp
                        end if
                     end repeat
                     break
                  case "specific property"--SPECIFIC
                     put "cREV" & word 1 of l & "PropertyNames" into tPropList
                     if matchText(the gREVSpecificProperty of l,gREVSearchTerm) then
                        put replaceText(the gREVSpecificProperty of l,gREVSearchTerm,tReplaceTerm) into tModSpecificProp
                        set the gREVSpecificProperty of l to tModSpecificProp
                     end if
                     break
               end switch
            end if
            
            if gREVCustomProperties then--CUSTOM PROPERTIES - SET NAMES, KEYS NAMES, CONTENTS
               
               repeat for each line n in the customKeys of l--DEFAULT SET KEY NAMES
                  if matchText(n,gREVSearchTerm) then
                     put replaceText(n,gREVSearchTerm,tReplaceTerm) into nMod
                  else
                     put n into nMod
                  end if
                  put the n of l into tTempSet[nMod]  
               end repeat
               set the customKeys of l to empty
               put keys(tTempSet) into tKeys
               repeat for each line o in tKeys
                  set the o of l to tTempSet[o]
               end repeat
               
               repeat for each line customKeyLine in the customKeys of l--DEFAULT SET KEY CONTENTS
                  if matchText(the customKeyLine of l,gREVSearchTerm) then
                     put replaceText(the customKeyLine of l,gREVSearchTerm,tReplaceTerm) into tContents
                     set the customKeyLine of l to tContents
                  end if
               end repeat
               
               repeat for each line customPropertySetLine in the customPropertySets of l--SET NAMES
                  if matchText(customPropertySetLine,gREVSearchTerm) then
                     put replaceText(customPropertySetLine,gREVSearchTerm,tReplaceTerm) into tName
                     put customPropertySetLine into tLine
                     
                     set the customProperties[tName] of l to the customProperties[tLine] of l
                     put the customPropertySets of l into tSets
                     set the wholeMatches to true
                     delete line lineOffset(tLine,tSets) of tSets
                     set the customPropertySets of l to tSets
                  end if
               end repeat
               
               repeat for each line customPropertySetLine in the customPropertySets of l--KEY NAMES INSIDE SETS
                  repeat for each line n in customKeys[customPropertySetLine] of l
                     put n into tCurrentName
                     if matchText(n,gREVSearchTerm) then
                        put replaceText(n,gREVSearchTerm,tReplaceTerm) into tName
                     else
                        next repeat
                     end if
                     put customPropertySetLine into tLine
                     do "set the" && tLine & "[" & quote & tName & quote & "] of l to the" && tLine & "[" & quote & tCurrentName & quote & "] of l"
                     put the customKeys[tLine] of l into tSets
                     set the wholeMatches to true
                     delete line lineOffset(tCurrentName,tSets) of tSets
                     set the customKeys[tLine] of l to tSets
                  end repeat
               end repeat
               
               repeat for each line customPropertySetLine in the customPropertySets of l--CONTENTS OF KEYS INSIDE SETS
                  repeat for each line customKeyLine in customKeys[customPropertySetLine] of l
                     do "put the" && customPropertySetLine &"[" & customKeyLine & "] of l into tContents"
                     if matchText(tContents,gREVSearchTerm) then
                        put replaceText(tContents,gREVSearchTerm,tReplaceTerm) into tContents
                     else
                        next repeat
                     end if
                     put customKeyLine into tLine
                     put customPropertySetLine into tSet
                     do "set the" && tSet & "[" & quote & tLine& quote & "] of l to" && quote&tContents&quote
                  end repeat
               end repeat
               
            end if
            
         end if
      end if
   end repeat
   if tReturnAddressing is not empty then set the hcAddressing of stack tStackName to tReturnAddressing
   disable me
   disable fld "replace" of stack "revSearch"
   disable fld "replace label" of stack "revSearch"
   send "mouseUp" to fld "stack" of stack "revSearch"
end mouseUp
