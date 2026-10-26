script "stack_revIDEProjectBrowser"
-- Stack file: ide/Toolset/palettes/project browser/revideprojectbrowser.livecode
-- Object: stack "revIDEProjectBrowser"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on resizestack
   lock screen
   if the visible of image "cover-square" of card "list" of this stack is true then 
      --set the rect of image  "cover-square" of card "list" of this stack to 0,the top of group "content" -1, the width of this stack, the height of this stack -20
      set the rect of image "cover-square" of card "list" of stack "revIDEProjectBrowser" to the rect of group "objectList" of card "list" of stack "revIDEProjectBrowser"
      if not(the pendingmessages contains "projBrowCover") then send projBrowCover to me in 2 ticks
   end if
   set the rect of group "content" of card 1 of me to the contentRect of me
   unlock screen
   pass resizestack
end resizestack

on preopenstack
   if the title of this stack contains "project browser" then
      hide image  "cover-square" of card "list" of this stack
      put the effective Backgroundcolor of this stack into tColourDecision
      put the itemDelimiter into tOldDelim
      set the itemDelimiter to ","
      put item 1 of tColourDecision + item 2 of tColourDecision + item 3 of tColourDecision into tMaxColValues
      -- put tMaxColValues -- debug
      if tMaxColValues <234 then
         -- I've decided to set UI to dark
         show image "cover-square" of card "list" of this stack
         set the rect of image "cover-square" of card "list" of stack "revIDEProjectBrowser" to the rect of group "objectList" of card "list" of stack "revIDEProjectBrowser"
         set the ink of group "content" to "blendExclusion"
         put the id of image "white-refresh" of card 1 of stack "revIcons" into tRefID
      else
         -- I've decided to set UI to light
         hide image "cover-square" of card "list" of this stack
         set the ink of group "content" to "srcCopy"
         put the id of image "dark-refresh" of card 1 of stack "revIcons" into tRefID
      end if
      -- set up refresh btn (tperry 28-4-24)
      set the layer of group "background" of cd "list" of stack "revIDEProjectBrowser" to bottom
      set the layer of btn "Refresh" of cd "list" of stack "revIDEProjectBrowser" to top
      set the icon of btn "refresh" of card "list" of stack "revIDEProjectBrowser" to tRefID
      set the style of btn "refresh" of card "list" of stack "revIDEProjectBrowser" to "transparent"
      set the bottom of btn "refresh" of card "list" of stack "revIDEProjectBrowser" to the top of group "content" of card "list" of stack "revIDEProjectBrowser" -4
   end if
   pass preopenstack
end preopenstack

on projBrowCover
   set the rect of image "cover-square" of card "list" of stack "revIDEProjectBrowser" to the rect of group "objectList" of card "list" of stack "revIDEProjectBrowser"
end projBrowCover
