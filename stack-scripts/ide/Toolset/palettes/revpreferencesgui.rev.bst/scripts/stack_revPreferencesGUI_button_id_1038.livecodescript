script "stack_revPreferencesGUI_button_id_1038"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "General" (id 1002) > group "General" (id 1016) > button "StartCenterPref" (id 1038)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the cStartPageShow of stack "revPreferences" to the hilite of me
   if the hilite of me then
      enable button "ReloadStartCenter"
      enable button "startCenterClassicPref"
   else
      disable button "ReloadStartCenter"
      disable button "startCenterClassicPref"
   end if
end mouseUp
