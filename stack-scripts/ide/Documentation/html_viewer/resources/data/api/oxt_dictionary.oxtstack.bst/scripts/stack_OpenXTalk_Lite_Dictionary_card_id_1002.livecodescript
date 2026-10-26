script "stack_OpenXTalk_Lite_Dictionary_card_id_1002"
-- Stack file: ide/Documentation/html_viewer/resources/data/api/oxt_dictionary.oxtstack
-- Object: stack "OpenXTalk Lite Dictionary" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on opencard
   lock screen
   put the long name of this stack into tPath
   put "" into cd fld "notes"
   put "" into cd fld "favs"
   if word 1 of tPath is "stack" then delete word 1 of tPath
   replace QUOTE with "" in tPath
   set the itemdelimiter to slash
   delete last item of tPath
   -- conditional part of path, based on what dictionary syntax we select
   if the hilite of cd btn "langxtalk" is true then put "xtalk" into tDef
   if the hilite of cd btn "langbuilder" is true then put "builder" into tDef
   if the hilite of cd btn "langdatagrid" is true then put "datagrid" into tDef
   put tPath & slash & "exports" & slash & tDef & slash & "resaved" & slash into cd fld "path"
   -- end conditional
   tRegenerateIndex
   --put cd fld "path" & "mobileControlGet function.txt" into cd fld "path" -- chose this because it's the largest
   send mousedown to btn "load random" of this card -- random entry
   -- vert drag slider
   set the itemdelimiter to ","
   set the loc of group "groupdrag" to (the left of fld "tEntries" + (the width of fld "tEntries") /2, the bottom of fld "tEntries"+16)
   set the text of image "VertResizer" of group "groupdrag" to the text of image "raised-horiz.png" of cd 1 of stack "revIcons"
   -- first, we update the icons for the list we can see
   set the PassedNum of fld "tEntries" to 1
   set the VisibleLine of fld "tEntries" to 1
   -- sort out the fav icon, just to make sure
   put the ID of image "heart" of cd 1 of this stack into tHeartImg
   set the icon of cd btn "favaddbtn" to tHeartImg
   set the icon of cd btn "favcaption" to tHeartImg
   set the iconGravity of button "favcaption" to left
   -- make sure visible  icons in the list are updated
   send KeywordToIconForVisible to this card -- update the icons if needed
   --
   send hLoadFavs to this card in 1 millisecond -- load favourites
   unlock screen
end opencard


on hLoadFavs
   -- this is where our favourites come from
   if tForkName is empty or tForkName is "tForkName" then put "xtalk" into tForkName
   if the platform contains "linux" then put specialFolderPath("home") & slash & "." & tForkName & slash into tUserPrefsFolder
   if the platform contains "mac" then put specialFolderPath("Preferences") & slash & tForkName & slash into tUserPrefsFolder
   if the platform contains "win" then put specialFolderPath(0x001a) & slash & tForkName & slash into tUserPrefsFolder
   -- create folders & set properties
   put tUserPrefsFolder & "xTalkDictionary/" into tDictFolder
   create folder tDictFolder
   set the dictPath of cd fld "favs" to tDictFolder
   put tUserPrefsFolder & "xTalkDictionary/Favs/" into tDictFavsFolder
   create folder tDictFavsFolder
   set the dictFavPath of cd fld "favs" to tDictFavsFolder
   put tUserPrefsFolder & "xTalkDictionary/Notes/" into tDictNotesFolder
   create folder tDictNotesFolder
   set the dictNotePath of cd fld "notes" to tDictNotesFolder
   -- read favs (not calling it favourites or favorites due to different spellings)
   put tDictFavsFolder & "favitems.txt" into tfilename
   open file tfilename
   read from file tfilename until EOF
   put it into tFavNames
   close file tfilename
   set the dictFavFile of cd fld "favs" to tfilename
   put tDictFavsFolder & "favpaths.txt" into tfilename
   open file tfilename
   read from file tfilename until EOF
   put it into tFavpaths
   close file tfilename
   set the dictFavPathFile of cd fld "favs" to tfilename
   -- now populate the fav field & set properties
   put tFavNames into cd fld "favs"
   set the favPaths of cd fld "favs" to tFavpaths
end hLoadFavs

