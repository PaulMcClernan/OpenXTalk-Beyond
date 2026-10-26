script "stack_revSEDebugEntryDialog_group_id_1018"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSEDebugEntryDialog" > card (id 1002) > group "Parameter Template" (id 1018)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

command itemInit pDetails
   set the cParameterObject of me to true
   
   local tName
   put item 1 of pDetails into tName
   if tName is "no parameters" then
      set the text of field "Overlay" of me to "No parameters available"
      set the visible of field "Overlay" of me to true
      set the visible of field "Name" of me to false
      set the visible of field "Value" of me to false
   else
      set the visible of field "Overlay" of me to false
      set the visible of field "Name" of me to true
      set the visible of field "Value" of me to true
      put tName & ": " into field "Name" of me
      set the cName of field "Name" of me to tName
      put item 2 to -1 of pDetails into field "Value" of me
   end if
   resize
end itemInit

private command resize
   # If any objects are invisible, move them off screen (in case the showInvisibles is true)
   if the visible of field "Name" of me then
      set the topLeft of field "Name" of me to the topLeft of me
   else
      set the right of field "Name" of me to -500
   end if
   
   if the visible of field "Value" of me then
      set the width of field "Value" of me to the width of me - the width of field "Name" of me - getScrollbarWidth()
      set the topLeft of field "Value" of me to the topRight of field "Name" of me
   else
      set the right of field "Value" of me to -500
   end if
   
   if the visible of field "Overlay" of me then
      set the rect of field "Overlay" of me to the rect of me
   else
      set the right of field "Overlay" of me to -500
   end if
end resize

getProp cName
   local tName
   lock messages
   put the cName of field "Name" of me into tName
   unlock messages
   
   return tName
end cName

getProp cValue
   return the text of field "Value" of me
end cValue
