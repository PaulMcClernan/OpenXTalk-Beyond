script "TestFileSelector"
-- OXT-Beyond: tests of the IDE's own file dialog, the stack "File
-- Selector" (ide/Toolset/palettes/revfileselector.rev), which the engine
-- opens for answer folder, answer file and ask file when the
-- systemFileSelector is false. Its scripts named its OK button and its
-- Cancel button by ids 1013 and 1014, which are its fields Dlabel and
-- Flabel, so its preOpenCard stopped with an error as the dialog opened,
-- and Return and Escape did nothing. Its OK button is button id 1012, and
-- Cancel button id 1008.

-- Whether the stack was in memory before the test, which leaves it so
local sFound

on TestSetup
   TestSkipIfNot "ide"
   put there is a stack "File Selector" into sFound
   get the long id of stack (TestGetIDERepositoryPath() & "/Toolset/palettes/revfileselector.rev")
end TestSetup

on TestTeardown
   set the dialogData to empty
   if sFound is not true and there is a stack "File Selector" then
      delete stack "File Selector"
   end if
end TestTeardown

-- The card opened as the engine opens it: its preOpenCard, with the
-- dialogData the engine gives it (the command, title, prompt, filter and
-- response, with numToChar(0) between them). Returns empty, or the error
private function __Open pCommand
   local tData
   put pCommand & numToChar(0) & numToChar(0) & "Pick one" & numToChar(0) & \
         "*" & numToChar(0) & "x.txt" into tData
   set the dialogData to tData
   try
      dispatch "preOpenCard" to card 1 of stack "File Selector"
   catch tError
      return tError
   end try
   return empty
end __Open

on TestAnswerFolder
   TestAssert "answer folder's dialog opens", __Open("answer folder") is empty
   TestAssert "its OK button is Choose", the short name of button id 1012 of stack "File Selector" is "Choose"
   TestAssert "its title", the title of stack "File Selector" is "Choose Directory"
   TestAssert "it lists no files", the visible of field "Files" of stack "File Selector" is false
end TestAnswerFolder

on TestAnswerFile
   TestAssert "answer file's dialog opens", __Open("answer file") is empty
   TestAssert "its OK button is Open", the short name of button id 1012 of stack "File Selector" is "Open"
   TestAssert "it lists the files", the visible of field "Files" of stack "File Selector" is true
end TestAnswerFile

on TestAskFile
   TestAssert "ask file's dialog opens", __Open("ask file") is empty
   TestAssert "its OK button is Save", the short name of button id 1012 of stack "File Selector" is "Save"
   TestAssert "its prompt", field "Prompt" of stack "File Selector" is "Pick one"
end TestAskFile

-- Return and Escape send their mouseUp to the OK button and to Cancel
on TestKeysNameTheButtons
   local tScript, tAll
   put the script of card 1 of stack "File Selector" into tScript
   put tScript & the script of field "Selection" of stack "File Selector" & \
         the script of field "Files" of stack "File Selector" into tAll
   TestAssert "Return clicks the OK button", tScript contains "send" && quote & "mouseUp" & quote && "to button id 1012"
   TestAssert "Escape clicks Cancel", tScript contains "send" && quote & "mouseUp" & quote && "to button id 1008"
   TestAssert "button id 1012 is a button", the short name of button id 1012 of stack "File Selector" is not empty
   TestAssert "button id 1008 is Cancel", the short name of button id 1008 of stack "File Selector" is "Cancel"
   TestAssert "nothing names the fields as buttons", \
         not (tAll contains "button id 1013") and not (tAll contains "button id 1014")
end TestKeysNameTheButtons
