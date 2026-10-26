script "stack_community.LinuxFileAssociations_card_id_1002"
-- Stack file: ide/Toolset/palettes/community.linuxfileassociations.oxtstack
-- Object: stack "community.LinuxFileAssociations" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on opencard
   if revIDEGetPreference("cDontShowFileAssociationsDialog") is not true then
      set the hilite of cd btn "Don't show this again" of cd 1 of this stack to false
   else
      set the hilite of cd btn "Don't show this again" of cd 1 of this stack to true
   end if
end opencard
