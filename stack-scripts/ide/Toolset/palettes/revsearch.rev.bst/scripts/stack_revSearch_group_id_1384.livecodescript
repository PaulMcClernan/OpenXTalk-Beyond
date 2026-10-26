script "stack_revSearch_group_id_1384"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002) > group (id 1384)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

global gREVCaseSensitive,gREVRegEx,gREVSearchTerm,gREVSearchIn
global gREVName,gREVFieldText,gREVButtonContents,gREVScript
global gREVOtherProperties,gREVOtherPropertiesSearchType,gREVSpecificProperty
global gREVCustomProperties

on mouseRelease
  mouseUp
end mouseRelease

on mouseDoubleUp
   local tObject, tStackName, tReturnAddressing
   set the itemDel to tab
   put item 2 of the selectedText of fld "stack" of stack "revSearch" into tObject
   set the itemDel to comma
   
   get wordOffset("stack",tObject) -- parse here because passing revTargetStack long id of HC address object = not found
   put word (it) to (it+1) of tObject into tStackName
   put the short name of tStackName into tStackName
   put the hcAddressing of stack tStackName into tReturnAddressing
   set the hcAddressing of stack tStackName to false
   
   if there is not a tObject then
      answer "Object not found. The object has either been deleted or relocated since your search."
      exit mouseDoubleUp
   end if
   
   if tReturnAddressing then
      if word 1 of tObject is not "group" then put "card " before tObject
      set the hcAddressing of stack tStackName to tReturnAddressing
   end if
   
   -- OK-2006-09-13: Fix for bug 3746
   local tCard
   
   local tTerm
   put the text of field "search term" into tTerm
   if word 1 of the name of tObject is "field" and matchText(the text of field "Item Info", " found in: text$") then
      put controlsCard(tObject) into tCard
      
      # OK-2007-11-23 : Bug 5502, prevent the card refreshing the contents of the controls 
      # which can cause the result not to be found
      local tDefaultStack
      put the defaultStack into tDefaultStack
      set the defaultStack to the owner of tCard
      
      lock messages
      go to card (the short name of tCard)
      unlock messages
      
      find string tTerm in tObject
      set the defaultStack to tDefaultStack
   else
      # OK-2008-08-12 : Bug 6810 - Get the script editor to show the first matching result.
      local tCallback
      put "scriptOpened" into tCallback
      
      local tCallbackTarget
      put the long id of me into tCallbackTarget 
      
      send "revSERegisterObjectCallback tCallback, tCallbackTarget, tObject" to revScriptEditorMain()
      edit the script of tObject
   end if
   mouseUp
end mouseDoubleUp

command scriptOpened pObject, pScriptEditor
   local tQuery
   put the text of field "Search Term" of the owner of me into tQuery
   
   local tIsRegExp
   put the hilited of button "Term is a regular expression" of the owner of me into tIsRegExp
   
   local tIgnoreCase
   put not the hilited of button "Case sensitive searching" of the owner of me into tIgnoreCase
   
   local tUseWildCards
   put false into tUseWildCards
   
   local tWholeMatch
   put false into tWholeMatch
   
   local tTarget
   put "current" into tTarget
   
   try
      send "revSEFindInitialize" to pScriptEditor
      send "revSEFindNext tQuery, tIsRegExp, tUseWildCards, tWholeMatch, tIgnoreCase, tTarget" to pScriptEditor
      --send "revSEFindFinalize" to pScriptEditor
   catch tError
      log "Error finding message to script editor"
      log tError
   end try
end scriptOpened

private command log pMessage
  put pMessage & return after msg
end log

