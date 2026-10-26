script "stack_revIDESnippetViewer"
-- Stack file: ide/Toolset/palettes/snippet viewer/revidesnippetviewer.livecode
-- Object: stack "revIDESnippetViewer"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on resizeStack
    revIDESnippetViewerResize
end resizeStack

on preOpenStack
   dispatch "setAsBehavior" to stack revIDEPaletteResourcePath("behaviors/revidesnippetviewerbehavior.livecodescript") with the long id of me
end preOpenStack
