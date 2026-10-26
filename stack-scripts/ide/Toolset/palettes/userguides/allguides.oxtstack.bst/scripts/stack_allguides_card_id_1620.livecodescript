script "stack_allguides_card_id_1620"
-- Stack file: ide/Toolset/palettes/userguides/allguides.oxtstack
-- Object: stack "allguides" > card "Release Notes" (id 1620)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on opencard
   put the short name of this stack into tCloseMe
   send tOpenReleaseNotes to card "Automatic Updates" of stack "revPreferencesGUI"
   close stack tCloseMe
end opencard
