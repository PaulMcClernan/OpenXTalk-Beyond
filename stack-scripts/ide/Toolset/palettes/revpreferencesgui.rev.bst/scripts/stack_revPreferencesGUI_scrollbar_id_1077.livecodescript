script "stack_revPreferencesGUI_scrollbar_id_1077"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Appearance" (id 1008) > group "Appearance" (id 1062) > scrollbar "grid" (id 1077)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on scrollBarDrag x
  if fld (the cTargetField of me) is not an integer then pass scrollBarDrag
  put the endValue of me - x into fld (the cTargetField of me)
  set the gridSize to fld (the cTargetField of me)
  set the cGridSize of stack "revPreferences" to fld (the cTargetField of me)
end scrollBarDrag
