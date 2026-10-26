script "stack_revStandaloneSettings_button_id_1624"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > card "Windows" (id 1016) > group "Windows" (id 1169) > button "UAC Execution Level" (id 1624)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
   local tValue
   put the cValue of me into tValue
   uacUpdateInfoField tValue
   
   if tValue is "default" then
      put empty into tValue
   end if
   
   set the cRevStandaloneSettings["Windows,uacExecutionLevel"] of stack the cRevTargetStack of this stack to tValue
end menuPick

getProp cValue
   return line (the menuHistory of me) of the cValues of me
end cValue

setProp cValue pValue
   local tLineNumber
   set the wholeMatches to true
   put lineOffset(pValue, the cValues of me) into tLineNumber
   set the wholeMatches to false
   
   if tLineNumber = 0 then
      exit cValue
   end if
   
   set the label of me to space
   set the label of me to line tLineNumber of the text of me
end cValue
