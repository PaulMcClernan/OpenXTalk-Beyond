script "stack_revSearch_button_id_1356"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch" > card (id 1002) > button "Search" (id 1356)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

global gREVCaseSensitive,gREVRegEx,gREVSearchTerm,gREVSearchIn
global gREVName,gREVFieldText,gREVButtonContents,gREVScript
global gREVOtherProperties,gREVOtherPropertiesSearchType,gREVSpecificProperty
global gREVCustomProperties
global gREVFinalResult
global gREVSharedFields
local lObeyDontSearch,lSearchMarkedCardsOnly,lMarkedOrUnmarked
local lObjectList,lResult
local lGroupsList

on mouseUp
   set the allowInterrupts to false
   --GENERAL PREPARATION
   put empty into lGroupsList
   put empty into lObjectList--EMPTY VARIABLES
   put empty into lResult
   put empty into field "name" of stack "revSearch"
   put empty into field "type" of stack "revSearch"
   put empty into field "card" of stack "revSearch"
   put empty into field "stack" of stack "revSearch"
   put empty into field "item info" of stack "revSearch"
   put empty into field "feedback" of stack "revSearch"
   put empty into gREVSharedFields
   disable button "remove from list" of stack "revSearch"
   disable field "replace" of stack "revSearch"
   disable button "replace" of stack "revSearch"
   global gREVShowStacks --GET FILTERED LIST OF OPENSTACKS
   set the wholeMatches to true
   
   local tOpenStacks
   put the openStacks into tOpenStacks
   if not gREVShowStacks then put revFilterStacksList(tOpenStacks) into tOpenStacks
   
   if tOpenStacks is empty and "this" is in the label of button "search in" then
      answer "There are no open user stacks. Please open a stack or, to enable searching of IDE stacks instead, select 'Show IDE Stacks in Lists' from the View menu."
      exit mouseUp    
   end if
   
   put the text of field "search term" into gREVSearchTerm --READ IN SEARCH TERM
   
   --"SEARCH FOR" PARAMETERS
   put the hilite of button "term is a regular expression" into gREVRegEx
   put the hilite of button "case sensitive searching" into gREVCaseSensitive
   if not(gREVCaseSensitive) and gREVRegEx then put "(?i)" before gREVSearchTerm
   
   ##mf 20/08/2005 Warning for error in pattern expression
   local tJunk
   if gREVRegEX then
      try
         put matchText("test", gREVSearchTerm) into tJunk
      catch tJunk
         answer error "There is an error in the pattern expression."
         exit mouseUp
      end try
   end if
   
   set the loc of image "indeterminate" of stack "revSearch" to the cOnScreenLoc of image "indeterminate" of stack "revSearch"
   set the loc of scrollbar "progress" of stack "revSearch" to the cOffScreenLoc of scrollbar "progress" of stack "revSearch"
   set the text of field "feedback" of stack "revSearch" to "Getting info..."
   
   --"SEARCH IN" PARAMETERS
   put the hilite of button "obey dontSearch properties" into lObeyDontSearch
   put the hilite of button "Search Marked Cards Only" into lSearchMarkedCardsOnly
   put the label of button "marked or unmarked" into lMarkedOrUnmarked
   --"PROPERTIES TO SEARCH IN" PARAMETERS
   put the cScript of stack "revSearch" into gREVScript
   put the cButtonContents of stack "revSearch" into gREVButtonContents
   put the cCustomProperties of stack "revSearch" into gREVCustomProperties
   put the cOtherProperties of stack "revSearch" into gREVOtherProperties
   put the cOtherPropertiesSearchType of stack "revSearch" into gREVOtherPropertiesSearchType
   put the cFieldText of stack "revSearch" into gREVFieldText
   put the cName of stack "revSearch" into gREVName
   put the cSpecificProperty of stack "revSearch" into gREVSpecificProperty 
   
   --LIST ALL OF THE OBJECTS TO SEARCH
   put the label of button "search in" of stack "revSearch" into gREVSearchIn
   switch the label of button "search in" of stack "revSearch"
      
      case "The Current Selection"
         if the selobj is empty then
            hFeedbackReset
            answer "You must select at least one object to search the current selection."
            exit mouseUp
         end if
         
         local tReturnAddressing
         put the hcAddressing of stack revTargetStack(line 1 of the selObj) into tReturnAddressing
         set the hcAddressing of stack revTargetStack(line 1 of the selObj) to false
         if lObeyDontSearch then --CHECK FOR DONTSEARCH PROPERTIES ON FIELDS
            repeat for each line l in the selobj
               if word 1 of the name of l is "field" then
                  if not the dontSearch of l then
                     put the long id of l & return after lObjectList
                  end if
               else
                  put the long id of l & return after lObjectList
               end if
               hAnimateIndeterminate
            end repeat
         else
            repeat for each line l in the selobj
               put the long id of l & return after lObjectList
               hAnimateIndeterminate
            end repeat
         end if
         hPropertySearch
         set the hcAddressing of stack revTargetStack(line 1 of the selObj) to tReturnAddressing
         break
      case "This Card"
         if the topStack is not "revSearch" then set the defaultStack to the topStack
         put the hcAddressing of this stack into tReturnAddressing
         set the hcAddressing of this stack to false
         put cardSearch(the long id of this card) after lObjectList
         hPropertySearch
         set the hcAddressing of this stack to tReturnAddressing
         break
      case "This Stack"
         set the defaultStack to the topStack
         put the hcAddressing of this stack into tReturnAddressing
         set the hcAddressing of this stack to false
         repeat with i = 1 to the num of cards in this stack
            put cardSearch(the long id of card i of this stack) after lObjectList
         end repeat
         put the long id of this stack after lObjectList
         hPropertySearch
         set the hcAddressing of this stack to tReturnAddressing
         break
      case "This Stack File"
         set the defaultStack to the topStack
         put the hcAddressing of this stack into tReturnAddressing
         set the hcAddressing of this stack to false
         repeat with i = 1 to the number of cards in this stack --THIS STACK
            put cardSearch(the long id of card i of this stack) after lObjectList
         end repeat
         put the long id of this stack & return after lObjectList
         repeat for each line l in the subStacks of this stack --SUBSTACKS OF THIS STACK
            repeat with i = 1 to the number of cards in stack l
               put cardSearch(the long id of card i of stack l) after lObjectList
            end repeat
            put the long id of stack l & return after lObjectList
         end repeat
         hPropertySearch
         set the hcAddressing of this stack to tReturnAddressing
         break
      case "This Stack File and its Stack Files" --THIS STACKFILE (THIS STACK AND ITS SUBSTACKS) AND ITS STACKFILES (MAINSTACKS AND SUBSTACKS OF ITS STACKFILES)
         set the defaultStack to the topStack
         put the hcAddressing of this stack into tReturnAddressing
         set the hcAddressing of this stack to false
         repeat with i = 1 to the number of cards in this stack --THIS STACK
            put cardSearch(the long id of card i of this stack) after lObjectList
         end repeat
         put the long id of this stack & return after lObjectList
         repeat for each line l in the subStacks of this stack --SUBSTACKS OF THIS STACK
            repeat with i = 1 to the num of cards in stack l
               put cardSearch(the long id of card i of stack l) after lObjectList
            end repeat
            put the long id of stack l & return after lObjectList
         end repeat
         
         local tStackList
         repeat for each line l in the stackFiles of this stack --COMPILE LIST OF VALID STACKFILES OF THIS STACK
            if there is a stack (item 1 of l) then put item 1 of l & return after tStackList
         end repeat
         delete last char in tStackList
         repeat for each line l in tStackList --MAINSTACKS IN STACKFILES
            put the long id of stack l & return after lObjectList
            repeat with i = 1 to the number of cards in stack l
               put cardSearch(the long id of card i of stack l) after lObjectList
            end repeat
            repeat for each line n in the subStacks stack l --SUBSTACKS OF MAINSTACKS IN STACKFILES
               repeat with i = 1 to the number of cards in stack n
                  put cardSearch(the long id of card i of stack n) after lObjectList
               end repeat
               put the long id of stack n & return after lObjectList
            end repeat
         end repeat
         hPropertySearch
         set the hcAddressing of this stack to tReturnAddressing
         break
      case "All Open Stacks" --ALL OPEN STACKS
         repeat for each line l in tOpenStacks
            repeat with i = 1 to the number of cards in stack l
               put cardSearch(the long id of card i of stack l) after lObjectList
            end repeat
            put the long id of stack l & return after lObjectList
         end repeat
         hPropertySearch
         break
      case "All Open Stack Files" --ALL OPEN STACK FILES
         repeat for each line l in tOpenStacks
            put the long id of stack l & return after lObjectList
            repeat with i = 1 to the number of cards in stack l --MAINSTACK OF STACK FILE
               put cardSearch(the long id of card i of stack l) after lObjectList
            end repeat
            repeat for each line n in the subStacks of stack l --SUBSTACKS OF MAINSTACK OF STACKFILE
               repeat with i = 1 to the number of cards in stack n
                  put cardSearch(the long id of card i of stack n) after lObjectList
               end repeat
               put the long id of stack n & return after lObjectList
            end repeat
         end repeat
         hPropertySearch
         break     
      case "All Stack Files in a Folder"
         local tPrevDirectory
         put the directory into tPrevDirectory
         set the directory to the cDirectory of stack "revSearch"
         
         local tFiles
         put the files into tFiles
         repeat for each line l in tFiles
            if there is a stack l then
               put the long id of stack l & return after lObjectList
               repeat with i = 1 to the number of cards in stack l --MAINSTACK OF STACK FILE
                  put cardSearch(the long id of card i of stack l) after lObjectList
               end repeat
               repeat for each line n in the subStacks of stack l --SUBSTACKS OF MAINSTACK OF STACKFILE
                  repeat with i = 1 to the number of cards in stack n of stack l
                     put cardSearch(the long id of card i of stack n of stack l) after lObjectList
                  end repeat
                  put the long id of stack n & return after lObjectList
               end repeat
            end if
         end repeat
         set the directory to tPrevDirectory
         hPropertySearch
         break
      case "Global Variable Contents"
         
         do "global" && the globals
         if gREVCaseSensitive then set the caseSensitive to true
         
         repeat for each item i in the globals
            if not gREVShowStacks then
               if char 1 to 4 of i is "gREV" or i is "msg" or i is "each" then
                  next repeat
               end if
            end if
            
            local tGlobalMatch
            if gREVRegEx then --REGEX MATCHING ON GLOBALS CONTENTS
               do "put matchText("&i,"gREVSearchTerm) into tGlobalMatch"
               if tGlobalMatch then
                  put  i & return after lResult
               end if
            else
               
               do "put" && quote & gREVSearchTerm & quote && "is in" && i && "into tGlobalMatch" --GLOBALS CONTENTS MATCHING
               
               if tGlobalMatch then
                  put i & return after lResult
               end if
            end if
         end repeat
         set the loc of image "indeterminate" of stack "revSearch" to the cOffScreenLoc of image "indeterminate" of stack "revSearch"
         if the last char in lResult is return then
            delete last char in lResult
         end if
         if lResult is empty then
            hFeedbackReset
            answer "No global variables found containing" &&quote& gREVSearchTerm &quote&"."
         else
            set the loc of scrollbar "progress" of stack "revSearch" to the cOffScreenLoc of scrollbar "progress" of stack "revSearch"
            set the cResult of stack "revSearch" to lResult
            revAdjustText
            set the text of field "name" of stack "revSearch" to lResult
            if the num of lines in lResult is 1 then
               set the text of field "feedback" of stack "revSearch" to (the num of lines in lResult) && "global found"
            else
               set the text of field "feedback" of stack "revSearch" to (the num of lines in lResult) && "globals found"
            end if
            
            --set the hilitedLines of field "results" of stack "revSearch" to 1
            enable button "remove from list" of stack "revSearch"
            enable field "replace" of stack "revSearch"
            enable field "replace label" of stack "revSearch"
            send "revEnabler" to field "replace" of stack "revSearch"
         end if
         break
         
         local tStack
      case "specific open stack file" --SPECIFIC OPEN STACK FILE
         if field "specific stack" is not empty then put field "specific stack" of stack "revSearch" into tStack --CHECK A STACK IS SPECIFIED
         else
            hFeedbackReset
            answer "Please enter the name of a specific stack to search."
            focus field "specific stack" of stack "revSearch"
            exit mouseUp
         end if
         if tStack is not among the lines of tOpenStacks then --CHECK THE SPECIFIED STACK IS OPEN
            hFeedbackReset
            answer "The stack you have specified is not open or is an IDE stack. To search an IDE stack you must first select 'Show IDE Stacks in Lists' from the View menu."
            focus field "specific stack" of stack "revSearch"
            exit mouseUp
         end if
         repeat with i = 1 to the num of cds in stack tStack --MAINSTACK
            put cardSearch(the long id of cd i of stack tStack) after lObjectList
         end repeat
         
         # OK-2008-09-11 : Stack script is missed out...
         put the long id of stack tStack & return after lObjectList
         
         repeat for each line l in the subStacks of stack tStack --SUBSTACKS
            repeat with i = 1 to the num of cds in stack l
               put cardSearch(the long id of cd i of stack l) after lObjectList
            end repeat
            # OK-2008-09-11 : Substacks scripts are missed out...
            put the long id of stack l & return after lObjectList
         end repeat
         
         hPropertySearch
         break
   end switch
   set the allowInterrupts to true