on tRegenerateIndex
   put cd fld "path" into tRegenInFolder
   put "tEntries" into tEntries
   set the itemdelimiter to SLASH
   delete last item of tRegenInFolder
   -- conditional part of path, based on what dictionary syntax we select
   if the hilite of cd btn "langxtalk" is true then put "xtalk" into tDef
   if the hilite of cd btn "langbuilder" is true then put "builder" into tDef
   if the hilite of cd btn "langdatagrid" is true then put "datagrid" into tDef
   --
   if the last item of tRegenInFolder is tDef then put tRegenInFolder & "resaved/" into tRegenInFolder
   set the defaultFolder to tRegenInFolder
   put the files into tTheFiles
   -- look for user additions / extra plugins to dictionary
   -- (I will expand upon this to also seek inside extensions within the IDE folder)
   put tRegenInFolder into tUserPluginFolder
   replace "resaved" with "plugins" in tUserPluginFolder
   create folder tUserPluginFolder
   if not (the last char of tUserPluginFolder is slash) then put tUserPluginFolder & slash into tUserPluginFolder
   set the defaultFolder to tUserPluginFolder -- set defaultfolder to plugins temporarily
   put the files into tPluginFiles
   set the defaultFolder to tRegenInFolder -- set the defaultfolder back
   filter lines of tPluginFiles without empty
   filter lines of tPluginFiles without ".*"
   sort lines of tPluginFiles ascending
   --
   put tTheFiles & return & tPluginFiles into tTheFiles -- merge files and plugins together in the list
   --
   filter lines of tTheFiles without empty
   filter lines of tTheFiles without ".*"
   sort lines of tTheFiles ascending
   -- put the number of lines in tTheFiles
   -- put tRegenInFolder
   delete the last item of tRegenInFolder
   -- OXT-Beyond: index.txt is no longer written into the install, which
   -- may be read-only (and on macOS is inside the signed app); nothing
   -- reads it
   -- read the substitutions file
   put tRegenInFolder & "/substitutions.txt" into tSubsFile -- some file systems cant handle these characters, so we replace them with this lookup data
   open file tSubsFile for read -- OXT-Beyond: the install may be read-only
   read from file tSubsFile until EOF
   filter lines of it without empty
   put it into tTheSubs
   close file tSubsFile
   put 0 into tcount
   put tTheFiles into tTheReplacedFiles
   set the itemdelimiter to TAB
   repeat the number of lines in tTheSubs
      add 1 to tcount
      --put item 1 of line tcount of tTheSubs into tFind
      --put the last item of line tcount of tTheSubs into tReplaceWith
      put the last item of line tcount of tTheSubs into tFind
      put item 1 of line tcount of tTheSubs into tReplaceWith
      replace TAB with return in tReplaceWith
      put line 1 of tReplaceWith into tReplaceWith
      --answer "finding: " & tFind & return & "replacing with: " & tReplaceWith -- debug
      if tFind is "DOLLAR" then
         replace (tFind & "_") with (tReplaceWith & "_") in tTheReplacedFiles
      else
         replace (tFind & " ") with (tReplaceWith & " ") in tTheReplacedFiles
      end if
   end repeat
   -- any other specific replacements that could trip up the dictionary?
   replace "DOLLAR keyword.txt" with "$ keyword.txt" in tTheReplacedFiles
   replace "slash constant.txt" with "/ constant.txt" in tTheReplacedFiles
   replace "slash operator.txt" with "/ operator.txt" in tTheReplacedFiles
   -- now we set custom props
   set the DICT_xTalk of fld tEntries to tTheFiles 
   set the DICT_xTalk_count of fld tEntries to the number of lines in tTheFiles 
   set the DICT_substitutions of fld tEntries to tTheSubs
   set the DICT_xTalk_Searchable of fld tEntries to tTheReplacedFiles 
   -- now we update the list of entries displayed (sets up for the icon replacer)
   put tTheReplacedFiles into tTheReplacedDisplay
   replace "command.txt" with "comentry" in tTheReplacedDisplay
   replace "constant.txt" with "constentry" in tTheReplacedDisplay
   replace "control.txt" with "contrentry" in tTheReplacedDisplay
   replace "expression.txt" with "exprentry" in tTheReplacedDisplay
   replace "function.txt" with "funcentry" in tTheReplacedDisplay
   replace "glossary.txt" with "glossentry" in tTheReplacedDisplay
   replace "handler.txt" with "hdlrentry" in tTheReplacedDisplay
   replace "iterator.txt" with "itarentry" in tTheReplacedDisplay
   replace "keyword.txt" with "keyentry" in tTheReplacedDisplay
   replace "library.txt" with "libentry" in tTheReplacedDisplay
   replace "message.txt" with "msgentry" in tTheReplacedDisplay
   replace "object.txt" with "objentry" in tTheReplacedDisplay
   replace "operator.txt" with "operentry" in tTheReplacedDisplay
   replace "property.txt" with "propentry" in tTheReplacedDisplay
   replace "statement.txt" with "stateentry" in tTheReplacedDisplay
   replace "type.txt" with "typentry" in tTheReplacedDisplay
   replace ".txt" with "" in tTheReplacedDisplay
   replace "control structure" with "controlstructentry" in tTheReplacedDisplay
   put tTheReplacedDisplay into fld tEntries
