script "stack_revNewScriptEditor_1_group_id_57769"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revNewScriptEditor 1" > card "Templates" (id 2609) > group "Visualizer Template" (id 57769)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

setProp cName pName
   set the text of field "Name" of me to pName
end cName

getProp cName
   return the text of field "Name" of me
end cName

setProp cValue pValue
   set the text of field "Value" of me to pValue
end cValue

getProp cValue
   return the text of field "Value" of me
end cValue

command initialize
   disable button "Apply" of me
end initialize

local sReference

command setReference pReference
   put pReference into sReference
end setReference

command getReference
   return sReference
end getReference

on keyUp pKey
   if the long id of the focusedObject is the long id of field "Value" of me then
      enable button "Apply" of me
   end if
   pass keyUp
end keyUp

on backspaceKey
   if the long id of the focusedObject is the long id of field "Value" of me then
      enable button "Apply" of me
   end if
   pass backspaceKey
end backspaceKey

on deleteKey
   if the long id of the focusedObject is the long id of field "Value" of me then
      enable button "Apply" of me
   end if
   pass deleteKey
end deleteKey

on commandKeyDown pKey
   if (pKey is "X" and the long id of the focusedObject is the long id of field "Value" of me) or (pKey is "P") then
      enable button "Apply" of me
   end if
   pass commandKeyDown
end commandKeyDown

command resize
   set the width of field "Name" of me to the width of me
   set the topLeft of field "Name" of me to the topLeft of me
   set the rect of field "Value" of me to the left of me, the bottom of field "Name" of me + 5, the right of me, the bottom of me - 30
   set the bottomRight of button "Apply" of me to the right of me -5, the bottom of me - 4
end resize

private command applyValue
   local tObject, tValue
   put the long id of this stack into tObject
   put the text of field "Value" of me into tValue
   send "visualizationObjectSetValue tObject, tValue" to the cManager of me
   disable button "Apply" of me
   
   # This is sent in time in order to allow the execution contexts of this stack to be removed
   # from the call stack, otherwise they appear in the debugger, and the update shows the wrong vars.
   send "update" to the cManager of me in 0 milliseconds
end applyValue


on mouseUp
   if the short name of the target is "Apply" then
     applyValue
   end if
end mouseUp

on enterKey
   if the enabled of button "Apply" of me then
      applyValue
   else
      finalize
      close this stack
   end if
end enterKey

on enterInField
   if the enabled of button "Apply" of me then
      applyValue
   else
      finalize
      close this stack
   end if
end enterInField

command finalize
   local tObject
   put the long id of this stack into tObject
   send "visualizationObjectRemove tObject" to the cManager of me
end finalize

on closeStackRequest
   finalize
   pass closeStackRequest
end closeStackRequest
