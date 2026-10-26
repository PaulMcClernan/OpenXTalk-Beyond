script "stack_revResourceCenter_scrollbar_id_579801"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "SettinganRGBcolorchannelofanobject" (id 80392) > group "mainContent" (id 80407) > group (id 579804) > group "Example" (id 577022) > scrollbar "Green" (id 579801)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on scrollbarDrag newPosition
  set the greenChannel of graphic "Color Swatch" to newPosition
end scrollbarDrag
