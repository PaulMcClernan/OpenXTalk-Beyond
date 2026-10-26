script "stack_revPreferencesGUI_field_id_1418"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Compatibility" (id 1015) > group "Compatibility Options" (id 1247) > field "tweakL" (id 1418)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseEnter
   send tMBOffset to btn "cMenuBarOffset" of this card
end mouseEnter

on mouseLeave
   send tMBOffset to btn "cMenuBarOffset" of this card
end mouseLeave
