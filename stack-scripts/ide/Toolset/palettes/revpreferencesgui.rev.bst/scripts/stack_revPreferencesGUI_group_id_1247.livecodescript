script "stack_revPreferencesGUI_group_id_1247"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Compatibility" (id 1015) > group "Compatibility Options" (id 1247)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on initialise
   -- load in settings for disabling the player
   if the cDisablePlayerTool of stack "revPreferences" is true then
      set the hilite of btn "disPlayerLin" of cd "Compatibility" to true
   else
      set the hilite of btn "disPlayerLin" of cd "Compatibility" to false
   end if
   -- load in settings for the menubar offset
   if the cTweakMenuBarOffset of stack "revPreferences" is true then
      set the hilite of btn "cMenuBarOffset" of cd "Compatibility" to true
   else
      set the hilite of btn "cMenuBarOffset" of cd "Compatibility" to false
   end if
   -- and the offsets
   if the cTweakMenuBarL of stack "revPreferences" is "" then
      put "0" into fld "tweakL" of cd "Compatibility"
   else
      put the cTweakMenuBarL of stack "revPreferences" into fld "tweakL"  of cd "Compatibility"
   end if
   if the cTweakMenuBarT of stack "revPreferences" is "" then
      put "0" into fld "tweakR" of cd "Compatibility"
   else
      put the cTweakMenuBarT of stack "revPreferences" into fld "tweakR"  of cd "Compatibility"
   end if
   -- load other options
   -- Browser Widget
   if the cDisableBrowserWidget of stack "revPreferences" is true then
      set the hilite of btn "disBrowserWidget" of cd "Compatibility" to true
   else
      set the hilite of btn "disBrowserWidget" of cd "Compatibility" to false
   end if
   -- data grids
   if the cDisableDataGrid of stack "revPreferences" is true then
      set the hilite of btn "disDataGrid" of cd "Compatibility" to true
   else
      set the hilite of btn "disDataGrid" of cd "Compatibility" to false
   end if
   -- desktop hiding
   set the hilite of btn "ClickDesktopHide" to the cDesktopClickToHide of stack "revPreferences"
   
end initialise









