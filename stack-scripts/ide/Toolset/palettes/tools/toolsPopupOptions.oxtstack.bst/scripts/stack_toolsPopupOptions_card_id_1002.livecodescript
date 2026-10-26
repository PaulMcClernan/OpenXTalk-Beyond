script "stack_toolsPopupOptions_card_id_1002"
-- Stack file: ide/Toolset/palettes/tools/toolsPopupOptions.oxtstack
-- Object: stack "toolsPopupOptions" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


-- update the views for the tools palette
-- revIDESetPreference "revTools_columns", 3 -- (why does this crash the IDE?)

on tUpdateViews -- read what is currently turned on or off
   put the revTools_show of stack "revPreferences" into tShownOptions
   -- can return:
   -- paintcontrols,graphictoolscontrols,classic,graphictools,runedit,graphic,paint,widget
   replace "," with return in tShownOptions
   -- we have to do a bit of juggling here
   -- why? because they have historically been labelled too closely with conflicting names
   replace "graphictoolscontrols" with "gruphic_tools_controls" in tShownOptions
   replace "graphictools" with "gruphic-tools" in tShownOptions
   replace "gruphic_tools_controls" with "gruphictoolscontrols" in tShownOptions -- more juggling(!)
   replace "paintcontrols" with "paint-controls" in tShownOptions
   replace "paint" with "p8int" in tShownOptions
   --put tShownOptions -- debug
   put 0 into tBtnCount
   repeat the number of buttons of group "tBtnOptions" of this card
      add 1 to tBtnCount
      put the short name of button tBtnCount of group "tBtnOptions" of this card into tBtnName
      repeat the number of lines of tShownOptions
         if tShownOptions contains tBtnName then
            set the hilite of btn tBtnName of group "tBtnOptions" to true
         else
            set the hilite of btn tBtnName of group "tBtnOptions" to false
         end if
      end repeat
      --
   end repeat
   
   -- now update the options to show how many columns we are using
   put the revTools_columns of stack "revPreferences" into tPrevSetColCount
   if isNumber(tPrevSetColCount) then
      if tPrevSetColCount is "2" then send mousedown to btn "twoCol" of group "colGroup"
      if tPrevSetColCount is "3" then send mousedown to btn "threeCol" of group "colGroup"
      if tPrevSetColCount is "4" then send mousedown to btn "fourCol" of group "colGroup"
      if tPrevSetColCount is "8" then send mousedown to btn "eightCol" of group "colGroup"
      if tPrevSetColCount is "16" then send mousedown to btn "sixteenCol" of group "colGroup"
      if tPrevSetColCount > 16 or tPrevSetColCount is "5" or tPrevSetColCount is "6" or  tPrevSetColCount is "7" then send mousedown to btn "OtherCol" of group "colGroup"
   end if
   if not(isNumber(tPrevSetColCount)) then send mousedown to btn "twoCol" of group "colGroup" -- assume 2 column if nothing set
   --
   -- end column check
   
   -- section names visible?
   if the cToolsSectionNames of stack "revPreferences" is true then
      set the hilite of btn "sectionNames" to true
   else
      set the hilite of btn "sectionNames" to false
   end if
   
   set the blendlevel of this stack to 0
   set the isViewing of this stack to true
end tUpdateViews

on tSaveToolViews -- save and apply the current tool selections
   set the blendlevel of this stack to 99
   if there is a stack "revTools" then
      -- store the position of revTools
      put the topleft of stack "revTools" into tStoredToolsTL
      set the cStoredToolsTL of this stack to tStoredToolsTL
   end if
   set cursor to busy
   lock screen
   put 0 into tBtnCount
   put "" into tToolOptionsToSave
   repeat the number of buttons of group "tBtnOptions" of this card
      add 1 to tBtnCount
      put the short name of button tBtnCount of group "tBtnOptions" of this card into tBtnName
      if the hilite of btn tBtnName of group "tBtnOptions" is true then
         put tBtnName into line (the number of lines of tToolOptionsToSave +1) of tToolOptionsToSave
      end if
   end repeat
   filter lines of tToolOptionsToSave without empty
   -- set the names back to something the other handlers understand
   replace "gruphic-tools" with "graphictools" in tToolOptionsToSave
   replace "paint-controls" with "paintcontrols" in tToolOptionsToSave
   replace "p8int" with "paint" in tToolOptionsToSave
   replace return with comma in tToolOptionsToSave
   --put tToolOptionsToSave -- debug
   
   --if the shiftkey is down then put tToolOptionsToSave -- debug
   
   put "revIDESetPreference " & QUOTE & "revTools_show" & QUOTE & ",  " & QUOTE & tToolOptionsToSave & QUOTE into tString
   do tString
   put the tSelectedColumn of group "colGroup" into cSelectedColumns
   if isNumber(cSelectedColumns) then
      put "revIDESetPreference " & QUOTE & "revTools_columns" & QUOTE & ", " & QUOTE & cSelectedColumns & QUOTE into tString
      do tString
   end if
   
   -- save sectionNames setting
   if the hilite of button "sectionNames" is true then
      set the cToolsSectionNames of stack "revPreferences" to true
   else
      set the cToolsSectionNames of stack "revPreferences" to false
   end if
   
   revIDETogglePalette "tools" -- hide
   revIDETogglePalette "tools"  -- show
   --set the destroystack of stack "revTools" to true
   --close stack "revTools"
   --revIDESetPreference "revTools_show", tToolOptionsToSave
   --open stack "revTools"
   unlock screen
   
   send tRestoreToolsLoc to me in 10 ticks
end tSaveToolViews

on closestack
   set the blendlevel of this stack to 0
   set the isViewing of this stack to false
   pass closestack
end closestack

on tRestoreToolsLoc
   if there is a stack "revTools" then
      -- store the position of revTools
      put the cStoredToolsTL of this stack into tStoredToolsTL
      set the topleft of stack "revTools" to tStoredToolsTL
   end if
  close this stack
end tRestoreToolsLoc
   
on opencard
   send tUpdateViews to this card
end opencard

