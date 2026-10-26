script "stack_revStandaloneSettings_button_id_1498"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "General" (id 1002) > group "generalContent" (id 2882) > button "Browse" (id 1498)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   get selectStandaloneBuildFolder()
   if it is not empty then
      set the text of field "Default Build Folder" to it
   end if
end mouseUp