end mouseUp

function cardSearch pCardLongId
  local tReturnAddressing
  put the hcAddressing of stack revTargetStack(pCardLongID) into tReturnAddressing
  set the hcAddressing of stack revTargetStack(pCardLongID) to false
  
  local tCardName
  put the name of pCardLongId into tCardName --CARD SHORT NAME FOR COMMUNICATING TO USER ONLY
  
  if lObeyDontSearch and the dontSearch of pCardLongId then --CHECK DONTSEARCH OF PASSED CARD
    if the label of button "search in" of stack "revSearch" is "this card" then
      answer "The 'dontSearch' property of" &&tCardName&& "is set to true. To search" && tCardName && ", turn off the 'Obey dontSearch Properties' checkbox and restart your search or set the 'dontSearch' property of" && tCardName && "to false."
    end if
    set the hcAddressing of stack revTargetStack(pCardLongID) to tReturnAddressing
    exit cardSearch
  end if
  if lSearchMarkedCardsOnly then --CHECK THE MARKED OF THIS CARD
    switch lMarkedOrUnmarked
    case "marked"
      if not the mark of pCardLongId then
        if the label of button "search in" of stack "revSearch" is "this card" then
          answer "The 'mark' property of" && tCardName && "is set to false. To search" && tCardName && ", turn off the 'Search marked/unmarked Cards Only' checkbox and restart your search or set the 'mark' property of" && tCardName && "to true."
        end if
        set the hcAddressing of stack revTargetStack(pCardLongID) to tReturnAddressing
        exit cardSearch
      end if
      break
    case "unmarked"
      if the mark of pCardLongId then
        if the label of button "search in" of stack "revSearch" is "this card" then
          answer "The 'mark' property of" && tCardName && "is set to true. To search" && tCardName && ", turn off the 'Search marked/unmarked Cards Only' checkbox and restart your search or set the 'mark' property of" && tCardName && "to false."
        end if
        set the hcAddressing of stack revTargetStack(pCardLongID) to tReturnAddressing
        exit cardSearch
      end if
      break
    end switch
  end if
   
  local tShortId
  put the short ID of pCardLongID into tShortID -- sharedText needs correct card ID
  if lObeyDontSearch then --LIST CONTROLS WITH CHECK FOR DONTSEARCH PROPERTIES ON FIELDS
    repeat with i = 1 to the num of controls in pCardLongId
      if word 1 of the name of control i of pCardLongId is "field" then
        if not the dontSearch of control i of pCardLongId then
          local tControl
          put the long id of control i of pCardLongId into tControl
          put tShortID into word wordOffset("card", tControl) + 2 of tControl -- correct CARD ID
          
          local tTempObjectList
          put tControl & return after tTempObjectList
        end if
      else
        put the long id of control i of pCardLongID into tControl
        if word 1 of tControl is "group" then -- don't duplicate groups
          if tControl is among the lines of lGroupsList then
            if gREVFieldText then -- shared text
              repeat with x = 1 to the number of controls in control i of pCardLongID
                
                --> ALTUIT EDIT CHANGES BEGIN
                #if word 1 of the name of control x of group i of pCardLongID is "field" \
                #and the sharedText of control x of group i of pCardLongID is false then 
                #put the long id of control x of group i of pCardLongID into tSharedField
                local tSharedField
                if word 1 of the name of control x of tControl is "field"  and the sharedText of control x of tControl is false then 
                  put the long id of control x of tControl into tSharedField
                  --> ALTUIT EDIT CHANGES END
                  
                  put tShortID into word wordOffset("card",tSharedField) + 2 of tSharedField -- correct CARD ID
                  put tSharedField & return after gREVSharedFields
                end if
              end repeat
            end if
            add the number of controls in tControl to i
            next repeat
          end if
          put tControl & return after lGroupsList -- don't correct group ID to avoid duplicates
        end if
        put tShortID into word wordOffset("card",tControl) + 2 of tControl -- correct CARD ID
        put tControl & return after tTempObjectList
      end if
    end repeat
  else
    repeat with i = 1 to the num of controls in pCardLongId
      put the long id of control i of pCardLongID into tControl
      if word 1 of tControl is "group" then -- don't duplicate groups
        if tControl is among the lines of lGroupsList then 
          if gREVFieldText then -- shared text
            repeat with x = 1 to the number of controls in control i of pCardLongID
              
              --> ALTUIT EDIT CHANGES BEGIN
              #if word 1 of the name of control x of group i of pCardLongID is "field" \
              #and the sharedText of control x of group i of pCardLongID is false then 
              #put the long id of control x of group i of pCardLongID into tSharedField
              if word 1 of the name of control x of tControl is "field"  and the sharedText of control x of tControl is false then 
                put the long id of control x of tControl into tSharedField                  
                --> ALTUIT EDIT CHANGES END
                
                put tShortID into word wordOffset("card",tSharedField) + 2 of tSharedField -- correct CD ID
                put tSharedField & return after gREVSharedFields
              end if
            end repeat
          end if
          add the number of controls in tControl to i
          next repeat
        end if
        put tControl & return after lGroupsList -- don't correct group ID to avoid duplicates
      end if
      put tShortID into word wordOffset("card",tControl) + 2 of tControl -- correct CD ID
      put tControl & return after tTempObjectList
    end repeat
  end if
  put the long id of pCardLongId & return after tTempObjectList
  hAnimateIndeterminate
  set the hcAddressing of stack revTargetStack(pCardLongID) to tReturnAddressing
  return tTempObjectList
