script "stack_demos_card_id_1002"
-- Stack file: ide/Resources/Examples/demos.oxtstack
-- Object: stack "demos" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preopencard
   put the defaultfolder into myDefaultFold -- store old defaultFolder
   set the itemdelimiter to slash
   put item 1 to -5 of the filename of stack "revMenubar" & slash & "Resources" & slash & "Examples" into tFoldPath
   set the itemdelimiter to ","
   set the defaultfolder to tFoldPath
   set the storedPath of field "pickList" to tFoldPath
   put the files into myFiles
   set the defaultfolder to myDefaultFold -- restore defaultFolder
   -- now we clean up our file listing
   filter lines of myFiles with "*.oxtstack"
   filter lines of myFiles without ".*"
   filter lines of myFiles without "demos.oxtstack"
   replace ".oxtstack" with "" in myFiles
   --
   sort lines of myFiles ascending
   put myFiles into field "pickList"
   pass preopencard
end preopencard

on opencard
   if field "pickList" is "" then
      disable btn "Open" of this card
   else
      enable btn "Open" of this card
      select line 1 of fld "pickList"
   end if
   pass opencard
end opencard
