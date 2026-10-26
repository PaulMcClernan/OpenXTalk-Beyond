script "stack_allguides"
-- Stack file: ide/Toolset/palettes/userguides/allguides.oxtstack
-- Object: stack "allguides"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

----------------------------------------------------------------------------------------------------------------
-------------------------------- new 'all guides' stack by tperry (9-12-23) ----------------------------------
-- an effort to get the all guides away from an uneditable database into a native stack & card format --
----------------------------------------------------------------------------------------------------------------

-- to edit any of the pages, just shift-click the icon at the top-left of the window. This will display an editor
-- to add new cards, add them as normal and pick a new name
-- delete cards as you like
-- click on the list on the left to refresh it
-- no editing of scripts should be required to edit these guides.
-- I am trying to 'externalise' these as much as possible, putting the editing of this content back in the hands of everyone

global tRetainTitle

on openstack
   if there is a fld "helpTitle" then
      send tUpdTitle to btn "miniIcon"
      set the icon of btn "miniIcon" to 210111
   end if
   send resizestack to this stack
   tUpdDocPath
   pass openstack
end openstack

on preopenstack
   set the cantmodify of this stack to true
   put "Guides" into tRetainTitle
   set the tEditorOn of btn "miniIcon" to false
   send tRefreshIndex to fld "ClickList"
   send tRefreshLinkColour to this stack
   
end preopenstack

on resizestack
   if there is a stack "allguides" then
      lock screen
      if not (the pendingmessages contains "tResizeMe") then send tResizeMe to this stack in 1 ticks
      unlock screen
   end if
   pass resizeStack
end resizestack

on tResizeMe
   if there is a stack "allguides" then
      set the topleft of group "ttitle" to 0,0
      put "350" into tWidthOfList
      set the rect of fld "helpTitle" to the left of fld "helpTitle", the top of fld "helpTitle", the width of this wd -50, the top of fld "helpTitle" + 40
      put the height of this wd into tWDCur
      if tWDCur <170 then put 170 into tWDCur
      set the rect of fld "ClickList" to the left of fld "ClickList", the top of fld "ClickList", tWidthOfList, tWDCur +20 - the top of fld "ClickList"
      put the width of this stack - (the width of fld "ClickList" +15) into tScreenAvailableArea
      if the tEditorOn of btn "miniIcon" is false then
         hide fld "tLayout"
         show fld "tActualContent"
         set the rect of fld "tActualContent" to the width of fld "ClickList" +10, the top of fld "ClickList", (the width of fld "ClickList" +10) + tScreenAvailableArea, the bottom of fld "ClickList"
      else
         show fld "tLayout"
         set the rect of fld "tLayout" to (the width of this stack) - (tScreenAvailableArea /2), the top of fld "ClickList", the width of this stack -5, the bottom of fld "ClickList"
         set the rect of fld "tActualContent" to the width of fld "ClickList" +10, the top of fld "ClickList", (the width of fld "ClickList" +10) + tScreenAvailableArea /2, the bottom of fld "ClickList"
      end if
   end if
end tResizeMe


on opencard
   if the title of this stack contains "user guides" then
      send tRefreshIndex to fld "ClickList"
   end if
   -- update links as needed (if you use the word tdocpath in your card, then it needs refreshing)
   if fld "tLayout" contains "tdocpath" then
      send mouseleave to fld "tLayout" of this card
   end if
   pass opencard
end opencard

on tRefreshLinkColour
   -- set colour of links
   put the cREVHelpHiliteColor of stack "revPreferences" into tNavLinkColour
   set the linkColor of this stack to tNavLinkColour
   set the linkVisitedColor of this stack to tNavLinkColour
end tRefreshLinkColour

on tUpdDocPath
   -- make sure we have the path to the documentation stored
   set the itemDelimiter to "/"
   put item 1 to -3 of the filename of stack "home" & "/Documentation/linked_files" into tDocumentationPath
   set the tDocPath of this stack to tDocumentationPath
end tUpdDocPath