end cardSearch

on hFeedbackReset
  set the loc of image "indeterminate" of stack "revSearch" to the cOffScreenLoc of image "indeterminate" of stack "revSearch"
  set the loc of sb "progress" of stack "revSearch" to the cOffScreenLoc of sb "progress" of stack "revSearch"
  set the text of field "feedback" of stack "revSearch" to empty
end hFeedbackReset

# OK-2007-11-26 : Added declaration as was missing
local lFinalResult

private command log pMessage
  put pMessage & return after msg
end log

on hPropertySearch
  set the loc of image "indeterminate" of stack "revSearch" to the cOffScreenLoc of image "indeterminate" of stack "revSearch"
  set the loc of scrollbar "progress" of stack "revSearch" to the cOnScreenLoc of scrollbar "progress" of stack "revSearch"
  if lObjectList is empty then
    answer "No objects found containing" && quote & gREVSearchTerm & quote & "."
    exit hPropertySearch
  end if
  set the text of field "feedback" of stack "revSearch" to "Searching..."
  enable scrollbar "progress" of stack "revSearch"
  
  local tLines
  put 100 / (the number of lines in lObjectList + the number of lines in gREVSharedFields) into tLines
  
  --search for properties using object list
  --allow user interruption
  
  set the allowInterrupts to false
  
  local tCount
  repeat for each line tObject in lObjectList
    if interrupt() then exit repeat
    hPropertySearchRepeatLoop tObject
    add 1 to tCount
    set the thumbPosition of scrollbar "progress" of stack "revSearch" to round(tLines*tcount)
  end repeat
  
  repeat for each line tObject in gREVSharedFields -- fields in groups with sharedText false
    if interrupt() then exit repeat
    sharedFieldPropSearch tObject
    add 1 to tCount
    set the thumbPosition of scrollbar "progress" of stack "revSearch" to round(tLines*tcount)
  end repeat
   
  if the last char of lResult is return then 
    delete last char of lResult
  end if
  
  # OK-2007-11-26 : Clear lFinalResult as it may have results left over from the last search
  put empty into lFinalResult
  
  repeat for each line tResultLine in lResult
    --put word 1 of the name of l & tab & the short name of l & tab & l & cr after lFinalResult  
    local tSlicer
    put tResultLine into tSlicer
    if word 1 of tResultLine is not "stack" then
      delete char 1 to offset("card id", tSlicer) - 1 of tSlicer
      
      local tCardName
      put the short name of tSlicer into tCardName
      
      local tCardID
      put the id of tSlicer into tCardID
    else
      put "n/a" into tCardName
      put "n/a" into tCardId
    end if
    
    delete char 1 to offset("stack", tSlicer) - 1 of tSlicer
    
    local tStackName
    put the short name of tSlicer into tStackName
    
    local tShortName
    put the short name of tResultLine into tShortName
     
    put word 1 of tResultLine & tab & tShortName & tab & tCardName & tab & tStackName & tab & tResultLine & return after lFinalResult
    
  end repeat
  
  if the last char of lFinalResult is return then
    delete last char in lFinalResult
  end if
  
  set the itemDelimiter to tab
  sort lines of lFinalResult by item 2 of each
  put lFinalResult into gREVFinalResult -- PUT FINAL RESULT INTO GLOBAL FOR LATER REFERENCEING
   
  # OK-2007-11-23
  updateSearchResults gREVFinalResult
  
  set the allowInterrupts to true
