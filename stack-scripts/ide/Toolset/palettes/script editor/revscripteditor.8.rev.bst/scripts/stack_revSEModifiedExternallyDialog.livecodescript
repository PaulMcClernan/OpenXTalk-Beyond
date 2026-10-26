script "stack_revSEModifiedExternallyDialog"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSEModifiedExternallyDialog"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
  set the loc of me to the screenLoc
  put formatObjects(the cObjects of me) into field 2 of me
end preOpenStack

private function formatObjects pObjectsList
   local tFormattedObjects
   repeat for each line tObject in pObjectsList
      put the name of tObject & return after tFormattedObjects
   end repeat
   delete the last char of tFormattedObjects
   return tFormattedObjects
end formatObjects

on mouseUp
   if the cAction of the target is not empty then
      set the cChoice of me to the cAction of the target
      close me
   end if
end mouseUp





