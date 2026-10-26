script "stack_toolsPopupOptions_button_id_1019"
-- Stack file: ide/Toolset/palettes/tools/toolsPopupOptions.oxtstack
-- Object: stack "toolsPopupOptions" > card (id 1002) > group "colGroup" (id 1021) > button "twoCol" (id 1019)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   lock screen
   put 0 into tColumnBtnCount
   repeat the number of buttons in group "colGroup"
      add 1 to tColumnBtnCount
      put the short name of button tColumnBtnCount of group "colGroup" into tBtnName
      set the hilite of btn tBtnName of group "colGroup" to false
   end repeat
   set the hilite of me to true
   set the tSelectedColumn of group "colGroup" to "2"
   unlock screen
end mousedown
