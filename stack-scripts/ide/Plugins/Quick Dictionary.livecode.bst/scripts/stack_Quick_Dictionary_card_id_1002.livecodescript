script "stack_Quick_Dictionary_card_id_1002"
-- Stack file: ide/Plugins/Quick Dictionary.livecode
-- Object: stack "Quick Dictionary" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on openCard 
   -- if the dictionary is open, then close it
   put "Dictionary" into tStackToClose
   if there is a stack (tStackToClose) then
      set the destroystack of stack (tStackToClose) to true
      close stack (tStackToClose)
      wait 1 second
   end if
   --
   --open dictionary v9.6.3+ sqlite db
   local tPath
   put specialFolderPath("engine") &"/Documentation/html_viewer/resources/data/api/api.sqlite" into tPath
   if the platform contains "mac" then replace "/MacOS/" with "/Tools/" in tPath -- allowances for MacOS here
   set the cConnID of this card to revOpenDatabase("sqlite",tPath)  --sqlite db connection id > custom prop
   choose browse tool  --run mode arrow
   if the visible of fld "Cerca" then select text of fld "Cerca"  --insert cursor
   else select text of fld "Cerca2"  --insert cursor
   pass openCard
end openCard

on preopencard
   set the cantmodify of this stack to false
   -- assess if we are dark or light mode
   put the effective Backgroundcolor of this stack into tColourDecision
   put the itemDelimiter into tOldDelim
   set the itemDelimiter to ","
   put item 1 of tColourDecision + item 2 of tColourDecision + item 3 of tColourDecision into tMaxColValues
   -- put tMaxColValues -- debug
   if tMaxColValues <234 then
      -- in dark mode
      show image  "cover-square" of card 1 of this stack
      set the rect of image  "cover-square" of card 1 of this stack to the rect of group "risultati"
      set the ink of group "risultati" to "blendExclusion"
   else
      --  in light mode
      hide image  "cover-square" of card 1 of this stack
      set the ink of group "risultati" to "srcCopy"
   end if
   set the backgroundColor of graphic "bnder" of this card to the cToolSelectorColor of stack "revPreferences"
end preopencard

on closeStack
   local tID
   put the cConnID of this card into tID  --custom property
   set the defaultcursor to 0
   try
      if isNumber(tID) then  -- handle any DB closing connection errors (hopefully)
         set the cantmodify of this stack to true
         revCloseDataBase(tID)
         -- Handle any error
         if pError contains "Invalid connection ID" then
            -- Invalid connection ID error occurred
            -- put "Invalid connection ID error: " & pError -- debug
         end if
         put "" into tID
         set the cConnID of this card to ""
      end if
   end try
   put "" into cd fld "testo"
   pass closeStack
end closeStack


on resizestack
   if the visible of image "flip-up" of this card is false then
      -- we are in expanded view
      set the rect of fld "cerca" to "105,14,285,37"
      set the rect of fld "cerca2" to the rect of fld "cerca"
      set the left of image "clear" to the right of fld "cerca" +5
      set the left of image "flip-down" to the right of image "clear" +5
      --
      if the height of this stack <463 then set the height of this stack to 463
      if the width of this stack <800 then set the width of this stack to 800
      --
      set the rect of group "risultati" of cd 1 of stack "Quick Dictionary" to "95,47," & the left of fld "testo" of cd 1 of stack "Quick Dictionary" -10, the height of this stack
      set the rect of image  "cover-square" of card 1 of this stack to the rect of group "risultati"
      set the rect of fld "testo" of cd 1 of stack "Quick Dictionary" to (the right of group "risultati" of card 1 of this stack +10),0,the width of this stack, the height of this stack
      --
      set the width of graphic "bnder" to the width of group "risultati"
      set the width of image "shading" to the width of group "risultati"
      set the topleft of this wd to the tOldTL of this wd
      set the left of graphic "bnder" to the left of fld "Cerca" -10
      set the left of image "shading" to the left of fld "Cerca" -10
   end if
   if the visible of image "flip-up" of this card is true then
      -- we are in compact view
      set the height of this stack to 46
      if the width of this stack >283 then set the width of this stack to 283
      --
      set the rect of fld "cerca" to "15,14,215,37"
      set the rect of fld "cerca2" to the rect of fld "cerca"
      set the left of image "clear" to the right of fld "cerca" +5
      set the left of image "flip-up" to the right of image "clear" +5
      --
      set the rect of group "risultati" of cd 1 of stack "Quick Dictionary" to "95,47," & the left of fld "testo" of cd 1 of stack "Quick Dictionary" -10, the height of this stack
      set the rect of image  "cover-square" of card 1 of this stack to the rect of group "risultati"
      set the rect of fld "testo" of cd 1 of stack "Quick Dictionary" to (the right of group "risultati" of card 1 of this stack +10),0,the width of this stack, the height of this stack
      --
      --set the topleft of this wd to the tOldTL of this wd
      set the rect of graphic "bnder" to the rect of this card
      set the backgroundColor of graphic "bnder" of this card to the cToolSelectorColor of stack "revPreferences"
      set the rect of image "shading" to the rect of grc "bnder"
      show image "shading"
      show graphic "bnder"
   end if
   set the left of btn "x" to the left of image "clear"
end resizestack
