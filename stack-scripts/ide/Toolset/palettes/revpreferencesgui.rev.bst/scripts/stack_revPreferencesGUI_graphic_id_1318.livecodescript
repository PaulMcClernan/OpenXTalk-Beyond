script "stack_revPreferencesGUI_graphic_id_1318"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Mobile Support" (id 1254) > group "iOS SDKs" (id 1261) > graphic "SDK Status" (id 1318)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   if the tooltip of me is not empty then
      answer warning the tooltip of me
   end if
end mouseUp
