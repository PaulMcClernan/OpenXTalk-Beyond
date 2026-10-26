script "stack_toolsPopupOptions_button_id_1028"
-- Stack file: ide/Toolset/palettes/tools/toolsPopupOptions.oxtstack
-- Object: stack "toolsPopupOptions" > card (id 1002) > group "colGroup" (id 1021) > button "otherCol" (id 1028)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local tNumPick

on mousedown
   lock screen
   put 0 into tColumnBtnCount
   repeat the number of buttons in group "colGroup"
      add 1 to tColumnBtnCount
      put the short name of button tColumnBtnCount of group "colGroup" into tBtnName
      set the hilite of btn tBtnName of group "colGroup" to false
   end repeat
   set the hilite of me to true
   put the tSelectedColumn of group "colGroup" into tNumPick
   if the mouseloc is within the rect of me then hAnswerColPick
   unlock screen
end mousedown

on hAnswerColPick
   if isNumber(tNumPick) then
      Ask "Please pick a number:" with tNumPick
      if it is cancel then exit hAnswerColPick
      put it into tNumPick
      if isNumber(tNumPick) then
         set the tSelectedColumn of group "colGroup" to tNumPick
      end if
   else
      put "2" into tNumPick
      send hAnswerColPick to me in 1 millisecond
   end if
end hAnswerColPick
