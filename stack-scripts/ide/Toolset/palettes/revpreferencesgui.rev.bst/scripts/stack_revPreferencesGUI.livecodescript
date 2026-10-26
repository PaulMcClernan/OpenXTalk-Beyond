script "stack_revPreferencesGUI"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lAlreadyBeenOpened

on preOpenStack
   --   if the short name of the target is not the short name of me then
   --      exit preOpenStack
   --   end if
   
  send updPrefPath to field "Menu"
   # OK-2008-06-23 : Bug 6604 - Preferences GUI doesn't remember its location
   local tLoc
   put revIDEGetPreference("cPreferencesLoc") into tLoc
   
   local tMenubarStack
   put revIDEPaletteToStackName("menubar") into tMenubarStack
   
   --! TODO we need the screen the user has used the menubar on on mac not the screen the menubar is on
   local tScreenRect
   put revIDEStackScreenRect(tMenubarStack, true) into tScreenRect
   
   if tLoc is empty or tLoc is not within tScreenRect then
      set the loc of me to revIDEStackScreenLoc(tMenubarStack)
      revIDESetPreference "cPreferencesLoc", the loc of me
   else
      set the loc of me to tLoc
   end if
   
   if not lAlreadyBeenOpened then
      set the textFont of fld "Menu" of cd 1 to empty
      set the textHeight of fld "Menu" of cd 1 to 20
      put true into lAlreadyBeenOpened
   end if
   
   /*
   ## Bug 17034
   ## Restore the fixed-font-and-size settings that the stack was originally designed for
   ## The theming changes in 8 make text too large to fit in available space
   if the platform is "Linux" then
      set the theme of this stack to "legacy"
   else
      set the theme of this stack to "native"
   end if
   */
   set the theme of this stack to "native"
   
   
   ## Bug 11173
   ## Last opened pane is shown but item 1 in list selected.
   set the hilitedLines of fld "Menu" to lineOffset(the short name of this card,the text of field "menu")
   send "mouseUp" to fld "Menu"
   
   pass preOpenStack
end preOpenStack

on closeStack
   if the short name of the target is not the short name of me then
      exit closeStack
   end if
   
   revInternal__SavePreferences
end closeStack

# OK-2008-06-23 : Bug 6604 - Preferences GUI doesn't remember its location
on moveStack
   revIDESetPreference "cPreferencesLoc", the loc of me
end moveStack

private command log pMsg
   put pMsg & return after msg
end log

# OK-2008-05-28 
# Parameters
#   pSection : the name of the section of preferences to open
# Description
#   Switches to the specified section, as if the user had clicked in the navigation field on the left
command revPrefsGoSection pSection
   local tLineNumber
   put lineOffset(pSection, the text of field "Menu") into tLineNumber
   if tLineNumber = 0 then
      exit revPrefsGoSection
   end if
   
   set the hilitedLines of field "Menu" to tLineNumber
   --send "mouseUp" to field "Menu"
   send "sectionChange" to field "Menu"
end revPrefsGoSection

on mousedown
   global gREVCurrentWidget
   if the short name of the target is "scrollbar widget" then
      put the long id of the target into gREVcurrentWidget
      send "extensionInitialise" to stack "revWidgetTrackerLibrary"
      revStartMouse
   end if
end mousedown

on revUpdateAB
   if there is a stack "revApplicationOverview" then
      if the mode of stack "revApplicationOverview" is not 0 then
         send "revRetainStacks" to stack "revApplicationOverview"
         send "revInitAppBrowser" to stack "revApplicationOverview"
      end if
   end if
end revUpdateAB

# OK-2008-05-27 : New script editor changes
# Description
#   Updates all open script editors in response to their preferences changing
command updateOpenScriptEditors
   local tScriptEditors
   put revListScriptEditors() into tScriptEditors
   lock screen
   repeat for each line tScriptEditor in tScriptEditors
      send "revSEUpdate" to tScriptEditor
   end repeat
   unlock screen
end updateOpenScriptEditors

-- General fallback handlers

on closeField
  local tName
  put the short name of the target into tName
  set the tName of stack "revPreferences" to the text of the target
end closeField

on enterInField
  closeField
  select the text of the target
end enterInField

on returnInField
  enterInField
end returnInField

on tSortTheme
   -- tperry (removed all theming from this stack 8/11/23)
   
end tSortTheme
