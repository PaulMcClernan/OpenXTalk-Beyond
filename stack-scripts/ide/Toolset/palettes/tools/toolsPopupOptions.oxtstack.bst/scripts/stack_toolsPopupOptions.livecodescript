script "stack_toolsPopupOptions"
-- Stack file: ide/Toolset/palettes/tools/toolsPopupOptions.oxtstack
-- Object: stack "toolsPopupOptions"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preopenstack
   if the title of this stack contains "toolsPopupOptions" then 
      set the cantmodify of this stack to true
      set the decorations of this stack to empty
      tPositionToolsPopup
   end if
end preopenstack

on tPositionToolsPopup
   -- work out where to position the window
   set the itemdelimiter to ","
   put item 3 of the screenrect into tScreenWidth
   put the width of stack "toolsPopupOptions" into tPopupWidth
   if the right of stack "revTools" > (tScreenWidth - tPopupWidth) then
      -- we popup on the right, but under
      set the left of stack "toolsPopupOptions" to the right of stack "revTools"
      set the top of stack "toolsPopupOptions" to the bottom of stack "revTools"
   else
      -- we popup on the right
      set the left of stack "toolsPopupOptions" to the right of stack "revTools"
      set the top of stack "toolsPopupOptions" to the top of btn "toolsOVERRIDEmenu" of cd 1 of stack "revTools" + the top of stack "revTools"
   end if
end tPositionToolsPopup
   
   
