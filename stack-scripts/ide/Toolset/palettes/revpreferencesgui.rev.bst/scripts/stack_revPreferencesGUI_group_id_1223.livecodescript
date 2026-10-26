script "stack_revPreferencesGUI_group_id_1223"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "RevOnline" (id 1014) > group "revOnline" (id 1223)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

# Description
#   Updates all controls in this group to reflect the current revOnline Pref settings
command update
   # OK-2009-01-31 : Bug 7673 - If revOnline has not been launched since startup,
   # Its preferences system will not have been loaded and revOnlinePrefGet will return
   # the defaults instead of the current settings. Because the revOnline prefs system
   # always keeps the preferences stack up to date, we know that calling revOnlinePrefLoad
   # here should be safe.
   revOnlinePrefLoad
   
   repeat with x = 1 to the number of controls of me
      if the cPref of control x of me is empty then
         next repeat
      end if
      
      local tValue
      put revOnlinePrefGet(the cPref of control x of me) into tValue
      setValue the long id of control x of me, tValue
   end repeat
   
   local tCacheSize
   put revOnlineCacheSize() into tCacheSize
   put tCacheSize div 1024 into tCacheSize
   set the text of field "Cache size" of me to tCacheSize & "KB"
   set the enabled of button "Clear" of me to (tCacheSize <> 0)
   set the enabled of button "Sign in automatically" to (revOnlinePrefGet("rememberEmail") is true)
end update

# Description
#   Sets all revOnline prefernces to match the values in the controls in this group
command setPrefs
   repeat with x = 1 to the number of controls of me
      if the cPref of control x of me is empty then
         next repeat
      end if
      
      local tValue
      put getvalue(the long id of control x of me) into tValue
      revOnlinePrefSet the cPref of control x of me, tValue
   end repeat
end setPrefs

# Parameters
#   pTarget : reference to a control in this group
# Returns
#   The value of the preference setting that the specified control
#   currently represents.
private function getValue pTarget
   local tPropname
   put the cProperty of pTarget into tPropname
   
   local tValue
   put the tPropname of pTarget into tValue
   return tValue
end getValue
  
# Parameters
#   pTarget : reference to a control in this group
#   pValue : the value to set
# Description
#   Sets the value of the specified object to pValue. If pValue is empty,
#   then the value is set to the default value for the object's assigned preference.
private command setValue pTarget, pValue
   local tValue
   if pValue is not empty then
      put pValue into tValue
   else
      local tPref
      put the cPref of pTarget into tPref
      put revOnlinePrefGetDefault(tPref) into tValue
      put the result into tValue
   end if
   
   local tPropname
   put the cProperty of pTarget into tPropname
   
   # Special case for button labels due to engine bug
   if tPropname is "label" then
      set the label of pTarget to "tempLabel"
      if tValue is empty then
         set the label of pTarget to "Default"
      else
         set the label of pTarget to tValue
      end if
      exit setValue
   end if
   
   # Default case
   set the tPropname of pTarget to tValue
end setValue

private command applyPref pTarget
   if the cPref of pTarget is empty then
      exit applyPref
   end if
   
   local tValue
   put getValue(pTarget) into tValue
   revOnlinePrefSet the cPref of pTarget, tValue
end applyPref

on mouseUp
   if the word 1 of the name of the target is "button" and the style of the target is "radiobutton" then
      applyPref the long id of the owner of the target
   else
      applyPref the long id of the target
   end if
   update
end mouseUp

# OK-2009-01-31 : Bug 7673 - Sliders not working because there is nothing to handle the messages
# generated when they are moved.
on scrollbarDrag
   applyPref the long id of the target
end scrollbarDrag

command changePassword pOldPassword, pNewPassword
   # Check that the user is already logged in, if not, we should log them in first,
   # as we have their password already, this should be possible unless we don't know
   # their email address.
end changePassword
