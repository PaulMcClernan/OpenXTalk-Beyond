script "stack_OpenXTalk_Lite_Dictionary_field_id_1016"
-- Stack file: ide/Documentation/html_viewer/resources/data/api/oxt_dictionary.oxtstack
-- Object: stack "OpenXTalk Lite Dictionary" > card (id 1002) > field "tEntries" (id 1016)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local tUpdateIcons

on mousedown
   set the hilitedline of fld "favs" to none -- turn off any fav hilited lines
   lock screen
   send tCloseSearches to this card
   put the long name of this stack into tPath
   if word 1 of tPath is "stack" then delete word 1 of tPath
   replace QUOTE with "" in tPath
   set the itemdelimiter to slash
   delete last item of tPath
   -- conditional part of path, based on what dictionary syntax we select
   if the hilite of cd btn "langxtalk" is true then put "xtalk" into tDef
   if the hilite of cd btn "langbuilder" is true then put "builder" into tDef
   if the hilite of cd btn "langdatagrid" is true then put "datagrid" into tDef
   put tPath & slash & "exports" & slash & tDef & slash & "resaved" & slash into tfilename
   --
   put the hilitedLine of me into tLine
   put line tLine of the DICT_xTalk of me into tShortFilename
   set the PassedNum of fld "tEntries" to tLine -- store the clicked line
   put tfilename & tShortFilename into tfilename
   put tfilename into cd fld "path"
   --
   if there is a file tfilename then
      open file tfilename for "UTF-8" text read -- OXT-Beyond: the install may be read-only, and the entries are UTF-8 (entry)
      read from file tfilename until EOF
      put it into tData
      close file tfilename
      put tData into cd fld "thetext" -- so now we have the data in our card... now comes the formatting
      --put cd fld "thetext" -- debug out
      send keywordToIcon to this card -- give the listing an icon
      send tFormatEntry to button "load random"
      set the hilitedline of cd fld "tEntries" to tLine -- restore selection of line
   else
      -- can't read file
      -- see if it exists in the plugins?
      put cd fld "path" into tUserPluginFolder
      replace "resaved/" with "plugins/" in tUserPluginFolder
      put tUserPluginFolder into cd fld "path"
      put tUserPluginFolder into tfilename
      -- now recheck, and if not, give up
      if there is a file tfilename then
         open file tfilename for "UTF-8" text read -- OXT-Beyond: the install may be read-only, and the entries are UTF-8 (plugin entry)
         read from file tfilename until EOF
         put it into tData
         close file tfilename
         put tData into cd fld "thetext" -- so now we have the data in our card... now comes the formatting
         send keywordToIcon to this card -- give the listing an icon
         send tFormatEntry to button "load random"
         set the hilitedline of cd fld "tEntries" to tLine -- restore selection of line
      else
         -- still can't find file, even after looking in the plugins folder - so it's probably been deleted between now and the index being generated(?)
      end if
   end if
   send KeywordToIconForVisible to this card -- update the icons if needed
   unlock screen
end mousedown


on scrollbarDrag newValue
   if the pendingmessages contains scrollbarDrag then exit scrollbarDrag
   put newValue div the textHeight of me + 1 into tLine  -- get current line number
   set the VisibleLine of fld "tEntries" to tLine
   if the mouse is down then
      if not (the pendingmessages contains "scrollBarCheck") then send scrollBarCheck to me in 1 millisecond
   end if
   if the mouse is up then 
      put true into tUpdateIcons
      --
      if not (the pendingmessages contains "scrollBarRelease") then 
         send scrollBarRelease to me in 1 milliseconds
      end if
      --
   else
      put false into tUpdateIcons
   end if
end scrollbarDrag


on scrollBarCheck
   if the mouse is up then
      put true into tUpdateIcons
      scrollBarRelease
   else
      send scrollBarCheck to me in 2 milliseconds
   end if
end scrollBarCheck

on scrollBarRelease
   lock screen
   if tUpdateIcons is true then
      send KeywordToIconForVisible to this card -- update the icons if needed
      put false into tUpdateIcons
   end if
   unlock screen
end scrollBarRelease
