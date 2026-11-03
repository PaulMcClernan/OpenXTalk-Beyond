script "TestIDEExtensionModuleFile"
-- OXT-Beyond: which compiled module the IDE's extension library
-- (ide/Toolset/libraries/revideextensionlibrary.livecodescript) loads from
-- an extension folder: revIDEExtensionModuleFileInFolder, which
-- __LoadExtension uses. It looked for module.<v>.lcm, <v> the version
-- lc-compile writes, then module.lcm. When lc-compile can't be asked, the
-- version is 0, so an extension shipped with module.2.lcm alone (the
-- macOS Native Tools library) failed to load on macOS (forum p=25991).
-- Now the engine's module.2.lcm is loaded when neither is there, and
-- every folder that had one of them still gets the same file.

local sFolder

on TestSetup
   get the long id of stack (TestGetIDERepositoryPath() & "/Toolset/libraries/revideextensionlibrary.livecodescript")
   put the tempname into sFolder
   create folder sFolder
end TestSetup

on TestTeardown
   repeat for each line tFile in files(sFolder)
      delete file (sFolder & slash & tFile)
   end repeat
   delete folder sFolder
end TestTeardown

private command __Files pList
   repeat for each line tFile in files(sFolder)
      delete file (sFolder & slash & tFile)
   end repeat
   repeat for each item tFile in pList
      put "lcm" into url ("binfile:" & sFolder & slash & tFile)
   end repeat
end __Files

private function __Pick pVersion
   dispatch function "revIDEExtensionModuleFileInFolder" to stack "revideextensionlibrary" with sFolder, pVersion
   return the result
end __Pick

on TestVersionedModuleFirst
   -- As before: the version lc-compile writes wins over module.lcm and
   -- over the engine's module.2.lcm
   __Files "module.3.lcm,module.lcm,module.2.lcm"
   TestAssert "module.<v>.lcm is loaded when it is there", __Pick(3) is "module.3.lcm"
   __Files "module.0.lcm,module.2.lcm"
   TestAssert "a failed probe still loads module.0.lcm when it is there", __Pick(0) is "module.0.lcm"
end TestVersionedModuleFirst

on TestUnversionedModuleSecond
   -- As before: module.lcm when module.<v>.lcm is not there, even with
   -- module.2.lcm beside it
   __Files "module.lcm,module.2.lcm"
   TestAssert "module.lcm is loaded when module.0.lcm is not there", __Pick(0) is "module.lcm"
end TestUnversionedModuleSecond

on TestEngineModuleWhenProbeFails
   -- The fix: a failed probe (version 0) with only module.2.lcm, as the
   -- macOS Native Tools library ships
   __Files "module.2.lcm"
   TestAssert "module.2.lcm is loaded when the probe answers 0", __Pick(0) is "module.2.lcm"
   -- Only the engine's version is taken, not any other
   __Files "module.5.lcm"
   TestAssert "another version is not taken", __Pick(0) is "module.lcm"
end TestEngineModuleWhenProbeFails

on TestNoModule
   -- As before: with no module at all the IDE tries module.lcm, and
   -- reports the same error
   __Files ""
   TestAssert "an empty folder answers module.lcm", __Pick(0) is "module.lcm"
end TestNoModule

on TestShippedMacOSNativeTools
   -- The folder the IDE ships
   local tSaved
   put sFolder into tSaved
   put TestGetIDERepositoryPath() & "/Extensions/org.openxtalk.library.macosnativeapptools" into sFolder
   TestAssert "macOS Native Tools loads module.2.lcm when the probe answers 0", __Pick(0) is "module.2.lcm"
   TestAssert "macOS Native Tools loads module.2.lcm when it answers 2", __Pick(2) is "module.2.lcm"
   put tSaved into sFolder
end TestShippedMacOSNativeTools
