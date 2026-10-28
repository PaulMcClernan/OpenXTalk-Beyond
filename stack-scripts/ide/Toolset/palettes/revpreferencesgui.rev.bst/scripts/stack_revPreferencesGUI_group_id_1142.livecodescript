script "stack_revPreferencesGUI_group_id_1142"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Script Editor" (id 1010) > group "Script Editor" (id 1142)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

constant kPropPrefix = "cScriptEditor,"

# Description
#   Updates all controls to reflect the current preference values
command update
   local tFontText
   
   put the fontNames into tFontText
   sort lines of tFontText
   repeat with tLine = 1 to the number of lines of tFontText
      if line tLine of tFontText begins with "(" then
         put "(" before line tLine of tFontText
      end if
   end repeat
   put "Default" & return & tFontText into tFontText
   set the text of button "Font" of me to tFontText
   
   repeat with x = 1 to the number of controls of me
      if the cPref of control x of me is empty then
         next repeat
      end if
      
      local tPropname
      put kPropPrefix & the cPref of control x of me into tPropname
      
      local tValue
      put the tPropname of stack "revPreferences" into tValue
      
      setValue the long id of control x of me, tValue
   end repeat
   
   updateSwatches
end update

command updateSwatches
   local tPropname
   put the cProperty of control "Background Color" of me into tPropname
   
   local tColor
   put the tPropname of control "Background Color" of me into tColor
   set the backgroundColor of graphic "Background Swatch" of me to tColor
   
   put the cProperty of control "Debug background color" of me into tPropname
   put the tPropname of control "Debug background color" of me into tColor
   set the backgroundColor of graphic "Debug background swatch" of me to tColor
end updateSwatches

# Parameters
#   pPref : the name of the preference to apply
#   pValue : the value to apply to the specified preference
# Description
#   Applies the specified value to the specified script editor preference.
private command applyPref pPref, pValue
   revIDESetPreference kPropPrefix & pPref, pValue
  
   updateOpenScriptEditors
end applyPref

# Parameters
#   pTarget : reference to a control in this group
# Returns
#   The value of the preference setting that the specified control
#   currently represents.
private function getValue pTarget
   local tPropname
   put the cProperty of pTarget into tPropname
   
   # Special case for radio buttons
   if the style of pTarget is "radiobutton" and tPropname is "hilite" then
      if word 1 of the name of the owner of pTarget is "group" then
         return the hilitedButtonName of the owner of pTarget
      else
         return the hilite of pTarget
      end if
   end if
   
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
      send "revSEGetDefaultPreference tPref" to revScriptEditorMain()
      put the result into tValue
   end if
   
   local tPropname
   put the cProperty of pTarget into tPropname
   
   -- OXT-Beyond: the saved default is a mode, never a literal color.
   if the cPref of pTarget is "editor,backgroundcolor" and tValue is "default" then
      sePrefInit
      put sePrefGet("editor,backgroundcolor") into tValue
   end if
   if the cPref of pTarget is "colorization,scheme" then
      if revIDEGetPreference("cScriptEditor,editor,backgroundcolor") is among the items of ",default" then
         put "Follow System Appearance" into tValue
      end if
   end if
   # Work around the engine's button-label update bug.
   if tPropname is "label" then
      set the label of pTarget to "tempLabel"
      if tValue is empty then
         set the label of pTarget to "Default"
      else
         set the label of pTarget to tValue
      end if
      exit setValue
   end if
   
   # Special case for radio buttons as all other radio buttons must be unhilited if grouped.
   if tPropname is "hilite" and the style of pTarget is "radiobutton" then
      if word 1 of the owner of pTarget is "group" then
         if pValue is the short name of pTarget then
            set the hilitedButtonName of the owner of pTarget to the short name of pTarget
         end if
      else
         set the hilite of pTarget to tValue
      end if
      exit setValue
   end if
   
   # Default case
   set the tPropname of pTarget to tValue
end setValue
  
on mouseUp
   if the cPref of the target is not empty then
      applyPref the cPref of the target, getValue(the long id of the target)
   end if
end mouseUp

on menuPick
   if the cPref of the target is not empty then
    applyPref the cPref of the target, getValue(the long id of the target)
  end if
end menuPick

command preferenceChanged pObject
   if the cPref of pObject is not empty then
      applyPref the cPref of pObject, getValue(the long id of pObject)
   end if
end preferenceChanged


# OK-2008-07-28 : Bug 6837
constant kMouseWheelUp = "65309"
constant kMouseWheelDown = "65308"
constant kMouseWheelIncrement = 30

on rawKeyDown pKey
   if pKey is kMouseWheelUp then
      set the vScroll of me to the vScroll of me - kMouseWheelIncrement
   else if pKey is kMouseWheelDown then
    set the vScroll of me to the vScroll of me + kMouseWheelIncrement 
   else
      pass rawKeyDown
   end if
end rawKeyDown
