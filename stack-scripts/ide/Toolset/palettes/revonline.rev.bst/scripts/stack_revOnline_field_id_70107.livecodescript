script "stack_revOnline_field_id_70107"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > card "main" (id 1002) > group "paging" (id 70106) > field "pages" (id 70107)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on mousemove
   lock screen
   local tMouseText, tText, tTextToHilite
   put the text of me into tText
   put the mouseText into tMouseText
   local tWord
   put wordoffset(tMouseText, tText) into tWord
   put word tWord of tText into tTextToHilite
   clearColors (the long id of me)
   if tTextToHilite is not "." and tTextToHilite is not " " then
      set the textColor of word tWord of me to rvoHiliteColor()
   end if
   unlock screen
end mousemove

on mouseUp
   lock screen
   local tMouseText, tText
   put the text of me into tText
   put the mouseText into tMouseText
   set the itemdelimiter to space
   if tMouseText is not empty and tMouseText is not "." then
      local tItem
      put itemoffset(tMouseText, tText) into tItem
      clearStyles (the long id of me)
      selectPage (item tItem of me)      
      clearColors (the long id of me)
   end if
   unlock screen
end mouseUp

on mouseLeave
   --clearColors (the long id of me)
end mouseLeave