on mouseUp
   local l, tReturnAddressing, tStackName, tBasicMatchingProps, tPropList, tMatchingProps
   local tSpecificMatchingProp, tMatchingCustomProps, tContents, tAllProps
   global gRegex
   if the owner of the target is not me and the target is not me then exit mouseUp
   
   if the num of lines in fld "stack" of stack "revSearch" is 0 then exit mouseUp
   
   if gREVSearchIn is "global variable contents" then
      exit mouseUp     
   end if
   
   set the itemDel to tab
   put item 2 of the selectedText of fld "stack" of stack "revSearch" into l
   set the itemDel to comma
   
   get wordOffset("stack",l) -- parse here because passing revTargetStack long id of HC address object = not found
   put word (it) to (it+1) of l into tStackName
   put the short name of tStackName into tStackName
   put the hcAddressing of stack tStackName into tReturnAddressing
   set the hcAddressing of stack tStackName to false
   
   if there is not a l then
      answer "Object not found. The object has either been deleted or relocated since your search."
      set the hcAddressing of stack tStackName to tReturnAddressing
      exit mouseUp
   end if
   
   if gREVCaseSensitive then set the caseSensitive to true
   
   if gREVName then
      # OK-2009-01-29
      if matchString(the short name of l, gREVSearchTerm, gREVRegEx, gREVCaseSensitive) then
         put "name, " after tBasicMatchingProps
      end if
   end if
   
   if gREVFieldText then
      # OK-2009-01-29
      if matchString(the text of l, gREVSearchTerm, gREVRegEx, gREVCaseSensitive) then
         put "text, " after tBasicMatchingProps
      end if
   end if
   
   if gREVButtonContents then
      # OK-2009-01-29
      if matchString(the text of l, gREVSearchTerm, gREVRegEx, gREVCaseSensitive) then
         put "contents (text), " after tBasicMatchingProps
      end if
   end if
   
   if gREVScript then
      # OK-2009-01-29
      if matchString(the script of l, gREVSearchTerm, gREVRegEx, gREVCaseSensitive) then
         put "script, " after tBasicMatchingProps
      end if
   end if
   
   if gREVOtherProperties then
      switch gREVOtherPropertiesSearchType
         case "all other object properties"
            put "cREV" & word 1 of l & "PropertyNames" into tPropList
            # OK-2009-01-29
            repeat for each line n in the tPropList of stack "revSearch"
               if matchString(the n of l, gREVSearchTerm, gREVRegEx, gREVCaseSensitive) then
                  put n & ", " after tMatchingProps
               end if
            end repeat
            
         break
         case "specific property"
            put "cREV" & word 1 of l & "PropertyNames" into tPropList
            if gREVSpecificProperty is in the tPropList of stack "revSearch" then
               # OK-2009-01-29
               if matchString(the gREVSpecificProperty of l, gREVSearchTerm, gREVRegEx, gREVCaseSensitive) then
                  put gREVSpecificProperty into tSpecificMatchingProp
               end if
            end if
         break
      end switch     
   end if
   
   if gREVCustomProperties then
      # OK-2009-01-29
      repeat for each line customKeyLine in the customKeys of l--DEFAULT SET
         if matchString(customKeyLine, gREVSearchTerm, gREVRegEx, gREVCaseSensitive) then
            put quote & customKeyLine & quote && "(custom key name - default set)" & cr after tMatchingCustomProps
         end if
         
         local tValue
         put the customKeyLine of l into tValue
         
         if tValue is an array then
            get matchArray(tValue, gREVSearchTerm, gREVRegEx, gREVCaseSensitive)
         else
            get matchString(tValue, gREVSearchTerm, gREVRegEx, gREVCaseSensitive)
         end if
         
         if it then
            put "contents of" &&quote& customKeyLine &quote&& "(custom key - default set)" & cr after tMatchingCustomProps
         end if
      end repeat
      
      repeat for each line customPropertySetLine in the customPropertySets of l--SET NAMES
         if matchString(customPropertySetLine, gREVSearchTerm, gREVRegEx, gREVCaseSensitive) then
            put quote & customPropertySetLine &quote && "(custom property set name)"  & cr after tMatchingCustomProps
         end if
         
         if matchString(the customKeys[customPropertySetLine] of l, gREVSearchTerm, gREVRegEx, gREVCaseSensitive) then
            put "custom key of custom property set" && quote & customPropertySetLine &quote & cr after tMatchingCustomProps
         end if
         
         repeat for each line customKeyLine in customKeys[customPropertySetLine] of l--CONTENTS OF KEYS INSIDE SETS
            do "put the" && customPropertySetLine &"[" & quote &customKeyLine& quote & "] of l into tContents"
            
            if tContents is an array then
               get matchArray(tContents, gREVSearchTerm, gREVRegEx, gREVCaseSensitive)
            else
               get matchString(tContents, gREVSearchTerm, gREVRegEx, gREVCaseSensitive)
            end if
            
            if it then
               put "contents of" && quote & customPropertySetLine &"["& customKeyLine &"]" &quote&& "(custom property set[key])" & cr after tMatchingCustomProps
            end if
         end repeat
      end repeat
   end if
   
   delete last char in tMatchingCustomProps
   delete last char in tMatchingProps
   delete last char in tMatchingProps
   sort items of tMatchingProps
   
   delete last char in tBasicMatchingProps
   delete last char in tBasicMatchingProps
   
   if tBasicMatchingProps is not empty then put tBasicMatchingProps & cr into tAllProps
   if tSpecificMatchingProp is not empty then put "Specific Property:" && tSpecificMatchingProp & cr after tAllProps
   if tMatchingProps is not empty then put "Other Properties:" && tMatchingProps & cr after tAllProps
   if tMatchingCustomProps is not empty then put "Custom Properties:" & cr & tMatchingCustomProps after tAllProps
   
   if tAllProps is not empty then
      put quote & gREVSearchTerm & quote && "found in: " before tAllProps
   else
      put quote & gREVSearchTerm & quote && "found in: (no matches - original search term replaced in found items)" into tAllProps
   end if
   
   set the text of fld "item info" of stack "revSearch" to tAllProps
   
   set the hcAddressing of stack tStackName to tReturnAddressing
end mouseUp

on arrowKey
  send "mouseUp" to me in 0 milliseconds
  pass arrowKey
end arrowKey

-- OK-2006-09-13: Given a reference to a control, returns a reference
-- to the card that owns the control. If the control is a card, returns
-- the control, if its a stack then returns a reference to the stack.
function controlsCard pControl
  local tReference
  if word 1 of the name of pControl is among the items of "card,stack" then return pControl
  
  put pControl into tReference
  
  local tCard
  repeat 1000 -- Just in case the reference is invalid
    if word 1 tReference is "card" then 
      put tReference into tCard
      return tCard
    end if
    put word 5 to -1 of tReference into tReference
  end repeat
  
end controlsCard
