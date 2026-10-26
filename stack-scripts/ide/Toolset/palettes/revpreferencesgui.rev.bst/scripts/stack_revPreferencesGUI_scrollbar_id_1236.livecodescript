script "stack_revPreferencesGUI_scrollbar_id_1236"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "RevOnline" (id 1014) > group "revOnline" (id 1223) > group "Cache options" (id 1229) > scrollbar "Cache validity" (id 1236)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

getProp cThumbPosition
   return the thumbPosition of me * 1024
end cThumbPosition

setProp cThumbPosition pPosition
   set the thumbPosition of me to pPosition div 1024
end cThumbPosition
