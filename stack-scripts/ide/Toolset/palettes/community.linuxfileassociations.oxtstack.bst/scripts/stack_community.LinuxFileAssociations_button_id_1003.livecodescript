script "stack_community.LinuxFileAssociations_button_id_1003"
-- Stack file: ide/Toolset/palettes/community.linuxfileassociations.oxtstack
-- Object: stack "community.LinuxFileAssociations" > card (id 1002) > button "Don't show this again" (id 1003)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   if the hilite of me is true then
      set the hilite of me to false
      set the cDontShowFileAssociationsDialog of stack "revPreferences" to false
   else
      set the hilite of me to true
      set the cDontShowFileAssociationsDialog of stack "revPreferences" to true
   end if
end mousedown
