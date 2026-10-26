script "stack_aboutstack_button_id_1011"
-- Stack file: ide/Toolset/palettes/about.oxtstack
-- Object: stack "aboutstack" > card "id 1002" (id 1002) > button "Release Notes" (id 1011)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
   put the short name of this stack into tDestStack
   send tOpenReleaseNotes to card "Automatic Updates" of stack "revPreferencesGUI"
   set the destroyStack of stack tDestStack to true
   close stack tDestStack
end mouseup
