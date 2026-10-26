script "stack_revNewScriptEditor_1_group_id_58997"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revNewScriptEditor 1" > card "Main" (id 1002) > group "Disambiguator" (id 58997)
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
         put getFriendlyObjectReference(item 4 to -1 of tSymbol) into tReference 
         
         put "<p><img src=" & quote & tIcon & quote & "></img> " & tReference & " / " & item 3 of tSymbol & "</p>" after tHtml
      else if tType is "variable" then
         put getFriendlyObjectReference(item 4 to -1 of tSymbol) into tReference
         put "<p><img src=" & quote & "205297" & quote & "></img> " & tReference & " / " & item 3 of tSymbol & "</p>" after tHtml
      end if
   end repeat
   
   local tField
   put the long id of field 1 of me into tField
   set the dontWrap of tField to true
   set the htmlText of tField to tHtml
   
   local tTopLeft
   put the topLeft of me into tTopLeft
   
   set the width of me to the formattedWidth of tField
   set the height of me to min(the formattedHeight of tField, the bottom of the cCaller of me - the top of me)
   set the topLeft of me to tTopLeft
   
   set the rect of tField to the rect of me
   set the vScrollbar of tField to (the formattedHeight of tField > the height of me)
end update

on mouseUp
   if the long id of the target is the long id of field 1 of me then
      local tSymbol
      put line (word 2 of the clickLine) of the cSymbols of me into tSymbol
   end if
   
   local tCallback
   put the cCallback of me into tCallback
   set the cResult of me to tSymbol
   send tCallback to the cCaller of me
end mouseUp

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
