script "stack_revSETemplate_group_id_54422"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSETemplate" > card "Main" (id 1002) > group "Editor" (id 1046) > group "Enter Password" (id 54422)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the long id of the target is the long id of button "Unlock" of me then
      unprotectRequest
   end if
end mouseUp

on returnInField
   unprotectRequest
end returnInField

on enterInField
   unprotectRequest
end enterInField

private command unprotectRequest
   local tObject
   getObject
   put the result into tObject
   
   local tStack
   put revTargetStack(tObject) into tStack
   
   try
      set the passKey of stack tStack to the cValue of field "Password" of me
   end try
   
   local tUnlocked
   put false into tUnlocked
   try
      get the script of stack tStack
      put true into tUnlocked
   end try
   
   if tUnlocked then
      displayError empty
      unprotectScript
   else
      displayError "Incorrect password, please try again"
   end if
end unprotectRequest

private command unprotectScript
   lock screen
   loadScript
   resize
   scriptUnlock
   unlock screen
   
   # OK-2010-02-11: Bug 8548 - The handler list on the left will be empty if the script was password protected,
   # as we've now unlocked the script, we need to update the list.
   seUpdateLeftBar
end unprotectScript

private command displayError pError
   set the textColor of field "Error" of me to "240,0,0,"
   put pError into field "Error" of me
end displayError

command openControl
   focus on field "Password" of me
   select before field "Password" of me
end openControl
