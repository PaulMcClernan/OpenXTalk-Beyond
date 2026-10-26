script "stack_revDictionary"
-- Stack file: ide/Toolset/palettes/dictionary/revdictionary.livecode
-- Object: stack "revDictionary"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
   set the cantModify of me to false	
   dispatch  "setAsBehavior" to  stack  (revEnvironmentToolsetPath() & "/palettes/dictionary/behaviors/revdictionarybehavior.livecodescript") with the long id of me
   -- dispatch "setAsBehavior" to stack revIDEPaletteResourcePath("behaviors/revdictionarybehavior.livecodescript") with the long id of me
   set the showPreferenceAction of me to false	
   set the navigationDisplayStyle of me to "names"
   clearFrameData
   addFrameItem "show_apis","header", "navigation", "API", "f1b3", "f1b3","showAPIs", the long id of me
   addFrameItem "show_guides","header", "navigation", "Guide", "f1b3", "f1b3","showGuides", the long id of me
end preOpenStack

on goToEntry pLibrary, pName, pType
   dispatch  "setAsBehavior" to  stack  (revEnvironmentToolsetPath() & "/palettes/dictionary/behaviors/revdictionarybehavior.livecodescript") with the long id of me
   -- dispatch "setAsBehavior" to stack revIDEPaletteResourcePath("behaviors/revdictionarybehavior.livecodescript") with the long id of me
   dispatch "navigateToEntry" to me with pLibrary, pName, pType
end goToEntry
