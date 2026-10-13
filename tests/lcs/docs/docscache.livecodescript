script "TestDocsCache"
-- OXT-Beyond: tests of the IDE's documentation cache
-- (ide/Toolset/libraries/revidedocumentationlibrary.livecodescript), with a
-- stand-in for the IDE handlers it calls. Every build of one engine version
-- shares one cache folder, and its api.sqlite used to be copied from the
-- distributed one only when there was none: a cache an older build made was
-- kept for good, and one made while no api.sqlite shipped held only the
-- extensions' docs, so the Script Editor and the xTalk Assistant found no
-- entry for "put". The cache now notes the distributed file it holds and,
-- when that changes, takes the distributed libraries' entries afresh and
-- keeps the extensions'.

constant kStub = "revDocsCacheTestIDE"

-- This test's folders: the distributed dictionary's and the cache's
local sFolder, sDistFolder, sCacheFolder

on TestSetup
   local tStub
   TestSkipIfNot "docs"
   TestSkipIfNot "database", "sqlite"
   TestLoadExternal "revdb"

   start using stack (TestGetEngineRepositoryPath() & "/ide-support/revdocsparser.livecodescript")

   put specialFolderPath("temporary") & "/oxt-docs-cache-" & the milliseconds into sFolder
   put sFolder & "/dist" into sDistFolder
   put sFolder & "/cache" into sCacheFolder
   create folder sFolder
   create folder sDistFolder
   create folder sCacheFolder

   -- The IDE's handlers the library calls, the folders from this test
   put "function revIDESpecialFolderPath pKey" & return & \
         "if pKey is `API` then" & return & "return the cDistFolder of me" & return & \
         "else if pKey is `documentation cache` then" & return & "return the cCacheFolder of me" & return & \
         "end if" & return & "return empty" & return & "end revIDESpecialFolderPath" & return & \
         "function revEnvironmentIsInstalled" & return & "return true" & return & \
         "end revEnvironmentIsInstalled" & return & \
         "on ideThrow pMessage, pDetail" & return & "throw pMessage & return & pDetail" & return & \
         "end ideThrow" & return into tStub
   replace "`" with quote in tStub
   create stack kStub
   set the script of stack kStub to tStub
   set the cDistFolder of stack kStub to sDistFolder
   set the cCacheFolder of stack kStub to sCacheFolder
   start using stack kStub

   start using stack (TestGetIDERepositoryPath() & "/Toolset/libraries/revidedocumentationlibrary.livecodescript")
end TestSetup

on TestTeardown
   __CloseCache
   if sFolder is not empty and there is a folder sFolder then
      __DeleteFolder sFolder
   end if
end TestTeardown

--------------------------------------------------------------------------------
-- Helpers

-- Adds a library's entries (pEntries: "name,type" lines) under API pAPI to
-- the api.sqlite in pFolder, as the IDE writes them
private command __AddDocs pFolder, pAPI, pLibrary, pEntries
   local tConnection, tLibraryA, tCount, tResult
   revDocsOpenAPIDatabase pFolder
   put the result into tConnection
   if tConnection is not a number then
      throw "unable to open" && pFolder & return & tConnection
   end if
   put pLibrary into tLibraryA["display name"]
   repeat for each line tLine in pEntries
      add 1 to tCount
      put item 1 of tLine into tLibraryA["doc"][tCount]["display name"]
      put item 1 of tLine into tLibraryA["doc"][tCount]["name"]
      put item 2 of tLine into tLibraryA["doc"][tCount]["type"]
      put pLibrary into tLibraryA["doc"][tCount]["library"]
   end repeat
   revExecuteSQL tConnection, "BEGIN TRANSACTION"
   revDocsUpdateDatabase tConnection, pAPI, tLibraryA
   put the result into tResult
   revExecuteSQL tConnection, "COMMIT"
   revCloseDatabase tConnection
   if tResult is not empty then
      throw "unable to add" && pLibrary & return & tResult
   end if
