script "stack_community.LinuxFileAssociations"
-- Stack file: ide/Toolset/palettes/community.linuxfileassociations.oxtstack
-- Object: stack "community.LinuxFileAssociations"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preopenstack
   set the itemdelimiter to ","
   put item 3 of the screenrect /2, item 4 of the screenrect /2 -20 into tnewLoc
   set the loc of this stack to tnewLoc
   -- set up icon
   if there is a stack "revGeneralIcons" then
      put the id of image "oxt-l-64.png" of card 1 of stack "revGeneralIcons" into tNewIconID
   else
      put the id of image "noentry" of cd 1 of this stack into tNewIconID -- fallback icon
   end if
   set the icon of btn "tIcon" of cd 1 of this stack to tNewIconID
   set the left of btn "tIcon" of cd 1 of this stack to 24
   set the top of btn "tIcon" of cd 1 of this stack to 24
   -- end set up icon
   -- set up message
   put "Linux file associations" & return &¬
   "" & return &¬
   "Would you like to add file associations for .oxtstack files so that they open with this IDE? This will also place shortcuts in the 'Programming' category of the Application menu, also in the 'Open With' right-click menu." into cd fld "fMessage"
   -- set up formatting
   set the textStyle of cd fld "fMessage" to plain
   set the textSize of cd fld "fMessage" to ""
   set the textStyle of line 1 of cd fld "fMessage" to "bold"
   set the textSize of line 1 of cd fld "fMessage" to "18"
end preopenstack
