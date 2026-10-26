script "stack_revStandaloneSettings_field_id_2883"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "General" (id 1002) > group "generalContent" (id 2882) > field "standalone name" (id 2883)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on closeField
   setStandaloneName the text of me
end closeField

local sLastText

# OK-2010-03-31: Updated this to perform a more consistent and thorough check.
on keyDown pKey
   put the text of me into sLastText
   pass keyDown
end keyDown

on keyUp pKey
   if revFolderNameIsIllegal(the text of me) then
      set the text of me to sLastText
      beep
      exit keyUp
   else
      pass keyUp
   end if
end keyUp

# OK-2010-03-31: Don't allow pasting of illegal names into field
on commandKeyDown pKey
   if pKey is "v" then
      local tText
      put the clipboardData["text"] into tText
      
      local tTruncated
      put false into tTruncated
      if the number of lines of tText > 1 then
         put line 1 of tText into tText
         put true into tTruncated
      end if
      
      if revFolderNameIsIllegal(tText) then
         put revFolderNameMakeLegal(tText) into me
         exit commandKeyDown
      else if tTruncated then
         put tText into me
         exit commandKeyDown
      end if
   end if
   
   pass commandKeyDown
end commandKeyDown
