script "stack_ReleaseNotes_button_id_1006"
-- Stack file: ide/Toolset/palettes/updates/ReleaseNotes.oxtstack
-- Object: stack "ReleaseNotes" > card (id 1002) > button "Close" (id 1006)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   put "" into cd fld "notes"
   put the short name of this stack into tCloseMe
   set the destroyStack of stack tCloseMe to true
   close stack tCloseMe
end mousedown
