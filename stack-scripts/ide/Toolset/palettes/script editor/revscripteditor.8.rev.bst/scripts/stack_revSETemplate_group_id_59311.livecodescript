script "stack_revSETemplate_group_id_59311"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSETemplate" > card "Main" (id 1002) > group "Disambiguator" (id 59311)
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
         get seGetIcon(tTag) into tIcon
         
         local tReference
         put getFriendlyObjectReference(item 4 to -1 of tSymbol) into tReference 
         
         put "<p><img src=" & tIcon & "></img> " & tReference & " / " & item 3 of tSymbol & "</p>" after tHtml
      else if tType is "variable" then
         put getFriendlyObjectReference(item 4 to -1 of tSymbol) into tReference
         put "<p><img src=" & "205297" & "></img> " & tReference & " / " & item 3 of tSymbol & "</p>" after tHtml
      end if
   end repeat
   
   set the htmlText of field 1 of me to tHtml
end update

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