end hPropertySearch

# OK-2007-11-23 : Abstracted out to improve clarity a little. 
private command updateSearchResults pResults
   lock screen
   set the itemDelimiter to tab
   repeat for each line tResult in pResults
      put item 1 of tResult & return after field "type" of stack "revSearch"
      put item 2 of tResult & return after field "name" of stack "revSearch"
      put item 3 of tResult & return after field "card" of stack "revSearch"
      put item 4 of tResult & tab & item 5 of tResult & return after field "stack" of stack "revSearch"
   end repeat
   if the last char in the text of field "type" of stack "revSearch" is return then delete last char in field "type" of stack "revSearch"
   if the last char in the text of field "name" of stack "revSearch" is return then delete last char in field "name" of stack "revSearch"
   if the last char in the text of field "card" of stack "revSearch" is return then delete last char in field "card" of stack "revSearch"
   if the last char in the text of field "stack" of stack "revSearch" is return then delete last char in field "stack" of stack "revSearch"
   
   set the endValue of scrollBar "results" of stack "revSearch" to the formattedHeight of field "stack" of stack "revSearch" -item 1 of the margins of field "stack" of stack "revSearch"
   set the thumbSize of scrollBar "results" of stack "revSearch" to the height of field "stack" of stack "revSearch"
   set the pageInc of scrollBar "results" of stack "revSearch" to the height of field "stack" of stack "revSearch"
   if the endValue of scrollBar "results" of stack "revSearch" > the height of field "stack" of stack "revSearch" then enable scrollbar "results" of stack "revSearch"
   else disable scrollbar "results" of stack "revSearch"
   
   set the itemDel to comma
   set the hilitedButtonName of grp "tabs" of stack "revSearch" to "name"
   if the number of lines in pResults is 1 then
      set the text of field "feedback" of stack "revSearch" to (the num of lines in lResult) && "object found"
   else
      set the text of field "feedback" of stack "revSearch" to (the num of lines in lResult) && "objects found"
   end if
   set the thumbPosition of sb "progress" of stack "revSearch" to 0
   set the loc of scrollbar "progress" of stack "revSearch" to the cOffScreenLoc of scrollbar "progress" of stack "revSearch"
   if the number of lines in pResults is 0 then
      exit updateSearchResults
   end if
   
   set the hilitedLines of field "type" of stack "revSearch" to 1
   set the hilitedLines of field "name" of stack "revSearch" to 1
   set the hilitedLines of field "card" of stack "revSearch" to 1
   set the hilitedLines of field "stack" of stack "revSearch" to 1
   send "mouseUp" to field "stack" of stack "revSearch"
   
   enable button "remove from list" of stack "revSearch"
   enable field "replace" of stack "revSearch"
   enable field "replace label" of stack "revSearch"
   send "revEnabler" to field "replace" of stack "revSearch"
   unlock screen
