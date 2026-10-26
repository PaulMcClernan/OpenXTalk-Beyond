script "stack_revSETemplate_group_id_55230"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSETemplate" > card "Templates" (id 2609) > group "Breakpoint Template" (id 55230)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on itemInit pInfo
   local tObject, tType, tLineOrVariable, tState, tCondition, tHandler, tActualState, tMessage
   
   get urlDecode(pInfo)
   
   put line 1 of it into tType
   put line 2 of it into tState
   put line 3 of it into tObject
   put line 4 of it into tLineOrVariable
   put line 5 of it into tHandler
   put line 6 of it into tCondition
   put line 7 of it into tMessage
   put line 8 of it into tActualState
   
   set the cObject of me to tObject
   set the cCondition of me to tCondition
   set the cType of me to tType
   
   local tLine, tVariable
   if tType is "breakpoint" then
      put tLineOrVariable into tLine
      put empty into tVariable
   else if tType is "watch" then
      put tLineOrVariable into tVariable
      put empty into tLine
   end if
   
   set the cLine of me to tLine
   set the cVariable of me to tVariable
   set the cHandler of me to tHandler
   
   set the hilite of button "Enabled" of me to (tState is "active")
   
   # Breakpoints may have an actual state different to their user specified state,
   # e.g because the line they are on has been commented out etc.
   if tType is "breakpoint" then
      set the icon of button "Icon" of me to getBreakpointImage(tActualState, tType)
   else
      set the icon of button "Icon" of me to getBreakpointImage(tState, tType)
   end if
   
   set the tooltip of button "Icon" of me to tMessage
   set the tooltip of field "Details" of me to tMessage
   
   local tText
   if tType is "breakpoint" then
      put makeFriendly(tObject) & ": line " & tLine & space into tText
   else
      put makeFriendly(tObject) & ": " & tHandler & " / " & tVariable & space into tText
   end if
   
   if tCondition is empty then
      put "no condition" into tCondition
   end if
   put "(" & tCondition & ")" after tText
   set the text of field "Details" of me to tText
   
   resize
end itemInit

command itemUnhilite
   if seGetPlatform() is not "MacOS" then
      set the backgroundColor of field "Details" of me to "255,255,255"
   end if
   set the textColor of field "Details" of me to "0,0,0"
end itemUnhilite

command itemHilite
   # OK-2009-03-11 : Bug 7499
   local tHiliteColor
   put sePrefGet("editor,hiliteColor") into tHiliteColor
   if tHiliteColor is empty then
      put the hiliteColor into tHiliteColor
   end if
   
   if tHiliteColor is empty then
      put "210,210,210" into tHiliteColor
   end if
   
   if seGetPlatform() is not "MacOS" then
      set the textColor of field "Details" of me to "255,255,255"
   end if
   set the backgroundColor of field "Details" of me to tHiliteColor
end itemHilite

# Description
#   Sent by the parent when this object might be been resized.
#   Updates the controls to reflect the current rect of the object.
command resize
   local tRightMargin
   put 20 into tRightMargin
   set the left of button "Enabled" of me to the left of me
   set the left of button "Icon" of me to the right of button "Enabled" of me
   set the rect of field "Details" of me to (the right of button "Icon" of me), (item 2 of the rect of field "Details" of me), min(the right of button "Icon" of me + the formattedWidth of field "Details" of me, (the right of me - the width of button "Edit" of me - tRightMargin)), (item 4 of the rect of field "Details" of me)
   set the left of button "Edit" of me to the right field "Details" of me
end resize

private function makeFriendly pObject
   try
      # Can be empty for global variable watches
      if pObject is empty then
         return "Global variable"
      else
         return the name of pObject
      end if
   end try
end makeFriendly
  
private function getBreakpointImage pState, pType
   if pType is "breakpoint" then
      if pState is "active" then
         return seGetIcon("gutterActiveBreakpoint")
      else
         return seGetIcon("gutterInactiveBreakpoint")
      end if
   end if
   
   if pType is "watch" then
      if pState is "active" then
         return seGetIcon("breakpointsActiveWatch")
      else
         return seGetIcon("breakpointsInactiveWatch")
      end if
   end if
end getBreakpointImage

getProp cState
   if the hilite of button "Enabled" of me then
      return "active"
   else
      return "inactive"
   end if
end cState

on mouseUp
   if the long id of the target is not long id of button "Enabled" of me then
      pass mouseUp
   end if
   
   set the icon of button "Icon" of me to getBreakpointImage(the cState of me, the cType of me)
   pass mouseUp
end mouseUp

