script "stack_revPreferencesGUI_field_id_1476"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Debug Properties" (id 1473) > group "propgroup" (id 1474) > field "search" (id 1476)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on keydown thekey
   -- take a guess when keys are pressed
   if not (the pendingmessages contains "tdosuggStr") then send tdosuggStr to me in 10 ticks
   pass keydown
end keydown

on rawkeydown thekey
   if thekey is "65288" then
      -- delete key pressed
      if not (the pendingmessages contains "tdosuggStr") then send tdosuggStr to me in 10 ticks
   end if
   pass rawkeydown
end rawkeydown
   
on tdosuggStr
   if the number of chars of cd fld "search" <2 then
      hide cd fld "suggestions"
   else
      -- this bit does the guessing
      put 0 into tborder
      if the visible of cd fld "suggestions" is true then hide cd fld "suggestions"
      set the rect of cd fld "suggestions" to the rect of cd fld "search"
      put cd fld "fPREFFS" into tlines
      put "*" & cd fld "search" & "*" into tstring
      filter lines of tlines with tstring
      filter lines of tlines without empty
      put tlines into cd fld "suggestions"
      -- work out new height
      set the fixedlineheight of cd fld "suggestions" to true
      put the textheight of cd fld "suggestions" into theight
      put the number of lines of tlines into tmatches
      put theight * tmatches + (the margins of cd fld "suggestions" /2) into tnewH
      -- visual fixes
      if tmatches >0 then put 8 into tborder
      if tmatches >4 then put 0 into tborder
      
      set the height of cd fld "suggestions" to tnewH + tborder
      set the topleft of cd fld "suggestions" to the bottomleft of cd fld "search"
      show cd fld "suggestions"
      if the height of cd fld "suggestions" <5 then 
         hide cd fld "suggestions"
      else
         --
      end if
   end if
end tdosuggStr

on deletekey
   delete last char of cd fld "search"
   -- refresh guesses when delete key is pressed too
   if not (the pendingmessages contains "tdosuggStr") then send tdosuggStr to me in 10 ticks
   pass deletekey
end deletekey
