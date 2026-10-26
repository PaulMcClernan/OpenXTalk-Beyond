script "stack_revSEDebugEntryDialog"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSEDebugEntryDialog"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

# Description
#   Called when the user presses the OK button. Saves changes and closes the dialog
command closeAccept
   applySettings
   set the cResult of me to "saved"
   close me
end closeAccept

# Description
#   Called when the user presses the Cancel button. Discards changes and closes the dialog
command closeReject
   set the cResult of me to "cancelled"
   close me
end closeReject

# Description
#   Called when the dialog is first opened. Sets up the dialog to reflect the current values of the
#   various properties that may affect it.
command update
   local tObject
   send "revSEGetCurrentObject" to the cCaller of me
   put the result into tObject
   
   # Obtain the handler list for the current object and put it into the Handler button.
   updateHandlerlist tObject
   
   # Get the current entry point handler (or select one as default), set the label of the Handler button appropriately
   updateCurrentHandler tObject
   
   # Work out what parameters the handler has and create controls to allow the user to fill in parameters to pass.
   # Get the saved parameter values if there any any and put them into the created controls.
   updateParameters tObject
end update

# Description
#   Called when the user clicks OK. Saves all the settings in this dialog as metadata on the appropriate object
command applySettings
   local tHandler
   put line (the menuHistory of button "Handler" of me) of the cHandlers of button "Handler" of me into tHandler
   
   local tParameters
   repeat with x = 1 to the number of groups of this card of me
      if not the cParameterObject of group x of this card of me then
         next repeat
      end if
      
      local tName, tValue
      put the cName of group x of this card of me into tName
      put the cValue of group x of this card of me into tValue
      
      put tName & comma & tValue & return after tParameters
   end repeat
   delete the last char of tParameters
   
   local tObject
   send "revSEGetCurrentObject" to the cCaller of me
   put the result into tObject
   
   revMetadataSet tObject, "general", "debugEntryHandler", tHandler
   revMetadataSet tObject, "general", "debugParameters", tParameters
end applySettings

on preOpenStack
   if the long id of the target is not the long id of this card of me then
      exit preOpenStack
   end if   
   update
end preOpenStack

on menuPick pItemName
   local tObject
   send "revSEGetCurrentObject" to the cCaller of me
   put the result into tObject
   updateParameters tObject
end menuPick

private command updateHandlerList pObject
   local tHandlers
   send "revSEGetHandlerList" to the cCaller of me
   put the result into tHandlers
   
   local tDisplayHandlers, tStoreHandlers
   repeat for each line tHandler in tHandlers
      # Private handlers must be filtered out as the debugger can't call them
      if char 1 of word 1 of tHandler is "P" then
         next repeat
      end if
      put word 2 of tHandler & return after tDisplayHandlers
      put word 1 tHandler & comma & word 2 of tHandler & return after tStoreHandlers
   end repeat
   delete the last char of tDisplayHandlers
   delete the last char of tStoreHandlers
   
   set the text of button "Handler" of me to tDisplayHandlers
   set the cHandlers of button "Handler" of me to tStoreHandlers
end updateHandlerList

private command updateCurrentHandler pObject
   local tHandler
   put revMetadataGet(pObject, "general", "debugEntryHandler") into tHandler
   if tHandler is empty or tHandler is not among the lines of the cHandlers of button "Handler" of me then
      put seDefaultEntryPoint(pObject) into tHandler
      if tHandler is empty then
         # This means there are no public handlers for the object. 
      end if
   end if
   
   set the label of button "Handler" of me to "tempLabel"
   set the wholeMatches to true
   local tLabel
   put line (lineOffset(tHandler, the cHandlers of button "Handler" of me )) of the text of button "Handler" of me into tLabel
   set the label of button "Handler" of me to tLabel
   set the wholeMatches to false
end updateCurrentHandler

