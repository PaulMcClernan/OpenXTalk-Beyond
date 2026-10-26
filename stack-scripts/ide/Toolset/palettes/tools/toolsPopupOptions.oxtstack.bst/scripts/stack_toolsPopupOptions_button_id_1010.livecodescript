script "stack_toolsPopupOptions_button_id_1010"
-- Stack file: ide/Toolset/palettes/tools/toolsPopupOptions.oxtstack
-- Object: stack "toolsPopupOptions" > card (id 1002) > button "Save" (id 1010)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseup
   send tSaveToolViews to this card
   
   send tUpdBrowseCursors to stack "home" in 1 second
end mouseup
