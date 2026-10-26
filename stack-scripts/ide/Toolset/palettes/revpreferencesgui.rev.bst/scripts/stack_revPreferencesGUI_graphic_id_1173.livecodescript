script "stack_revPreferencesGUI_graphic_id_1173"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Script Editor" (id 1010) > group "Script Editor" (id 1142) > graphic "Debug Background Swatch" (id 1173)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
   put "Debug Background Color" into tTargBtn
   put the menuHistory of button tTargBtn into tOldValue
   lock messages
   set the menuHistory of button tTargBtn to  1 -- set it away to anything
   unlock messages
   set the menuHistory of button tTargBtn to (the number of lines of button tTargBtn)
end mouseup

-- thanks to mwieder for this
-- for a tip I found at https://forums.livecode.com/viewtopic.php?t=11356
