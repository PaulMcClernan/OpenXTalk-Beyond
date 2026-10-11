script "TestXTalkAssistantGuide"
-- OXT-Beyond: tests of the xTalk Assistant's guide
-- (ide/Extensions/org.openxtalk.plugin.xtalkassistant/xtalk-guide.md), the
-- text every request starts with. A model follows what it is told, so what
-- the guide says must be true: its examples compile, the statements it
-- writes inline compile, and what part 4 says about this engine holds here.
-- What it says only of OpenXTalk (curly quotes, 1.4) and what needs a
-- window, a socket or a second card (5.3, 5.6, 5.11 to 5.13, 6.1 to 6.12)
-- is not run here.

-- Calls counted by guideCounted (engine note 2.5)
local sGuideCalls

on TestSetup
   start using stack (TestGetIDERepositoryPath() & "/Extensions/org.openxtalk.plugin.xtalkassistant/xtalkassistant-core.livecodescript")
end TestSetup

on TestTeardown
   if there is a stack "xtaGuideProbe" then
      delete stack "xtaGuideProbe"
   end if
   xtaCheckCleanup
end TestTeardown

private function guidePath
   return TestGetIDERepositoryPath() & "/Extensions/org.openxtalk.plugin.xtalkassistant/xtalk-guide.md"
end guidePath

private function guideText
   return xtaReadGuide(guidePath())
end guideText

-- The part of the guide from the heading that begins with pHeading to the
-- next heading of its level
private function guidePart pHeading
   local tText, tPart, tIn, tLine
   put guideText() into tText
   put false into tIn
   repeat for each line tLine in tText
      if tLine begins with "## " then
         if tIn then
            exit repeat
         end if
         put tLine begins with pHeading into tIn
      end if
      if tIn then
         put tLine & return after tPart
      end if
   end repeat
   return tPart
end guidePart

--------------------------------------------------------------------------------
-- The file

on TestGuideReads
   local tData, tByte, tHigh, tHeadings, tLine, tIndex
   TestAssert "the guide is in the plugin's folder", there is a file guidePath()
   TestAssert "and reads", guideText() begins with "# The xTalk Assistant's guide"
   -- Plain ASCII, as the scripts it teaches: nothing a provider or a
   -- copy and paste could change. Its line endings are the checkout's
   -- (.gitattributes: *.md text), CRLF on Windows.
   put url ("binfile:" & guidePath()) into tData
   put 0 into tHigh
   repeat for each byte tByte in tData
      if byteToNum(tByte) > 126 or (byteToNum(tByte) < 32 and byteToNum(tByte) is not 10 and byteToNum(tByte) is not 13) then
         add 1 to tHigh
      end if
   end repeat
   TestAssert "plain ASCII, with no tabs", tHigh is 0
   TestAssert "read with one kind of line ending", not (guideText() contains numToChar(13))
   repeat for each line tLine in guideText()
      if tLine begins with "## " then
         put tLine & return after tHeadings
      end if
   end repeat
   TestDiagnostic tHeadings
   TestAssert "seven parts", the number of lines of tHeadings is 7
   repeat with tIndex = 1 to 7
      TestAssert "part" && tIndex && "in its place", word 2 of line tIndex of tHeadings is (tIndex & ".")
   end repeat
   TestAssert "the language, objects and this engine", \
         line 2 of tHeadings is "## 2. The language" and line 3 of tHeadings is "## 3. Objects" and \
         line 4 of tHeadings is "## 4. This engine"
end TestGuideReads

on TestGuideIsNotTooLong
   -- Sent with every request (from the cache after the first), so it is
   -- kept to what a model needs
   TestDiagnostic the number of chars of guideText()
   TestAssert "under 32 KB", the number of chars of guideText() < 32768
end TestGuideIsNotTooLong

--------------------------------------------------------------------------------
-- The examples compile

-- The guide's indented code: each run of indented lines (4 spaces or
-- more) between blank lines is an example. Fenced ones keep only what is
-- inside a livecodescript fence. Returns an array of examples, each with
-- "code", and "kind": "check" (compile it), "fragment" (has "..."),
-- "listing" (first lines of handlers, one per line) or "other" (another
-- language).
private function guideExamples
   local tText, tExamples, tCount, tLine, tCode
   put guideText() & return & return into tText
   put 0 into tCount
   repeat for each line tLine in tText
      if char 1 to 4 of tLine is "    " then
         put tLine & return after tCode
         next repeat
      end if
      if tCode is not empty then
         add 1 to tCount
         put guideExample(tCode) into tExamples[tCount]
         put empty into tCode
      end if
   end repeat
   return tExamples
