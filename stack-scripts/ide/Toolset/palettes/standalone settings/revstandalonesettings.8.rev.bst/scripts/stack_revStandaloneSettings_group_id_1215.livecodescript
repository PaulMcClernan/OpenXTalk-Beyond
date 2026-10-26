script "stack_revStandaloneSettings_group_id_1215"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "General" (id 1002) > group "generalContent" (id 2882) > group "profiles" (id 1215)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on revGetProfileList
   local tFinalList
   set the cursor to watch
   put revGetPropertyProfilesList() into tFinalList
   put tFinalList into fld "include profiles"
   put tFinalList into btn "set objects"
   unlock cursor
   if tFinalList = "" then
      beep 1
      answer information "There are no profiles in this application"
      click at the loc of btn "remove"
   end if
end revGetProfileList
