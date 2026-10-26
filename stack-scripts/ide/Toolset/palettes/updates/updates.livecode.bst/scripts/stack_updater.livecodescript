script "stack_updater"
-- Stack file: ide/Toolset/palettes/updates/updates.livecode
-- Object: stack "updater"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preopenstack
   -- should the updates window be shown or hidden
   if the cUpdateCheckSilent of stack "revPreferences" is true then
      hide this stack
   else
      show this stack
   end if
   -- put the window at the bottom right of the screen
   put the title of this stack into tStackTitle
   if tStackTitle is "Automatic Updates" then
      put the itemdelimiter into tOldDelims
      hide cd btn "whatschanged"
      set the itemdelimiter to ","
      put item 3 of the screenrect, item 4 of the screenrect into tBottomRight
      subtract 10 from item 1 of tBottomRight
      subtract 20 from item 2 of tBottomRight
      if the platform contains "mac" then
         -- we make more allowances for MacOS here...
         -- (how do we know how big the dock might be?)
         -- let's guess!
         subtract "86" from item 2 of tBottomRight
      end if
      
      set the itemdelimiter to tOldDelims
      set the bottomRight of stack "updater" to tBottomRight
      --
      set the cantmodify of this stack to true
      set the hilite of btn "insecure" of cd 1 of stack "updater" to false -- default to https mode
      hide cd btn "insecure" of cd 1 of stack "updater"
      set the icon of btn "miniIcon" to 210111
      
   end if
end preopenstack


on closestack
   -- just makes sure this stack is removed from memory
   put the title of this stack into tStackTitle
   if tStackTitle is "Automatic Updates" then
      set the destroyStack of this stack to true
      pass closestack
   end if
end closestack