end guideExamples

private function guideExample pCode
   local tExample, tLine, tFirst, tStarts, tLines, tInner
   put pCode into tExample["code"]
   put word 1 to -1 of line 1 of pCode into tFirst
   if tFirst begins with "```" then
      if tFirst is not "```livecodescript" then
         put "other" into tExample["kind"]
         return tExample
      end if
      put line 2 to -2 of pCode into tInner
      if word 1 to -1 of the last line of tInner is "```" then
         delete the last line of tInner
      end if
      put tInner into pCode
      put pCode into tExample["code"]
   end if
   if pCode contains "..." then
      put "fragment" into tExample["kind"]
      return tExample
   end if
   put 0 into tStarts
   put 0 into tLines
   repeat for each line tLine in pCode
      if word 1 to -1 of tLine is empty then
         next repeat
      end if
      add 1 to tLines
      if word 1 of tLine is among the items of "on,command,function,getProp,setProp,private" then
         add 1 to tStarts
      end if
   end repeat
   if tStarts is tLines then
      put "listing" into tExample["kind"]
   else
      put "check" into tExample["kind"]
   end if
   return tExample
end guideExample

on TestGuideExamplesCompile
   local tExamples, tIndex, tCheck, tKinds, tChecked
   put guideExamples() into tExamples
   put 0 into tChecked
   repeat with tIndex = 1 to the number of elements of tExamples
      add 1 to tKinds[tExamples[tIndex]["kind"]]
      if tExamples[tIndex]["kind"] is not "check" then
         next repeat
      end if
      add 1 to tChecked
      put xtaCheckScript(tExamples[tIndex]["code"], empty) into tCheck
      if tCheck["ok"] is not true then
         TestDiagnostic tExamples[tIndex]["code"] & return & tCheck["issues"]
      end if
      TestAssert "example" && tIndex && "compiles (" & word 1 to -1 of line 1 of tExamples[tIndex]["code"] & ")", tCheck["ok"] is true
   end repeat
   TestDiagnostic "checked" && tKinds["check"] & ", fragments" && tKinds["fragment"] & ", listings" && tKinds["listing"] & ", other" && tKinds["other"]
   -- A reader that found nothing would pass whatever the guide says
   TestAssert "the examples were found", tChecked >= 4 and tKinds["fragment"] >= 1 and tKinds["listing"] is 1 and tKinds["other"] is 1
end TestGuideExamplesCompile

-- The statements the guide writes inline, in backquotes, beginning with a
-- command: every one compiles as written, with its variables declared as
-- the guide says to. Spans of one or two words name a command rather than
-- write a statement, and spans with "..." are fragments; repeat, exit and
-- pass need more than a line.
on TestGuideInlineStatementsCompile
   local tProse, tLine, tItem, tSpan, tIndex, tCheck, tChecked, tCommands
   put "put set get delete replace filter sort split combine create clone go open close read write" && \
         "send dispatch start answer ask post load accept rename add palette modal wait lock throw cancel" into tCommands
   -- Code blocks are the other test's; the rest is joined into one line,
   -- since a span can break over two
   repeat for each line tLine in guideText()
      if char 1 to 4 of tLine is not "    " then
         put tLine & space after tProse
      end if
   end repeat
   set the itemDelimiter to "`"
   put 0 into tChecked
   put 0 into tIndex
   repeat for each item tItem in tProse
      -- Every second item is inside backquotes
      add 1 to tIndex
      if tIndex mod 2 is 1 then
         next repeat
      end if
      put word 1 to -1 of tItem into tSpan
      if word 1 of tSpan is not among the words of tCommands then
         next repeat
      end if
      if the number of words of tSpan < 3 or tSpan contains "..." then
         next repeat
      end if
      add 1 to tChecked
      put xtaCheckScript(guideDeclared(tSpan) & tSpan, empty) into tCheck
      if tCheck["ok"] is not true then
         TestDiagnostic tSpan & return & tCheck["issues"]
      end if
      TestAssert "compiles:" && tSpan, tCheck["ok"] is true
   end repeat
   TestDiagnostic tChecked && "statements"
   TestAssert "the statements were found", tChecked >= 40
end TestGuideInlineStatementsCompile

-- A local line for the variables of pStatement (t or s and a capital), or
-- empty when it has none
private function guideDeclared pStatement
   local tWord, tNames, tChar
   repeat for each char tChar in "[](),&" & quote
      replace tChar with space in pStatement
   end repeat
   repeat for each word tWord in pStatement
      if matchText(tWord, "^[ts][A-Z][A-Za-z0-9]*$") and tWord is not among the items of tNames then
         put tWord & comma after tNames
      end if
   end repeat
   if tNames is empty then
      return empty
   end if
   return "local" && char 1 to -2 of tNames & return
