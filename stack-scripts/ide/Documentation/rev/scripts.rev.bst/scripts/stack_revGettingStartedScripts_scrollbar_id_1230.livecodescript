script "stack_revGettingStartedScripts_scrollbar_id_1230"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Setting an RGB color channel of an object Example" (id 1223) > scrollbar "Red" (id 1230)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on scrollbarDrag newPosition
  set the redChannel of graphic "Color Swatch" to newPosition
end scrollbarDrag
