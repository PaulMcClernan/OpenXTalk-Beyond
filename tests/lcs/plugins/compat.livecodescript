script "TestXTalkPluginCompat"
-- OXT-Beyond: tests of the compatibility stack the plugin packages carry
-- (tools/plugins/plugin-compat.livecodescript.in, made into
-- <main>-compat.livecodescript by tools/plugins/build-plugin-packages.py),
-- made here from the template for a plugin of the test's own, with a
-- stand-in for the IDE: that it writes no launcher on an IDE whose menu bar
-- lists the plugin itself, as OXT-Beyond's does; that on one that does not
-- it writes a launcher into the user's Plugins folder, which is a stack of
-- the menu item's name that dispatches the plugin's menu message, and
-- takes it out again when stopped; that a file of that name it did not
-- write is left alone; and that the Script Editor handlers it adds put
-- text at the last selection as one undo group and say which line that
-- is, through a stand-in for the editor's field. The packages themselves
-- are checked by tools/ci/tests/test_plugin_packages.py.

constant kCompat = "xtpcTestMain-compat"
constant kMain = "xtpcTestMain"
constant kTitle = "xtpc Test Plugin"
constant kPick = "xtpcTestMenuPick"

-- The stand-in IDE's folders: its Toolset (with a menu bar file of the
-- test's choosing) and the user's Plugins folder
local sFolder, sToolset, sPlugins

on TestSetup
   local tTemplate, tText, tStub, tCompatFile
   put specialFolderPath("temporary") & "/xtpc-test-" & the milliseconds into sFolder
   put sFolder & "/Toolset" into sToolset
   put sFolder & "/My xTalk/Plugins" into sPlugins
   create folder sFolder
   create folder sToolset
   create folder (sToolset & "/palettes")
   create folder (sToolset & "/palettes/menubar")
   -- The user's folder is there, its Plugins folder not yet (the launcher
   -- makes it)
   create folder (sFolder & "/My xTalk")
   -- The package's stack, made as the package builder makes it
   put TestGetEngineRepositoryPath() & "/tools/plugins/plugin-compat.livecodescript.in" into tTemplate
   put textDecode(url ("binfile:" & tTemplate), "UTF-8") into tText
   replace "@COMPAT_STACK@" with kCompat in tText
   replace "@MAIN_STACK@" with kMain in tText
   replace "@MENU_TITLE@" with kTitle in tText
   replace "@MENU_PICK@" with kPick in tText
   put sFolder & "/" & kCompat & ".livecodescript" into tCompatFile
   put textEncode(tText, "UTF-8") into url ("binfile:" & tCompatFile)
   -- The IDE's handlers it calls
   put "local sUpdates" & return & \
         "function revEnvironmentToolsetPath" & return & "return `" & sToolset & "`" & return & "end revEnvironmentToolsetPath" & return & \
         "function revEnvironmentUserPluginsPath" & return & "return `" & sPlugins & "`" & return & "end revEnvironmentUserPluginsPath" & return & \
         "on revIDEEnsurePath pPath" & return & "create folder pPath" & return & "end revIDEEnsurePath" & return & \
         "on revIDEUpdatePlugins" & return & "add 1 to sUpdates" & return & "end revIDEUpdatePlugins" & return & \
         "function xtpcTestUpdates" & return & "return sUpdates + 0" & return & "end xtpcTestUpdates" & return into tStub
   replace "`" with quote in tStub
   create invisible stack "xtpcTestIDE"
   set the script of stack "xtpcTestIDE" to tStub
   start using stack "xtpcTestIDE"
   -- As the plugin's main stack loads it (xtaStartCompat, mcbStartCompat)
   get the short name of stack tCompatFile
   start using stack kCompat
   -- The menu bar is open, so that a change refreshes the plugins' list
   create invisible stack "revMenuBar"
end TestSetup

on TestTeardown
   if there is a stack kCompat then
      stop using stack kCompat
      delete stack kCompat
   end if
   if there is a stack "revMenuBar" then
      delete stack "revMenuBar"
   end if
   if there is a stack kTitle then
      delete stack kTitle
   end if
   TestDeleteFolder sFolder
end TestTeardown

private command TestDeleteFolder pFolder
   local tName
   if there is not a folder pFolder then
      exit TestDeleteFolder
   end if
   repeat for each line tName in files(pFolder)
      delete file (pFolder & "/" & tName)
   end repeat
   repeat for each line tName in folders(pFolder)
      if tName is not among the items of ".,.." then
         TestDeleteFolder pFolder & "/" & tName
      end if
   end repeat
   delete folder pFolder
end TestDeleteFolder

private function TestLauncherPath
   return sPlugins & "/" & kTitle & ".livecodescript"
end TestLauncherPath

on TestNativeMenuWritesNothing
   -- As OXT-Beyond's menu bar: it dispatches the plugin's message itself
   set the script of stack "revMenuBar" to "on revTestPick" & return & \
         "dispatch" && quote & kPick & quote && "to stack" && quote & kMain & quote & return & "end revTestPick"
   dispatch function "xtpcMenuIsNative" to stack kCompat
   TestAssert "the menu bar lists the plugin", the result is true
   dispatch "xtpcStart" to stack kCompat
   TestAssert "no launcher", there is not a file TestLauncherPath()
   TestAssert "the plugins are not listed again", xtpcTestUpdates() is 0
end TestNativeMenuWritesNothing

