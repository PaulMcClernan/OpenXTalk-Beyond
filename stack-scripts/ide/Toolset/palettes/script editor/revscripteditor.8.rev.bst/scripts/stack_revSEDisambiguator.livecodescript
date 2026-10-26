script "stack_revSEDisambiguator"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSEDisambiguator"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

command update
   local tSymbols
   put the cSymbols of me into tSymbols
   
   local tHtml
   repeat for each line tSymbol in tSymbols
      local tType
      put item 1 of tSymbol into tType
      
      if tType is "handler" then
         local tTag
         put getIconTagFromType(tType) into tTag
         
         local tIcon
         put seGetIcon(tTag) into tIcon
         
         local tReference
         put getFriendlyObjectReference(item 5 to -1 of tSymbol) into tReference 
         
         put "<p><img src=" & quote & tIcon & quote & "></img> " & tReference & " / " & item 3 of tSymbol & "</p>" after tHtml
      else if tType is "variable" then
         put getFriendlyObjectReference(item 4 to -1 of tSymbol) into tReference
         put "<p><img src=" & quote & "205297" & quote & "></img> " & tReference & " / " & item 3 of tSymbol & "</p>" after tHtml
      end if
   end repeat
   
   local tField
   put the long id of field "Symbols" of me into tField
   set the htmlText of tField to tHtml
   
   --   local tTopLeft
   --   put the topLeft of me into tTopLeft
   
   --   set the width of me to the formattedWidth of tField
   --   set the height of me to min(the formattedHeight of tField, the bottom of the cCaller of me - the top of me)
   --   set the topLeft of me to tTopLeft
   
   --   set the rect of tField to the rect of me
   set the vScrollbar of tField to (the formattedHeight of tField > the height of tField)
end update

--on mouseUp
--   if the long id of the target is the long id of field "Symbols" of me then
--      local tSymbol
--      put line (word 2 of the clickLine) of the cSymbols of me into tSymbol
--   end if

--   local tCallback
--   put the cCallback of me into tCallback
--   set the cResult of me to tSymbol
--   send tCallback to the cCaller of me
--end mouseUp

command closeAccept
   set the cResult of me to line (word 2 of the selectedLine of field "Symbols" of me) of the cSymbols of me
   close me
end closeAccept

command closeReject
   set the cResult of me to empty
   close me
end closeReject

function getFriendlyObjectReference pObject
   # Return the long name of the object, but make sure the stack is refered by name, rather than by filename.
   local tReference
   put the long name of pObject into tReference
   
   local tStack
   put revTargetStack(pObject) into tStack
   
   if the mainstack of stack tStack is not tStack then
      put the mainstack of stack tStack into tStack
   end if
   
   put quote & tStack & quote into word -1 of tReference
   return tReference
end getFriendlyObjectReference

function getIconTagFromType tType
   local tTag
   put "handler" into tTag
   switch tType
      case "PM"
         put "PrivateMessage" after tTag
      break
      case "PC"
         put "PrivateCommand" after tTag
      break
      case "PF"
         put "PrivateFunction" after tTag
      break
      case "M"
         put "Message" after tTag
      break
      case "F"
         put "Function" after tTag
      break
      case "S"
         put "Setprop" after tTag
      break
      case "G"
         put "Getprop" after tTag
      default
         return empty
   end switch
   
   return tTag
end getIconTagFromType

on preOpenStack
end preOpenStack

on openStack
end openStack

on preOpenCard
end preOpenCard

on openCard
end openCard
