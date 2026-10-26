script "stack_revSearch"
-- Stack file: ide/Toolset/palettes/revsearch.rev
-- Object: stack "revSearch"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

global gREVShowStacks

on preOpenStack
  put empty into field "search term" of stack "revSearch"
  put empty into field "feedback" of stack "revSearch"
  disable button "search" of stack "revSearch"
  set the thumbPosition of scrollbar "progress" of stack "revSearch" to 0
  disable scrollbar "progress" of stack "revSearch"
  set the hilitedButtonName of group "tabs" of stack "revSearch" to "name"
  put empty into field "type" of stack "revSearch"
  put empty into field "name" of stack "revSearch"
  put empty into field "card" of stack "revSearch"
  put empty into field "stack" of stack "revSearch"
  put empty into field "item info" of stack "revSearch"
  disable button "remove from list" of stack "revSearch"
  put empty into field "replace" of stack "revSearch"
  disable field "replace" of stack "revSearch"
  disable button "replace" of stack "revSearch"
  focus field "search term" of stack "revSearch"
  
  set the cName of stack "revSearch" to the hilite of button "name" of group "properties" of stack "revSearch"
  set the cScript of stack "revSearch" to the hilite of button "script" of group "properties" of stack "revSearch"
  set the cFieldText of stack "revSearch" to the hilite of button "field text" of group "properties" of stack "revSearch"
  set the cButtonContents of stack "revSearch" to the hilite of button "button contents" of group "properties" of stack "revSearch"
  set the cCustomProperties of stack "revSearch" to the hilite of button "custom properties" of group "properties" of stack "revSearch"
  set the cOtherProperties of stack "revSearch" to the hilite of button "all other object properties" of group "properties" of stack "revSearch"
  
  get the defaultFolder
  set the cDirectory of stack "revSearch" to it
  set the itemDel to "/"
  put the last item of it into field "folder" of stack "revSearch"
end preOpenStack

on revFeedBack
  
end revFeedBack

on escapeKey
   close this stack
end escapeKey

# OK-2009-01-29 : Bug 7158
# Searches pArray for pSearchString and returns whether or not its found
function matchArray pArray, pSearchString, pRegExp, pCaseSensitive
   # Array contains the string if its in one of the keys or one of the elements. Check the keys 
   # first...
   repeat for each key tKey in pArray
      if matchString(tKey, pSearchString, pRegExp, pCaseSensitive) then
         return true
      end if
   end repeat
   
   #...then check the elements, recursing if needed.
   repeat for each key tKey in pArray
      local tElement
      put pArray[tKey] into tElement
      if tElement is an array then
         if matchArray(tElement, pSearchString, pRegExp, pCaseSensitive) then
            return true
         end if
      else
         if matchString(tElement, pSearchString, pRegExp, pCaseSensitive) then
            return true
         end if
      end if
   end repeat
   
   return false
end matchArray

# OK-2009-01-29 : Refactored to avoid duplicating more code.
function matchString pString, pSearchString, pRegExp, pCaseSensitive
   if pCaseSensitive then
      set the caseSensitive to true
   end if
   
   if pRegExp then
      return matchText(pString, pSearchString)
   else
      return (pSearchString is in pString)
   end if
end matchString