on TestNativeMenuFromItsFile
   -- Before the menu bar is open, its file says
   delete stack "revMenuBar"
   put "script " & quote & "revMenuBar" & quote & return & "dispatch" && quote & kPick & quote & return into url ("file:" & sToolset & "/palettes/menubar/revmenubar.livecodescript")
   dispatch function "xtpcMenuIsNative" to stack kCompat
   TestAssert "read from the menu bar's file", the result is true
   put "script " & quote & "revMenuBar" & quote & return into url ("file:" & sToolset & "/palettes/menubar/revmenubar.livecodescript")
   dispatch function "xtpcMenuIsNative" to stack kCompat
   TestAssert "a file without it", the result is false
end TestNativeMenuFromItsFile

on TestLauncherWrittenAndTakenOut
   local tText
   set the script of stack "revMenuBar" to empty
   dispatch "xtpcStart" to stack kCompat
   TestAssert "a launcher in the Plugins folder", there is a file TestLauncherPath()
   TestAssert "the plugins are listed again", xtpcTestUpdates() is 1
   put textDecode(url ("binfile:" & TestLauncherPath()), "UTF-8") into tText
   TestDiagnostic line 1 to 2 of tText
   TestAssert "it names the plugin that wrote it", line 2 of tText is ("-- xtalk-plugin-launcher: " & kMain)
   TestAssert "it dispatches the plugin's menu message", tText contains ("dispatch" && quote & kPick & quote && "to stack" && quote & kMain & quote)
   -- It is a stack, named as the menu item is (what the IDE lists)
   TestAssert "a stack of the menu item's name", the short name of stack TestLauncherPath() is kTitle
   delete stack kTitle
   -- Started again (the next session): the same file, written once
   dispatch "xtpcStart" to stack kCompat
   TestAssert "not written again", xtpcTestUpdates() is 1
   dispatch "xtpcStop" to stack kCompat
   TestAssert "taken out when stopped", there is not a file TestLauncherPath()
   TestAssert "the plugins are listed again after", xtpcTestUpdates() is 2
end TestLauncherWrittenAndTakenOut

on TestUsersOwnFileLeftAlone
   local tMine
   set the script of stack "revMenuBar" to empty
   create folder sPlugins
   put "script " & quote & kTitle & quote & return & "-- the user's own" & return into tMine
   put tMine into url ("binfile:" & TestLauncherPath())
   dispatch "xtpcStart" to stack kCompat
   TestAssert "not replaced", url ("binfile:" & TestLauncherPath()) is tMine
   dispatch "xtpcStop" to stack kCompat
   TestAssert "not deleted", there is a file TestLauncherPath()
end TestUsersOwnFileLeftAlone

-- A stand-in for the Script Editor: a stack with a field "Script" whose
-- script answers as LiveCode Community 9.6's field behavior does
-- (revsecommoneditorbehavior), and notes the undo groups
private command TestMakeEditor pText, pChunk
   local tScript
   create invisible stack "xtpcTestEditor"
   set the defaultStack to "xtpcTestEditor"
   create field "Script"
   put pText into field "Script" of stack "xtpcTestEditor"
   put "local sLog" & return & \
         "command getLastSelectedChunk" & return & "return `" & pChunk & "`" & return & "end getLastSelectedChunk" & return & \
         "function scriptLocked" & return & "return false" & return & "end scriptLocked" & return & \
         "on textBeginGroup pLabel" & return & "put `begin ` & pLabel & return after sLog" & return & "end textBeginGroup" & return & \
         "on textEndGroup" & return & "put `end` & return after sLog" & return & "end textEndGroup" & return & \
         "on scriptFormat pScope" & return & "put `format ` & pScope & return after sLog" & return & "end scriptFormat" & return & \
         "command textReplace pOffset, pOld, pNew" & return & \
         "put `replace ` & pOffset & `,` & the number of chars of pOld & return after sLog" & return & \
         "put pNew into char pOffset to pOffset + the number of chars of pOld - 1 of me" & return & "end textReplace" & return & \
         "function xtpcTestLog" & return & "return sLog" & return & "end xtpcTestLog" into tScript
   replace "`" with quote in tScript
   set the script of field "Script" of stack "xtpcTestEditor" to tScript
end TestMakeEditor

on TestInsertAtLastSelection
   local tLog
   TestMakeEditor "on a" & return & "end a", "4,4"
   dispatch "revSEInsertText" to stack "xtpcTestEditor" with "XY"
   TestAssert "handled", it is "handled"
   TestDiagnostic field "Script" of stack "xtpcTestEditor"
   TestAssert "in place of the selection", field "Script" of stack "xtpcTestEditor" is ("on XY" & return & "end a")
   dispatch function "xtpcTestLog" to field "Script" of stack "xtpcTestEditor"
   put the result into tLog
   TestDiagnostic tLog
   TestAssert "one undo group", line 1 of tLog is "begin Insert" and line -1 of tLog is "end"
   TestAssert "the selection replaced", line 2 of tLog is "replace 4,1"
   delete stack "xtpcTestEditor"
end TestInsertAtLastSelection

on TestInsertBeforeAnyClick
   TestMakeEditor "abc", empty
   dispatch "revSEInsertText" to stack "xtpcTestEditor" with "d"
   TestAssert "at the end", field "Script" of stack "xtpcTestEditor" is "abcd"
   delete stack "xtpcTestEditor"
end TestInsertBeforeAnyClick

on TestLastSelectedLine
   TestMakeEditor "one" & return & "two" & return & "three", "9,8"
   dispatch function "revSEGetLastSelectedLine" to stack "xtpcTestEditor"
   TestAssert "the third line", the result is 3
   delete stack "xtpcTestEditor"
   TestMakeEditor "one", empty
   dispatch function "revSEGetLastSelectedLine" to stack "xtpcTestEditor"
   TestAssert "empty before a click", the result is empty
   delete stack "xtpcTestEditor"
end TestLastSelectedLine