private command updateParameters pObject
   local tHandler
   put line (the menuHistory of button "Handler" of me) of the cHandlers of button "Handler" of me into tHandler
   
   local tAvailableParameters
   put line 1 of the revAvailableVariables[tHandler] of pObject into tAvailableParameters
   --log "tAvailableParameters: " & tAvailableParameters
   
   local tParameters
   put revMetadataGet(pObject, "general", "debugParameters") into tParameters
   
   local tList
   repeat for each item tParameter in tAvailableParameters
      put item 1 of tParameter & comma after tList
      
      local tLineNumber
      put lineOffset(tParameter, tParameters) into tLineNumber
      if tLineNumber <> 0 then
         put item 2 to -1 of of line tLineNumber of tParameters after tList
      end if
      put return after tList
   end repeat
   delete the last char of tList
   
   --log "tList: " & tList
   
   ensureListObject
   set the cData of group "Parameter List" of me to tList
   send "update" to group "Parameter List" of me
   set the vScrollbar of group "Parameter List" of me to (the formattedHeight of group "Parameter List" of me > the height of group "Parameter List" of me)
end updateParameters

private command ensureListObject
   if there is a group "Parameter List" of me then
      delete group "Parameter List" of me
   end if
   
   local tObject
   copy group "List Template" of card "Templates" of the cCaller of me to me
   put the long id of it into tObject
   set the name of it to "Parameter List"
   set the cantDelete of tObject to false
   set the opaque of tObject to false
   set the rect of tObject to "24,125,372,230"
   set the lockLocation of tObject to true
   set the showBorder of tObject to false
   set the margins of tObject to 0
   set the scrollbarWidth of tObject to getScrollbarWidth()
   set the vScrollbar of tObject to false
   set the cItemTemplate of tObject to the long id of group "Parameter Template" of me
   
   local tPrefs
   put "marginLeft=5" & return & \
   "marginRight=5" & return & \
   "marginTop=10" & return & \
   "spacing=5" & return & \
   "justification=left" into tPrefs
   
   set the cPrefs of tObject to tPrefs
end ensureListObject

function seDefaultEntryPoint pObject
   local tHandlers
   send "revSEGetHandlerList" to the cCaller of me
   put the result into tHandlers
   
   local tBreakpoints
   put revDebuggerListBreakpoints(pObject) into tBreakpoints
   
   local tPublicHandlers, tPublicHandlersWithBreakpoints
   repeat for each line tHandler in tHandlers
      if char 1 of word 1 of tHandler is "P" then
         next repeat
      end if
      
      put word 1 of tHandler & comma & word 2 of tHandler & return after tPublicHandlers
      
      repeat for each line tBreakpoint in tBreakpoints
         local tLine
         put item -1 of tBreakpoint into tLine
         if tLine >= word 3 of tHandler and tLine <= word 4 of tHandler then
            put word 1 of tHandler & comma & word 2 of tHandler & return after tPublicHandlersWithBreakpoints
            exit repeat
         end if
      end repeat
   end repeat
   delete the last char of tPublicHandlers
   delete the last char of tPublicHandlersWithBreakpoints
   
   local tType
   put word 2 of the name of pObject into tType
   
   local tStyle
   if tType is "button" then
      put the style of pObject into tStyle
   end if
   
   local tDefaultEntry
   put defaultEntryPointForObjectType(tType, tStyle) into tDefaultEntry
   
   # If we have handlers with breakpoints in, we choose one of them, ideally the default entry (e.g. mouseup for a push button)
   if tPublicHandlersWithBreakpoints is not empty then
      if tDefaultEntry is not empty and tDefaultEntry is among the lines of tPublicHandlersWithBreakpoints then
         return tDefaultEntry
      else
         return line 1 of tPublicHandlersWithBreakpoints
      end if
   end if
   
   # Otherwise either the default entry if it exists, or the first handler in the list
   if tDefaultEntry is not empty and tDefaultEntry is among the lines of tPublicHandlers then
      return tDefaultEntry
   else
      return line 1 of tPublicHandlers
   end if
   
   # This means there were no public handlers.
   return empty
end seDefaultEntryPoint

private function defaultEntryPointForObjectType pType, pStyle
   switch pType
      case "button"
         switch pStyle
            case "menu"
               return "M,menuPick"
            break
            default
               return "M,mouseUp"
         end switch
      break
      default
         return empty
   end switch
end defaultEntryPointForObjectType

function getScrollbarWidth
   return 20
end getScrollbarWidth

on enterKey
   closeAccept
end enterKey

on returnKey
   closeAccept
end returnKey

on escapeKey
   closeReject
end escapeKey
