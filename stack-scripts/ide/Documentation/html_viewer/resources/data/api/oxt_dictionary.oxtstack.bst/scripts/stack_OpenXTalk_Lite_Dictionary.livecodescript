script "stack_OpenXTalk_Lite_Dictionary"
-- Stack file: ide/Documentation/html_viewer/resources/data/api/oxt_dictionary.oxtstack
-- Object: stack "OpenXTalk Lite Dictionary"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on resizeStack twidth,theight
   if not (the pendingmessages contains "tStackResizer") then send tStackResizer to me in 1 millisecond
   if twidth <722 then
      -- nope, reached limit
      set the width of this stack to 723
      if not (the pendingmessages contains "tStackResizer") then send tStackResizer to me in 1 ticks
   end if
   
   if theight <363 then
      -- nope, reached vert limit
      set the height of this stack to 364
      if not (the pendingmessages contains "tStackResizer") then send tStackResizer to me in 1 ticks
   end if
   
   pass resizeStack
end resizeStack

on tStackResizer
   lock screen
   if the width of this stack >722 then
      set the rect of fld "tEntries" to the topleft of fld "tEntries", the width of this stack -16, the bottom of fld "tEntries"
      set the rect of fld "styledTextField" to the topleft of fld "styledTextField", the width of this stack -16, the height of this stack -16
      set the right of btn "searchBtn" to the width of this stack -16
      set the right of fld "searchFld" to the left of btn "searchBtn"
      set the loc of group "groupdrag" to item 1 of the loc of fld "tEntries", item 2 of the loc of group "groupdrag"
      set the bottom of btn "export" to the bottom of fld "styledTextField"
      set the bottom of btn "load random" to the bottom of fld "styledTextField"
      set the topright of btn "favaddbtn" to the right of fld "styledTextField" -5 -(the scrollbarwidth of fld "styledTextField"), the top of fld "styledTextField" +5
      set the rect of fld "notes" to the bottomleft of fld "noteheader", item 3 of the rect of fld "notes", the top of btn "export" -16
      --
      if the platform contains "linux" then
         show graphic "wdsizenote"
         set the loc of graphic "wdsizenote" to the width of this stack /2, the height of this stack /2
         set the label of graphic "wdsizenote" to "(" & the width of this stack & "," & the height of this stack & ")"
      end if
   end if
   unlock screen
   if the mouse is down then send tStackResizer to me in 1 millisecond
   if the mouse is up then
      hide graphic "wdsizenote"
   end if
end tStackResizer


on openstack
   -- should we make the stack editable or not?
   put specialfolderpath("engine") into tAppDir
   put the filename of this stack into tThisStackDir
   if tThisStackDir contains tAppDir then
      -- we are inside the engine folder
      set the cantmodify of this stack to true
   else
      -- we are outside the engine folder
      set the cantmodify of this stack to false
   end if
   
   hSortTheming
end openstack

on hSortTheming
   -- support theming of answer dialogs
   -- tperry 13-09-2025
   put "50,50,50" into tDarkGrey-- very dark grey
   put "225,225,255" into tLightGrey-- very light grey
   
   if the cUseThemeDark of stack "revPreferences" is true then
      -- dark mode
      set the backgroundColor of this stack to tDarkGrey
      -- now correct buttons
      put 0 into tcount
      repeat the number of buttons of this stack
         add 1 to tcount
         put the id of button tcount of this stack into tID
         set the foregroundColor of btn id tID of this stack to black
         if the platform contains "mac" then
            if the height of btn id tID of this stack <50 then 
               set the backgroundColor of btn id tID of this stack to "86,84,93"
               set the style of btn id tID to "roundRect"
               set the borderWidth of btn id tID to 0
               set the foregroundColor of btn id tID of this stack to white
               if the default of btn id tID of this stack is true then set the backgroundColor of btn id tID of this stack to "48,113,250"
            end if
         else
            if the height of btn id tID of this stack <50 then 
               set the backgroundColor of btn id tID of this stack to ""
               set the style of btn id tID to "roundRect"
               set the borderWidth of btn id tID to 0
               set the foregroundColor of btn id tID of this stack to ""
            end if
         end if
      end repeat
   else
      -- light mode
      set the backgroundColor of this stack to ""
      -- now correct buttons
      put 0 into tcount
      repeat the number of buttons of this stack
         add 1 to tcount
         put the id of button tcount of this stack into tID
         set the foregroundColor of btn id tID of this stack to ""
         set the backgroundColor of btn id tID of this stack to ""
         if the height of btn id tID <40 then set the borderWidth of btn id tID to 2
         if the height of btn id tID <40 then set the style of btn id tID to "standard"
         
      end repeat
   end if
   set the style of btn "favcaption" to transparent
   set the borderWidth of btn "favcaption" to 0
   
end hSortTheming
