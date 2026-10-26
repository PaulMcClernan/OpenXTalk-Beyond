script "stack_revPreferencesGUI_card_id_1015"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Compatibility" (id 1015)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


local isError
on opencard
   if the platform contains "linux" then
      tCheckDeps
      --
      show cd fld "if you" of this card
      show group "deps" of this card
      show group "depbit" of this card
      --
   else
      -- we aren't linux, so set things as success (assume win and mac has deps)
      set the hilite of cd btn "Success" to true
      set the backgroundcolor of graphic "deps-rect" to 73,165,0
   end if
   
   -- are we raising palettes?
   if the CRaisePalettes of stack "revPreferences" is true then
      set the raisePalettes to true
      set the hilite of btn "tPalWD" of this card to true
   else
      set the raisePalettes to false
      set the hilite of btn "tPalWD" of this card to false
   end if
   
   -- are we raising windows?
   if the CRaiseWindows of stack "revPreferences" is true then
      set the raiseWindows to true
      set the hilite of btn "tRaiseWD" of this card to true
   else
      set the raiseWindows to true
      set the hilite of btn "tRaiseWD" of this card to false
   end if
   
end opencard

on preopencard
   --
   hide cd fld "if you" of this card
   hide group "deps" of this card
   hide group "depbit" of this card
   --
   send "initialise" to group "Compatibility Options"
   tAllBtnsToFalse
end preopencard

on tCheckDeps
   put "" into field "output"
   lock screen
   put false into isError
   if the platform contains "linux" then
      set the hideConsoleWindows to true
      put the number of buttons of group "deps" this card into tbtnCount
      put 0 into tCount
      repeat tbtnCount
         set cursor to busy
         add 1 to tCount
         put the short name of btn tCount of group "deps" of this card into tPkg
         if tPkg is "test" then 
            --
         else
            tCheckDep(tPkg)
         end if 
      end repeat
      filter lines of field "output" without empty
   end if
   if isError is false then
      set the hilite of cd btn "Success" to true
      set the backgroundcolor of graphic "deps-rect" to 73,165,0
   else
      set the hilite of cd btn "Success" to false
      set the backgroundcolor of graphic "deps-rect" to 255,0,0
      set the hilite of btn "disPlayerLin" to true
      set the cDisablePlayerTool of stack "revPreferences" to true -- disable player tool
   end if
   unlock screen
   set the vScroll of field "output" to 0
end tCheckDeps

on tCheckDep tDep
   if the platform contains "linux" then
      put tDep into tEscaped
      replace "." with "\." in tEscaped
      put "/sbin/ldconfig -p | grep -q '" & tEscaped & "' && echo installed || echo not-installed" into tTermOut
      put shell(tTermOut) into tTermOut
      put tDep && tTermOut after field "output"
      
      if there is a btn (tDep) then
         if tTermOut contains "not-installed" then
            -- not installed
            put true into isError
            set the hilite of btn (tDep) of group "deps" to false
         else
            -- is installed
            set the hilite of btn (tDep) of group "deps" to true
         end if
      end if
   end if
end tCheckDep

on tAllBtnsToFalse
   if the platform contains "linux" then
      set cursor to busy
      lock screen
      set the hilite of cd btn "Success" to false
      set the backgroundcolor of graphic "deps-rect" to 255,0,0
      put the number of buttons of group "deps" of this card into tbtnCount
      put 0 into tCount
      repeat tbtnCount
         add 1 to tCount
         put the short name of btn tCount of group "deps" of this card into tPkg
         if tPkg is "test" then 
            --
         else
            set the hilite of btn tPkg of group "deps" to false
         end if 
      end repeat
      unlock screen
   end if
end tAllBtnsToFalse