end tRegenerateIndex


-- this puts the icon at the start of the line, and trims the suffix
on keywordToIcon
   put the PassedNum of fld "tEntries" into tLine -- previously tried this as a function, but too much recursion error (macOS)
   if tLine is "" then exit keywordToIcon
   put "comentry,constentry,contrentry,exprentry,funcentry,glossentry,hdlrentry,itarentry,keyentry,libentry,msgentry,objentry,operentry,propentry,stateentry,typentry,controlstructentry" into tKeyTypes
   put "Command-Icon,Constant-Icon,Graphic-Icon,Text-Icon,Function-Icon,General-icon,handler.png,down-on.png,Keyword-Icon,Share-stack,Messages-Icon,Object-Icon,Operator-Icon,global-properties.png,next-statement-on.png,Plugin-icon,Graphic-Icon" into tIconNames
   put the last word of line tLine of cd fld "tEntries" into tKeyWord
   put the imagesource of char 1 of line tLine of field "tEntries" into tIcon
   if tKeyTypes contains tKeyWord then
      if tIcon is "" then
         -- icon unset, so set it
         put tKeyTypes into tKeyTemp
         replace "," with return in tKeyTemp
         put 0 into tKeyCount
         repeat the number of lines in tKeyTemp
            add 1 to tKeyCount
            if line tKeyCount of tKeyTemp is tKeyWord then exit repeat
         end repeat
         set the itemdelimiter to ","
         put item tKeyCount of tIconNames into tIconID
         put the ID of image tIconID of cd 1 of this stack into tImageSourceID
         -- put the ID of image tIconID of cd 1 of stack "revIcons" into tImageSourceID
         put "  " & line tLine of field "tEntries" into line tLine of field "tEntries"
         set the imagesource of char 1 of line tLine of field "tEntries" to tImageSourceID
         delete the last word of line tLine of field "tEntries"
      else
         -- already has icon
      end if
   else
      -- tKeyword made no sense
   end if
   
end keywordToIcon


on closecard
   tCleanupAll

end closecard

on tCleanupAll
   set the PassedNum of cd fld "tEntries" to ""
   put "" into cd fld "tEntries"
   set the DICT_xTalk of fld tEntries to "" 
   set the DICT_xTalk_count of fld tEntries to ""
   set the DICT_substitutions of fld tEntries to ""
   set the DICT_xTalk_Searchable of fld tEntries to "" 
   put "" into cd fld "styledTextField"
   put "" into cd fld "theText"
   put "" into cd fld "path"
   put "" into cd fld "searchFld"
   put "" into cd fld "notes"
   put "" into cd fld "favs"
   set the tFoundLines of fld "tDropSearches" to "" 
   -- choose the right syntax as default
   set the hilite of btn "langxtalk" to true
   set the hilite of btn "langbuilder" to false
   tCloseSearches
end tCleanupAll

on mousedown
      send tCloseSearches to this card
   pass mousedown
end mousedown

on tCloseSearches
   if the mouseloc is not within the rect of cd fld "tDropSearches" or the mouseloc is not within the rect of btn "searchBtn" then
      hide fld "tDropSearches"
      put "" into fld "tDropSearches"
   end if
end tCloseSearches

on KeywordToIconForVisible
   if the pendingmessages contains KeywordToIconForVisible then exit KeywordToIconForVisible
   put the PassedNum of fld "tEntries" into tOldNum
   put the VisibleLine of fld "tEntries" -3 into tLine
   put the tLinesShown of fld "tEntries" +3 into tRpt
   repeat tRpt
      if the imagesource of char 1 of line tLine of field "tEntries" is "" then send keywordToIcon to this card
      add 1 to tLine
      set the PassedNum of fld "tEntries" to tLine
   end repeat
   set the PassedNum of fld "tEntries" to tOldNum
end KeywordToIconForVisible


on linkClicked pLink
   if the number of chars in pLink <4 then
      repeat until the number of chars in pLink >4
         put pLink & " " into pLink
      end repeat
   end if 
   put pLink into fld "searchFld"
   send textchanged to fld "searchFld" in 1 millisecond
   -- put QUOTE & pLink & QUOTE
end linkClicked
