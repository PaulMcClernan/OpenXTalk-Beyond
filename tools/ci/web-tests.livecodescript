script "OXTWebTests"
/*
Copyright (C) 2026 OXT-Beyond contributors.

This file is part of OXT-Beyond.

OXT-Beyond is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License v3 as published by the Free
Software Foundation.

OXT-Beyond is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
details.

You should have received a copy of the GNU General Public License
along with OXT-Beyond.  If not see <http://www.gnu.org/licenses/>.  */

-- The main stack of the web standalone that tools/ci/web_tests.py makes to
-- run the LiveCode Script tests of tests/lcs in the web engine. It runs
-- them as tests/_standalonetestrunner/StandaloneTestRunner.livecodescript
-- runs them in a standalone, one test command after the other in this
-- engine, with the test runner's behavior (tests/_testrunnerbehavior):
-- each test gets the same set-up, tear-down and clean-up as in a test
-- run on the desktop, where each runs in an engine of its own.
--
-- The stack is named StandaloneTestRunnerMainstack, as LiveCode's, which
-- is how the test library knows that it runs in a standalone
-- (TestIsInStandalone): tests that need the IDE, the documentation or the
-- LiveCode Builder compiler skip there.
--
-- The standalone has the tests in /boot/standalone/tests, and the list of
-- the tests to run in /boot/standalone/web-tests.txt, one a line: the
-- test file, a tab, the test command. The page's address can start the
-- run at another line than the first (?start=<line>), for web_tests.py to
-- go on after a test that never ended. Every line of the run goes to
-- stdout, which the page writes to the browser's console:
--
--    WEBTESTS COUNT <number of tests>
--    WEBTESTS BEGIN <line>                 before a test
--    WEBTESTS TAP <line> <TAP line>        each line of its output
--    WEBTESTS QUIT <line>                  the test quit (see below)
--    WEBTESTS DONE <line>                  after it
--    WEBTESTS END                          after the last
--
-- A test that quits would end the engine, and with it the run: the test
-- library quits when it cannot load an extension (TestLoadExtension), and
-- in a desktop run each test has an engine of its own. A backscript
-- cancels the quit instead (its shutdownRequest handler does not pass it,
-- which the quit command asks first) and says so, and the test goes on.

local sTests
local sIndex

on startup
   local tTestsFolder
   put specialFolderPath("resources") & slash & "tests" into tTestsFolder

   -- The test runner's behavior, as tests/_testrunner.livecodescript sets
   -- it, and the libraries a test command needs (_testlib and _inputlib)
   set the behavior of me to the long id of stack (tTestsFolder & slash & "_testrunnerbehavior.livecodescript")
   TestRunnerInvokeLoadLibraries
   TestOutputToVariable

   -- The backscript that cancels a quit, in a button of this stack that
   -- nobody sees
   set the defaultStack to the short name of me
   create invisible button "WebTestsQuit"
   set the script of it to "on shutdownRequest" & return & \
         "   write " & quote & "WEBTESTS QUIT " & quote & " & the uIndex of me & return to stdout" & return & \
         "end shutdownRequest"
   insert the script of it into back

   put url ("file:" & specialFolderPath("resources") & slash & "web-tests.txt") into sTests
   if the last char of sTests is return then
      delete the last char of sTests
   end if
   webWrite "WEBTESTS COUNT" && the number of lines of sTests

   put webStartLine() into sIndex
   send "webTestsNext" to me in 0 milliseconds
end startup

-- A line to stdout, in UTF-8 as the test library writes its own: the
-- engine writes text to stdout in the system's encoding
private command webWrite pLine
   write textEncode(pLine & return, "UTF-8") to stdout
end webWrite

-- The line to start at: ?start=<line> in the page's address, else 1
private function webStartLine
   local tSearch, tStart
   do "window.location.search" as "JavaScript"
   put the result into tSearch
   if tSearch begins with "?" then
      delete char 1 of tSearch
   end if
   set the itemDelimiter to "&"
   repeat for each item tItem in tSearch
      if tItem begins with "start=" then
         put char 7 to -1 of tItem into tStart
      end if
   end repeat
   if tStart is an integer and tStart >= 1 then
      return tStart
   end if
   return 1
end webStartLine

on webTestsNext
   if sIndex > the number of lines of sTests then
      webWrite "WEBTESTS END"
      exit webTestsNext
   end if

   local tFile, tCommand, tOutput
   set the itemDelimiter to tab
   put item 1 of line sIndex of sTests into tFile
   put item 2 of line sIndex of sTests into tCommand
   set the uIndex of button "WebTestsQuit" of me to sIndex
   webWrite "WEBTESTS BEGIN" && sIndex

   try
      TestRunnerInvokeTestCommand tFile, tCommand
   catch tError
      TestAssert "run the test command", false
      TestDiagnostic tError
   end try

   -- The test's TAP output
   put TestFetchAndClearOutput() into tOutput
   replace numToChar(13) with numToChar(10) in tOutput
   repeat for each line tLine in tOutput
      webWrite "WEBTESTS TAP" && sIndex && tLine
   end repeat
   webWrite "WEBTESTS DONE" && sIndex

   add 1 to sIndex
   send "webTestsNext" to me in 0 milliseconds
end webTestsNext
