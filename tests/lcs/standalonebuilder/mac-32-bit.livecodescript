script "TestStandaloneBuilderMac32Bit"
-- OXT-Beyond: tests of revSBRemove32BitMacFromSettings
-- (ide-support/revsblibrary.livecodescript), which the standalone builder
-- (revDoSaveAsStandalone in ide-support/revsaveasstandalone.livecodescript)
-- calls on its copy of a stack's standalone settings. OXT-Beyond has no
-- 32-bit Mac engine, so a stack set to build for 32-bit Intel Macs
-- ("MacOSX x86-32") got an app with no code in it, and any build with
-- that target took its externals and support libraries from a runtime
-- folder that has none (openxtalk.org p=25421). The target is turned off;
-- when it was the stack's only Mac target, 64-bit Intel ("MacOSX x86-64")
-- is turned on in its place, and the function returns true. Every other
-- setting is left as it was, and so are the settings of a stack not set
-- to 32-bit, whatever else they have.

constant kStack = "TestStandaloneBuilderMac32BitStack"
constant kHandler = "revSBRemove32BitMacFromSettings"
constant kMacTargets = "MacOSX x86-32,MacOSX x86-64,MacOSX x64-ARM64"

-- The function as the library has it, in the script of a button in the
-- back scripts: the library itself does not compile in the standalone
-- engine that runs these tests, as it has commands that only the IDE's
-- engine has (_internal call)
on TestSetup
   local tScript, tStart, tEnd
   put url ("file:" & TestGetEngineRepositoryPath() & "/ide-support/revsblibrary.livecodescript") into tScript
   put lineOffset("function" && kHandler && "@xSettingsA", tScript) into tStart
   put lineOffset("end" && kHandler, tScript) into tEnd
   if tStart is 0 or tEnd < tStart then
      throw "the library has no function" && kHandler
   end if
   create stack kStack
   set the defaultStack to kStack
   create button "library"
   set the script of button "library" of stack kStack to line tStart to tEnd of tScript
   if the result is not empty then
      throw "the function does not compile:" && the result
   end if
   insert the script of button "library" of stack kStack into back
end TestSetup

on TestTeardown
   if there is a stack kStack then
      remove the script of button "library" of stack kStack from back
      delete stack kStack
   end if
end TestTeardown

--------------------------------------------------------------------------------
-- Helpers

-- Settings as a stack has them: the three Mac targets ("-" leaves a
-- target's key out, as in a stack that never had it), and settings of
-- other kinds beside them
private function makeSettings p32, p64, pArm
   local tSettingsA
   if p32 is not "-" then put p32 into tSettingsA["MacOSX x86-32"]
   if p64 is not "-" then put p64 into tSettingsA["MacOSX x86-64"]
   if pArm is not "-" then put pArm into tSettingsA["MacOSX x64-ARM64"]
   put true into tSettingsA["Windows"]
   put false into tSettingsA["Linux x64"]
   put "Probe" into tSettingsA["name"]
   put "XML" & return & "SSL & Encryption" into tSettingsA["scriptLibraries"]
   put "com.example.probe" into tSettingsA["OSX,identifier"]
   put empty into tSettingsA["OSX,plist"]
   return tSettingsA
end makeSettings

-- The three Mac targets of pSettingsA as one line, each its value, or "-"
-- when there is no key
private function macTargets pSettingsA
   local tLine
   repeat for each item tKey in kMacTargets
      if tKey is among the keys of pSettingsA then
         put pSettingsA[tKey] & comma after tLine
      else
         put "-" & comma after tLine
      end if
   end repeat
   delete char -1 of tLine
   return tLine
end macTargets

-- Whether pA and pB have the same keys with the same values, besides the
-- Mac targets
private function sameOtherSettings pA, pB
   repeat for each item tKey in kMacTargets
      delete variable pA[tKey]
      delete variable pB[tKey]
   end repeat
   if the number of lines of the keys of pA is not the number of lines of the keys of pB then
      return false
   end if
   repeat for each key tKey in pA
      if tKey is not among the keys of pB or pA[tKey] is not pB[tKey] then
         return false
      end if
   end repeat
   return true
end sameOtherSettings

-- Calls the function on settings with the given Mac targets and checks
-- what it returns and the Mac targets it leaves; every other setting must
-- be as it was
private command checkSettings p32, p64, pArm, pReturns, pTargets
   local tSettingsA, tBeforeA, tReturned
   put makeSettings(p32, p64, pArm) into tSettingsA
   put tSettingsA into tBeforeA
   put revSBRemove32BitMacFromSettings(tSettingsA) into tReturned
   TestDiagnostic macTargets(tBeforeA) && "->" && macTargets(tSettingsA) && "returned" && tReturned
   TestAssert macTargets(tBeforeA) && "returns" && pReturns, tReturned is pReturns
   TestAssert macTargets(tBeforeA) && "becomes" && pTargets, macTargets(tSettingsA) is pTargets
   TestAssert macTargets(tBeforeA) && "keeps the other settings", sameOtherSettings(tSettingsA, tBeforeA)
end checkSettings

--------------------------------------------------------------------------------
-- Tests

-- 32-bit Intel as the only Mac target: 64-bit Intel in its place, however
-- the other two are not set (false, empty, no key), and whichever way
-- true is written
on TestMac32BitOnly
   checkSettings true, false, false, true, "false,true,false"
   checkSettings true, "-", "-", true, "false,true,-"
   checkSettings true, empty, empty, true, "false,true,"
   checkSettings "true", "false", "-", true, "false,true,-"
   checkSettings "TRUE", "-", "false", true, "false,true,false"
end TestMac32BitOnly

-- 32-bit Intel beside another Mac target: turned off, and the other
-- targets left as they are
on TestMac32BitWithAnotherTarget
   checkSettings true, true, false, false, "false,true,false"
   checkSettings true, true, "-", false, "false,true,-"
   checkSettings true, false, true, false, "false,false,true"
   checkSettings true, "-", true, false, "false,-,true"
   checkSettings true, true, true, false, "false,true,true"
   checkSettings "true", "TRUE", "-", false, "false,TRUE,-"
end TestMac32BitWithAnotherTarget

-- Settings not set to 32-bit Intel are left as they are, whatever their
-- other Mac targets are, and so is a value that is not true
on TestNot32BitLeftAsItIs
   repeat for each item t32 in "false,-,,no"
      repeat for each item t64 in "true,false,-"
         repeat for each item tArm in "true,false,-"
            checkSettings t32, t64, tArm, false, t32 & comma & t64 & comma & tArm
         end repeat
      end repeat
   end repeat
end TestNot32BitLeftAsItIs

-- The settings are changed in the caller's variable, as the builder calls
-- the function on its own copy of the stack's settings, and a second call
-- changes nothing more
on TestMac32BitByReference
   local tSettingsA
   put makeSettings(true, false, false) into tSettingsA
   get revSBRemove32BitMacFromSettings(tSettingsA)
   TestAssert "the caller's settings are changed", macTargets(tSettingsA) is "false,true,false"
   TestAssert "a second call returns false", revSBRemove32BitMacFromSettings(tSettingsA) is false
   TestAssert "a second call changes nothing", macTargets(tSettingsA) is "false,true,false"
end TestMac32BitByReference
