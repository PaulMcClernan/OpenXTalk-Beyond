script "stack_CustomScriptCol_graphic_id_1015"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > substack "CustomScriptCol" > card (id 1002) > graphic "bkgndSwatch" (id 1015)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
   local myColor
   answer color with (the backgroundColor of me)
   put it into myColor
   if myColor is empty or myColor is cancel then exit mouseup
   --
   set the backgroundColor of me to myColor
   put myColor into field "bkgndValue" of stack "CustomScriptCol"
   revIDESetPreference "cScriptEditor," & "editor,backgroundcolor", myColor
   revIDESetPreference "cScriptEditor," & "editor,debugBackgroundcolor", myColor
   updateOpenScriptEditors
   send getSEBkgndCol to button "update" of this stack
end mouseup