end guideDeclared

--------------------------------------------------------------------------------
-- Part 4 holds on this engine

-- What part 4 says does not compile, does not; and the safe form it gives
-- does
on TestGuideWhatDoesNotCompile
   TestAssert "a part of the guide", guidePart("## 4.") contains "does not compile"
   guideCompiles false, "two declarations of one name (1.6)", "local sA" & return & "local sA" & return & "on a" & return & "end a"
   guideCompiles true, "one", "local sA" & return & "on a" & return & "end a"
   guideCompiles true, "the number of elements", "get the number of elements of tA"
   guideCompiles true, "the number of lines of the keys", "get the number of lines of the keys of tA"
   guideCompiles false, "a command called with brackets (3.3)", "refreshList()"
   guideCompiles true, "a command by its name alone", "refreshList"
   guideCompiles true, "a function with brackets", "get listCount()"
   guideCompiles false, "a chunk of a smaller chunk", "get word 1 of char 2 to 9 of tText"
   guideCompiles true, "a chunk of a larger chunk", "get char 2 of word 3 of tText"
   guideCompiles true, "bitAnd as an operator (1.9)", "get 6 bitAnd 3"
   guideCompiles false, "split on a name never declared or put into", "split tText by return"
   guideCompiles true, "split on a declared variable", "local tText" & return & "split tText by return"
   guideCompiles true, "or one put into first", "put field 1 into tText" & return & "split tText by return"
   guideCompiles false, "combine on a name never declared", "combine tA using return"
   guideCompiles false, "delete variable on a name never declared", "delete variable tA[" & quote & "x" & quote & "]"
   guideCompiles true, "delete variable on a declared one", "local tA" & return & "delete variable tA[" & quote & "x" & quote & "]"
end TestGuideWhatDoesNotCompile

private command guideCompiles pExpected, pLabel, pCode
   local tCheck
   put xtaCheckScript(pCode, empty) into tCheck
   if tCheck["ok"] is not pExpected then
      TestDiagnostic pCode & return & tCheck["issues"]
   end if
   if pExpected then
      TestAssert "compiles:" && pLabel, tCheck["ok"] is true
   else
      TestAssert "does not compile:" && pLabel, tCheck["ok"] is false
   end if
end guideCompiles

on TestGuideValuesAndText
   local tA, tText, tList, tBig, tThird
   TestAssert "a trailing delimiter is not counted (2.2)", the number of items of "a,b," is 2
   put 9007199254740992 into tBig
   TestAssert "whole numbers are exact to 2^53 (2.4)", (tBig - 1) - tBig is -1
   TestAssert "and rounded past it", (tBig + 1) - tBig is 0
   put 1 / 3 into tThird
   TestAssert "six decimals by default", ("s" & tThird) is "s0.333333"
   put "a" & return & "b" into tText
   TestAssert "a chunk count takes the nearest value (2.6)", ("s" & the number of lines of tText & "x") is "s2x"
   put 1 into tA["Name"]
   put 2 into tA["name"]
   TestAssert "array keys ignore case (2.7)", the number of elements of tA is 1 and tA["NAME"] is 2
   TestAssert "is compares number-like text as numbers (2.11)", "1e2" is "100" and "01" is "1" and "0x10" is "16"
   TestAssert "but not with a letter before both", ("s" & "01") is not ("s" & "1")
   TestAssert "is an integer (2.12)", "12" is an integer and "12.5" is not an integer
   TestAssert "offset counts after the skipped part", offset("b", "abcb", 2) is 2
   put "a,b" into tList
   put "d" into item 4 of tList
   TestAssert "putting past the end adds delimiters", tList is "a,b,,d"
end TestGuideValuesAndText

on TestGuideNumberOfKeys
   local tA, tThrew
   put 1 into tA["x"]
   put false into tThrew
   try
      get the number of keys of tA
   catch tError
      put true into tThrew
   end try
   TestAssert "the number of keys stops with an error (1.7)", tThrew
   TestAssert "the number of lines of the keys does not", the number of lines of the keys of tA is 1
end TestGuideNumberOfKeys

on TestGuideTextDecodeDoesNotThrow
   local tText, tThrew
   put false into tThrew
   try
      put textDecode(numToByte(255) & "a", "UTF-8") into tText
   catch tError
      put true into tThrew
   end try
   TestAssert "bad UTF-8 does not throw (2.8)", not tThrew
   TestAssert "the rest is kept", tText ends with "a"