end updateSearchResults

on sharedFieldPropSearch pControl
   # OK-2009-01-29 : Simplified
   if matchString(the text of pControl, gREVSearchTerm, gREVRegEx, gREVCaseSensitive) then
      put pControl & return after lResult
      exit sharedFieldPropSearch
   end if
end sharedFieldPropSearch

on hPropertySearchRepeatLoop pControl
   if gREVCaseSensitive then set the caseSensitive to true
   
   if gREVName then--NAME
      # OK-2009-01-29
      if matchString(the short name of pControl, gREVSearchTerm, gREVRegEx, gREVCaseSensitive) then
         put pControl & return after lResult
         exit hPropertySearchRepeatLoop
      end if
   end if
   
   if gREVFieldText and word 1 of pControl is "field" then --FIELD TEXT
      # OK-2009-01-29
      if matchString(the text of pControl, gREVSearchTerm, gREVRegEx, gREVCaseSensitive) then
         put pControl & return after lResult
         exit hPropertySearchRepeatLoop
      end if
   end if
   
   if gREVButtonContents and word 1 of pControl is "button" then --BUTTON CONTENTS
      # OK-2009-01-29
      if matchString(the text of pControl, gREVSearchTerm, gREVRegEx, gREVCaseSensitive) then
         put pControl & return after lResult
         exit hPropertySearchRepeatLoop
      end if
   end if
   
   local tScript
   if gREVScript then  --SCRIPT
      if not gREVRegEx then
         put empty into tScript
         try
            put the script of pControl into tScript
         catch tJunk
         end try
         if gREVSearchTerm is in tScript then
            put pControl & return after lResult
            exit hPropertySearchRepeatLoop
         end if
      else
         if matchText(revMatchScript(pControl), gREVSearchTerm) then
            put pControl & return after lResult
            exit hPropertySearchRepeatLoop
         end if
      end if
   end if
   
   local tPropList
   if gREVOtherProperties then--OTHER PROPERTIES
      switch gREVOtherPropertiesSearchType
         case "all other object properties" --ALL OTHERS
            put "cREV" & word 1 of pControl & "PropertyNames" into tPropList
            # OK-2009-01-29
            repeat for each line n in the tPropList of stack "revSearch"
               if matchString(the n of pControl, gREVSearchTerm, gREVRegEx, gREVCaseSensitive) then
                  put pControl & return after lResult
                  exit repeat
               end if
            end repeat
            
            exit hPropertySearchRepeatLoop
         break
         case "specific property"--SPECIFIC
            put "cREV" & word 1 of pControl & "PropertyNames" into tPropList
            if gREVSpecificProperty is in the tPropList of stack "revSearch" then
               # OK-2009-01-29
               if matchString(the gREVSpecificProperty of pControl, gREVSearchTerm, gREVRegEx, gREVCaseSensitive) then
                  put pControl & return after lResult
                  exit hPropertySearchRepeatLoop
               end if
               
            else
               exit hPropertySearchRepeatLoop
            end if
         break
      end switch
   end if
   
   if gREVCustomProperties then --CUSTOM PROPERTIES - SET NAMES, KEYS NAMES, CONTENTS
      repeat for each line customKeyLine in the customKeys of pControl --DEFAULT SET
         if matchString(customKeyLine, gREVSearchTerm, gREVRegEx) then 
            put pControl & return after lResult
            exit hPropertySearchRepeatLoop
         end if
         
         local tValue
         put the customKeyLine of pControl into tValue
         if tValue is an array then
            get matchArray(tValue, gREVSearchTerm, gREVRegEx)
         else
            get matchString(tValue, gREVSearchTerm, gREVRegEx)
         end if
         
         if it then
            put pControl & return after lResult
            exit hPropertySearchRepeatLoop
         end if
      end repeat
      
      repeat for each line customPropertySetLine in the customPropertySets of pControl --SET NAMES
         
         if matchString(customPropertySetLine, gREVSearchTerm, gREVRegEx) then
            put pControl & return after lResult
            exit hPropertySearchRepeatLoop
         end if
         
         if matchString(customKeys[customPropertySetLine] of pControl, gREVSearchTerm, gREVRegEx) then --KEY NAMES INSIDE SETS
            put pControl & return after lResult
            exit hPropertySearchRepeatLoop
         end if
         
         local tContents
         repeat for each line customKeyLine in customKeys[customPropertySetLine] of pControl --CONTENTS OF KEYS INSIDE SETS
            
            # OK-2008-09-11 : Bug 7158
            -- do "put the" && customPropertySetLine & "[" & quote & customKeyLine & quote & "] of l into tContents"
            do "put the" && customPropertySetLine & "[" & quote & customKeyLine & quote & "] of pControl into tContents"
            if tContents is an array then
               
               # OK-2009-01-29 : Bug 7158 - Search array and just return the custom property for now.
               if matchArray(tContents, gREVSearchTerm, gREVRegEx) then
                  put pControl & return after lResult
                  exit hPropertySearchRepeatLoop
               else if gREVSearchTerm is in tContents then
                  put pControl & return after lResult
                  exit hPropertySearchRepeatLoop
               end if
            end if
         end repeat
      end repeat
   end if
   
end hPropertySearchRepeatLoop

on hAnimateIndeterminate
  if the currentFrame of image "indeterminate" of stack "revSearch" is not 8 then
    set the currentFrame of image "indeterminate" of stack "revSearch" to (the currentFrame of image "indeterminate" of stack "revSearch" +1)
  else
    set the currentFrame of image "indeterminate" of stack "revSearch" to 1
  end if
end hAnimateIndeterminate

on revAdjustText
  
end revAdjustText

function revMatchScript pObject
  local tScript
  
  local tWorkAround
  try
    put the script of pObject into tScript
  catch tJunk
    put empty into tWorkAround
  end try
  replace "\" & return with empty in tScript
  replace "\" && return with empty in tScript
  return tScript
end revMatchScript




