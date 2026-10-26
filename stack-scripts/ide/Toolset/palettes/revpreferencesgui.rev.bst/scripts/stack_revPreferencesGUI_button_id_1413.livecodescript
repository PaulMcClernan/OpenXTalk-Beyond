script "stack_revPreferencesGUI_button_id_1413"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Compatibility" (id 1015) > group "Compatibility Options" (id 1247) > button "cMenuBarOffset" (id 1413)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   -- either way, we want to store offsets
   set the cTweakMenuBarL of stack "revPreferences"  to fld "tweakL"
   set the cTweakMenuBarT of stack "revPreferences"  to fld "tweakR"
   -- but we only apply it if the button is clicked
   if the hilite of me is true then
      set the hilite of me to false
      set the cTweakMenuBarOffset of stack "revPreferences" to false
   else
      set the hilite of me to true
      set the cTweakMenuBarOffset of stack "revPreferences" to true
      send tMBOffset to me
   end if
end mouseUp


on tMBOffset
   if the hilite of btn "cMenuBarOffset" of card "Compatibility" is true then
      set the cTweakMenuBarL of stack "revPreferences"  to fld "tweakL"
      set the cTweakMenuBarT of stack "revPreferences"  to fld "tweakR"
      set the top of wd "revMenuBar" to the cTweakMenuBarT of stack "revPreferences" 
      set the left of wd "revMenuBar" to the cTweakMenuBarL of stack "revPreferences" 
   end if
end tMBOffset