end TestGuideTextDecodeDoesNotThrow

on TestGuideItemDelimiterIsPerHandler
   set the itemDelimiter to ";"
   TestAssert "a handler called starts with a comma (2.3)", guideItemDelimiter() is comma
   TestAssert "and the caller keeps its own", the itemDelimiter is ";"
end TestGuideItemDelimiterIsPerHandler

private function guideItemDelimiter
   return the itemDelimiter
end guideItemDelimiter

on TestGuideAndOrStopEarly
   local tValue
   put 0 into sGuideCalls
   put false and guideCounted() into tValue
   TestAssert "and stops at false (2.5)", sGuideCalls is 0 and tValue is false
   put true or guideCounted() into tValue
   TestAssert "or stops at true", sGuideCalls is 0 and tValue is true
   put true and guideCounted() into tValue
   TestAssert "and goes on at true", sGuideCalls is 1
end TestGuideAndOrStopEarly

private function guideCounted
   add 1 to sGuideCalls
   return true
end guideCounted

on TestGuideRepeatStep
   local tSeen, i
   repeat with i = 1 to 9 step 2
      put i & comma after tSeen
   end repeat
   TestAssert "repeat honours step (3.1)", tSeen is "1,3,5,7,9,"
end TestGuideRepeatStep

on TestGuideThrowInCatch
   local tCaught, tError
   try
      guideThrowFromCatch
   catch tError
      put tError into tCaught
   end try
   TestDiagnostic tCaught
   TestAssert "a throw in a catch reaches the caller (3.2)", tCaught contains "again"
end TestGuideThrowInCatch

private command guideThrowFromCatch
   try
      throw "first"
   catch tError
      throw "again"
   end try
end guideThrowFromCatch

-- Declarations by position (1.2), dispatch and private handlers (3.5),
-- and the menuHistory of an option menu (5.14), on a stack of their own
on TestGuideScriptsAndMessages
   local tScript, tExplicit, tStack, tResult
   put "command guideAbove" & return & "   return sLater" & return & "end guideAbove" & return & \
         "local sLater = 5" & return & \
         "command guideBelow" & return & "   return sLater" & return & "end guideBelow" & return & \
         "private command guidePrivate" & return & "   return 1" & return & "end guidePrivate" & return & \
         "command guidePasses" & return & "   pass guidePasses" & return & "end guidePasses" into tScript
   create invisible stack "xtaGuideProbe"
   put the long id of stack "xtaGuideProbe" into tStack
   put the explicitVariables into tExplicit
   set the explicitVariables to false
   set the script of tStack to tScript
   put the result into tResult
   set the explicitVariables to tExplicit
   TestDiagnostic tResult
   TestAssert "the probe's script compiles", tResult is empty

   send "guideAbove" to tStack
   TestAssert "above its declaration a local is undeclared (1.2, 2.1)", the result is "sLater"
   send "guideBelow" to tStack
   TestAssert "below it, declared", the result is 5

   dispatch "guideBelow" to tStack
   TestAssert "dispatch sets it to handled", it is "handled"
   dispatch "guidePrivate" to tStack
   TestAssert "a private handler is not reached (3.5)", it is "unhandled"
   dispatch "guideNowhere" to tStack
   TestAssert "nor a handler that is not there", it is "unhandled"
   dispatch "guidePasses" to tStack
   TestAssert "and passed when it passes", it is "passed"

   -- 5.14
   set the defaultStack to "xtaGuideProbe"
   create button "Choice"
   set the style of it to "menu"
   set the menuMode of it to "option"
   set the text of it to "One" & return & "Two" & return & "Three"
   set the script of it to "on menuPick pItem" & return & "   set the cPicked of me to pItem" & return & "end menuPick"
   set the menuHistory of button "Choice" to 2
   TestAssert "setting the menuHistory sends menuPick (5.14)", the cPicked of button "Choice" is "Two"
   lock messages
   set the menuHistory of button "Choice" to 3
   unlock messages
   TestAssert "not under lock messages", the cPicked of button "Choice" is "Two"
end TestGuideScriptsAndMessages

on TestGuideOpenForWriteEmpties
   local tPath, tText
   put specialFolderPath("temporary") & "/xta-guide-" & the milliseconds & ".txt" into tPath
   put "abcdef" into url ("file:" & tPath)
   open file tPath for write
   write "x" to file tPath
   close file tPath
   put url ("file:" & tPath) into tText
   delete file tPath
   TestAssert "open for write empties the file (6.14)", tText is "x"
end TestGuideOpenForWriteEmpties