end __AddDocs

-- The distributed dictionary: the core libraries, as the build makes it
private command __MakeDistributed pScriptEntries
   __AddDocs sDistFolder, "livecode_script", "LiveCode Script", pScriptEntries
   __AddDocs sDistFolder, "livecode_builder", "LiveCode Builder", "variable,statement"
   __AddDocs sDistFolder, "livecode_script", "Data Grid", "dgText,property"
end __MakeDistributed

-- How many entries a lookup of pTerm in the xTalk Script dictionary finds,
-- through the library as the Script Editor and the xTalk Assistant look
private function __Found pTerm
   local tEntries
   put ideDocsFetchLCSData(pTerm) into tEntries
   if tEntries is not an array then
      return 0
   end if
   return the number of elements of tEntries
end __Found

-- Every entry of the cache, "library:name" lines, sorted
private function __CacheEntries
   local tConnection, tEntries
   put revOpenDatabase("sqlite", sCacheFolder & "/api.sqlite",,,,,,) into tConnection
   put revDataFromQuery(":", return, tConnection, \
         "SELECT library_name, entry_name FROM dictionary_data") into tEntries
   revCloseDatabase tConnection
   sort lines of tEntries
   return tEntries
end __CacheEntries

private function __Digest pFile
   local tHex
   get binaryDecode("H*", md5Digest(url ("binfile:" & pFile)), tHex)
   return tHex
end __Digest

private function __Note
   return url ("binfile:" & sCacheFolder & "/api.sqlite.source")
end __Note

-- Closes the library's cache connection (the only one these tests leave
-- open), as quitting the IDE does: the next lookup opens it again, as the
-- next session's first does
private command __CloseCache
   try
      repeat for each item tConnection in revOpenDatabases()
         revCloseDatabase tConnection
      end repeat
   catch tError
   end try
end __CloseCache

private command __DeleteFolder pFolder
   repeat for each line tFile in files(pFolder)
      delete file (pFolder & slash & tFile)
   end repeat
   repeat for each line tSub in folders(pFolder)
      if tSub is not among the items of ".,.." then
         __DeleteFolder pFolder & slash & tSub
      end if
   end repeat
   delete folder pFolder
end __DeleteFolder

--------------------------------------------------------------------------------
-- Tests

-- The first lookup with no cache copies the distributed file, and notes it,
-- so it is not taken again
on TestFreshCacheIsACopy
   __MakeDistributed "put,command" & return & "menuPick,message"
   TestAssert "put found", __Found("put") is 1
   TestAssert "menuPick found", __Found("menuPick") is 1
   TestAssert "the cache is the distributed file", \
         __Digest(sCacheFolder & "/api.sqlite") is __Digest(sDistFolder & "/api.sqlite")
   TestAssert "the cache notes the distributed file", __Note() is __Digest(sDistFolder & "/api.sqlite")
end TestFreshCacheIsACopy

-- A cache that holds only extensions' docs, as one made while no
-- api.sqlite shipped does, gets the core entries and keeps the extensions'
on TestCacheOfExtensionsOnly
   local tEntries
   __AddDocs sCacheFolder, "livecode_script", "Tree View", "treeViewSelect,message" & return & "pathDelimiter,property"
   __MakeDistributed "put,command" & return & "menuPick,message" & return & "menubar,property"

   TestAssert "put found", __Found("put") is 1
   TestAssert "menuPick found", __Found("menuPick") is 1
   TestAssert "menuBar found whatever its case", __Found("menuBar") is 1
   put __CacheEntries() into tEntries
   TestDiagnostic tEntries
   TestAssert "extension entries kept", "Tree View:treeViewSelect" is among the lines of tEntries \
         and "Tree View:pathDelimiter" is among the lines of tEntries
   TestAssert "builder entries in", "LiveCode Builder:variable" is among the lines of tEntries
   TestAssert "Data Grid entries in", "Data Grid:dgText" is among the lines of tEntries
   TestAssert "nothing twice", the number of lines of tEntries is 7
   TestAssert "the cache notes the distributed file", __Note() is __Digest(sDistFolder & "/api.sqlite")
   TestAssert "the library names", ideDocsFetchLibraryNames() is \
         "Data Grid" & return & "LiveCode Builder" & return & "LiveCode Script" & return & "Tree View"
