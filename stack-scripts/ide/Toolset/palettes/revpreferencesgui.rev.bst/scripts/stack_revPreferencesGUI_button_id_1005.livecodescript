script "stack_revPreferencesGUI_button_id_1005"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "General" (id 1002) > group "Navigation" (id 1003) > button "Reset Preferences to Defaults" (id 1005)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   Answer warning "Are you sure you want to reset your preferences to default? This cannot be undone" with "Reset" or "Cancel"
   if it is "Reset" then
      revInternal__ResetPreferences
      -- however, substitute with these instead (tperry)
      revIDESetPreference "revTools_show", "paintcontrols,graphictoolscontrols,classic,graphictools,runedit,graphic,paint"
      revIDESetPreference "revTools_columns", 2
      revIDESetPreference "cStartPageShow", false
      revIDESetPreference "cBackdropColor", "Gray40"
      revIDESetPreference "cToolSelectorColor", "Gray50"
      --
      updateIDEWithNewPreferences
   end if
end mouseUp

command updateIDEWithNewPreferences
   global gREVLastPaletteTopLeft, gREVTemplateMasterName, gREVProfileReadOnly, gREVAutoCreateProfiles
   lock messages
   lock screen
   
   put "Master" into fld "Default profile name" of cd "Property Profiles"
   send "closeField" to fld "Default profile name" of cd "Property Profiles"
   
   put empty into gREVTemplateMasterName
   put false into gREVProfileReadOnly
   put false into gREVAutoCreateProfiles
   
   set the httpProxy to empty
   
   set the topleft of stack "revTools" to 13,125
   
   set the hilite of  button "UI edit script" of cd "General" to false
   send "mouseUp" to  button "UI edit script" of cd "General"
   
   set the label of  button "Rulers" of cd "Appearance" to "Pixels"
   send "mouseUp" to  button "Rulers" of cd "Appearance"
   
   set the hilite of  button "Context menus work on Rev dev stacks" of cd "general" to false
   send "mouseUp" to  button "Context menus work on Rev dev stacks" of cd "general"
   
   set the hilite of  button "language names on properties" of cd "general" to false
   
   unhilite button "Hide Palettes" of cd "Script Editor"
   send "mouseUp" to  button "Hide Palettes" of cd "Script Editor"
   unhilite  button "Hide Message Box" of cd "Script Editor"
   send "mouseUp" to  button "Hide Message Box" of cd "Script Editor"
   unhilite  button "Hide errors" of cd "Script Editor"
   send "mouseUp" to  button "Hide errors" of cd "Script Editor" 
   
   set the hilite of  button "Notify me of stable releases" of cd "Updates" to true
   send "mouseUp" to  button "Notify me of stable releases" of cd "Updates"
   set the hilite of  button "Notify me of maintainence releases" of cd "Updates" to true
   send "mouseUp" to  button "Notify me of maintainence releases" of cd "Updates"
   set the hilite of  button "Notify me of beta releases" of cd "Updates" to true
   send "mouseUp" to  button "Notify me of beta releases" of cd "Updates"
   set the hilite of  button "Notify me of development releases" of cd "Updates" to true
   send "mouseUp" to  button "Notify me of development releases" of cd "Updates"
   
   set the hilite of  button "Show Revolution Stacks" of cd "general" to false
   send "mouseUp" to  button "Show Revolution Stacks" of cd "general"
   
   set the menuHistory of button "backdrop color" of cd "Appearance" to 2
   set the backgroundColor of grc "Backdrop Swatch" of cd "Appearance" to the label of  button "backdrop color" of cd "Appearance"
   set the cRevSetting of button "backdrop color" of cd "Appearance" to the label of  button "backdrop color" of cd "Appearance"
   set the backdrop to none
   send "revFullBar" to  button "View" of cd 1 of stack "revMenuBar"
   
   set the hilite of  button "opt edit script shortcut" of cd "general" to true
   send "mouseUp" to  button "opt edit script shortcut" of cd "general"
   
   set the menuHistory of button "selectionHandle color" of cd "Appearance" to 2
   set the backgroundColor of grc "Selection Handle Swatch" of cd "Appearance" to the label of  button "selectionHandle color" of cd "Appearance"
   set the cSelectionHandle of stack "revPreferences" to the label of  button "selectionHandle color" of cd "Appearance"
   set the selectionHandleColor to line 2 of button "selectionHandle color" of cd "Appearance"
   
   set the hilite of  button "destroyStack" of cd "Files & Memory" to false
   set the hilite of  button "don't remove" of cd "Files & Memory" to true
   set the hilite of  button "Remove from memory" of cd "Files & Memory" to false
   set the hilite of  button "ask" of cd "Files & Memory" to false
   send "mouseUp" to  button "don't remove" of cd "Files & Memory"
   
   put empty into gREVLastPaletteTopleft
   
   put empty into fld "external editor" of cd "general"
   
   set the grid to true
   hilite menuItem 15 of menu "view"
   put 2 into field "gridSize" of card "general" of me
   
   set the gridSize to 2
   
   local tLockMessages
   put the lockMessages into tLockMessages
   set the lockMessages to tLockMessages
   set the hilite of  button "add extension" of cd "Files & Memory" to true
   
   put empty into fld "external editor" of cd "general"
   
   send "preOpenCard" to cd 1
   
   
   local tHilitedLines
   put the hilitedLines of fld "Menu" of cd "general" into tHilitedLines
   set the hilitedLines of fld "Menu" of cd "general" to tHilitedLines
   unlock messages
   
   set the hilitedButton of grp "Options in Properties palettes are labeled with:" of cd "general" to 2
   send "revUpdateLanguageNamePref" to grp "Options in Properties palettes are labeled with:" of cd "general"
   
   set the menuHistory of  button "hypertext color" of cd "Appearance" to 3
   
   put 30 into fld "Num Recent Files" of cd "Files & Memory"
   set the hilitedButtonName of grp "Recent files Sort" of cd "Files & Memory" to "modification date"
   
   revVerboseDebug false
   
   # TH-08-01-2008: Part of fix for bug 5708, resetting preferences to defaults is now reflected in the
   # script text size and text height fields
   --set the cREVScriptSize of stack "revPreferences" to the effective textSize of field "script" of card "revScript" of stack "revTemplateScriptEditor"
   set the scriptTextSize to the cREVScriptSize of stack "revPreferences"
   
   # OK-2008-05-27 : New script editor changes
   send "revSEReloadPreferences" to revScriptEditorMain()
   
   updateOpenScriptEditors
   
   # OK-2007-12-12: Added ability to choose customization path
   local tRestartRequired
   put false into tRestartRequired
   if the cCustomizationPath of stack "revPreferences" is not empty then
      put true into tRestartRequired
   end if
   send "updateCustomizationPath" to group "Files & Memory" of card "Files & Memory"
   
   # OK-2008-05-27 : New script editor changes
   send "update" to group "Script Editor" of card "Script Editor"
   
   if the short name of this cd is "Application browser" then revRefreshABprefs
   revUpdateAB
   
   if the mode of stack "revVariableWatcher" is not 0
   then send "revUpdatePalette" to cd 1 of stack "revVariableWatcher"
   unlock screen
   
   # OK-2007-12-12
   if tRestartRequired then
      answer warning "Some settings have changed which require OXT-Beyond to be restarted" with "Later" or "Quit"
      if it is "Quit" then
         quit
      end if
   end if
end updateIDEWithNewPreferences
