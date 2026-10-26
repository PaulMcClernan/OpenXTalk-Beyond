script "stack_revStandaloneSettings_button_id_1234"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Stacks" (id 1013) > group "Basic Options" (id 2037) > button "Add Stack File..." (id 1234)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   local filterstring,tIncludeList,tFiles,tType
   if the optionKey is not down then
      get revAnswerFiles("stack", "Select a stack file to add:")
      if it is empty then
         exit mouseUp
      end if
      revIncludeStackFiles it
      exit mouseUp
   else
      answer folder "Select a folder to add from:"
      if it is empty then exit mouseUp
      put the directory into tReturn
      set the directory to it
      put the files into tFiles
      repeat for each line tLine in tFiles
         put it&"/"&tLine & cr after tIncludeList
      end repeat
      delete char -1 of tIncludeList
      set the directory to tReturn
   end if
   revIncludeStackFiles tIncludeList
end mouseUp
