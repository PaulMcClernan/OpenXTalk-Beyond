script "stack_revStandaloneSettings_button_id_1640"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Copy Files" (id 1027) > button "Add Folder..." (id 1640)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp pMouseButton, pOverRide
   answer folder "Select a folder to add from:"
   if it is empty then
      exit mouseUp
   end if
   
   local tPrev
   put field "files" into tPrev
   put revRelativePath(it) & slash & "*" into line (the number of lines in tPrev + 1) of tPrev
   put tPrev into field "files"
   setProps
end mouseUp