end TestCacheOfExtensionsOnly

-- An empty cache file, as the copy of a missing file leaves, has no tables
on TestEmptyCacheFile
   put empty into url ("binfile:" & sCacheFolder & "/api.sqlite")
   __MakeDistributed "put,command"
   TestAssert "put found", __Found("put") is 1
   TestAssert "the cache notes the distributed file", __Note() is __Digest(sDistFolder & "/api.sqlite")
end TestEmptyCacheFile

-- With no distributed file the cache is left as it is and nothing is noted;
-- once one ships, the next session takes its entries
on TestDistributedFileArrivesLater
   __AddDocs sCacheFolder, "livecode_script", "Tree View", "treeViewSelect,message"
   TestAssert "nothing found while none ships", __Found("put") is 0
   TestAssert "nothing noted", there is not a file (sCacheFolder & "/api.sqlite.source")
   TestAssert "extension entries as they were", __CacheEntries() is "Tree View:treeViewSelect"

   __CloseCache
   __MakeDistributed "put,command"
   TestAssert "put found once it ships", __Found("put") is 1
   TestAssert "extension entries kept", "Tree View:treeViewSelect" is among the lines of __CacheEntries()
end TestDistributedFileArrivesLater

-- The cache is taken from the distributed file once: a later session with
-- the same file changes nothing, and a new file replaces the core entries
-- (one it no longer has goes) and keeps the extensions'
on TestNewDistributedFileReplacesCoreEntries
   local tConnection, tEntries
   __AddDocs sCacheFolder, "livecode_script", "Tree View", "treeViewSelect,message"
   __MakeDistributed "put,command" & return & "oldEntry,command"
   TestAssert "put found", __Found("put") is 1
   TestAssert "oldEntry found", __Found("oldEntry") is 1
   __CloseCache

   -- A mark in the cache that taking the distributed entries again would remove
   __AddDocs sCacheFolder, "livecode_script", "LiveCode Script", "mark,command"
   TestAssert "the same file is not taken again", __Found("mark") is 1
   __CloseCache

   -- The next release's file
   delete file (sDistFolder & "/api.sqlite")
   __MakeDistributed "put,command" & return & "find,command"
   TestAssert "the new entry found", __Found("find") is 1
   TestAssert "the old entry gone", __Found("oldEntry") is 0
   TestAssert "the mark gone", __Found("mark") is 0
   TestAssert "put found once", __Found("put") is 1
   put __CacheEntries() into tEntries
   TestDiagnostic tEntries
   TestAssert "extension entries kept", "Tree View:treeViewSelect" is among the lines of tEntries
   TestAssert "nothing twice", the number of lines of tEntries is 5
   TestAssert "the cache notes the new file", __Note() is __Digest(sDistFolder & "/api.sqlite")
end TestNewDistributedFileReplacesCoreEntries

-- A distributed file that is not a dictionary changes nothing, and is tried
-- again next session
on TestBrokenDistributedFile
   __AddDocs sCacheFolder, "livecode_script", "Tree View", "treeViewSelect,message"
   put "not a database" into url ("binfile:" & sDistFolder & "/api.sqlite")
   TestAssert "nothing found", __Found("put") is 0
   TestAssert "extension entry still found", the number of elements of ideDocsFetchScriptData("treeViewSelect") is 1
   TestAssert "nothing noted", there is not a file (sCacheFolder & "/api.sqlite.source")
   TestAssert "extension entries as they were", __CacheEntries() is "Tree View:treeViewSelect"
end TestBrokenDistributedFile
