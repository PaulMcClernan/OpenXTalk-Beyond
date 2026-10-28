script "editor-theme-check"
-- Run with a development engine and -ui. Uses isolated preference stubs;
-- no user preferences are loaded or written.
local sDark, sPrefs, sFailed
on startup
   create invisible stack "revSETemplate"
   local tRoot
   put the filename of me into tRoot
   set the itemDelimiter to slash
   delete item -3 to -1 of tRoot
   start using stack (tRoot & "/ide/Toolset/palettes/script editor/behaviors/revseutilities.livecodescript")
   put false into sDark
   sePrefInit
   check sePrefGet("editor,backgroundcolor"), "255,255,255", "light background"
   check sePrefGet("editor,textcolor"), "0,0,0", "light text"
   check (sePrefGet("colorization,config") contains "class identifier none 0,0,0"), true, "light syntax"
   put true into sDark
   sePrefInit
   check sePrefGet("editor,backgroundcolor"), "30,30,30", "dark background"
   check sePrefGet("editor,textcolor"), "238,238,238", "dark text"
   check (sePrefGet("colorization,config") contains "class identifier none 238,238,238"), true, "dark syntax"
   put "12,34,56" into sPrefs["cScriptEditor,editor,backgroundcolor"]
   sePrefInit
   check sePrefGet("editor,backgroundcolor"), "12,34,56", "keep custom background"
   check sePrefGet("colorization,scheme"), "default", "keep light scheme preference"
   put "oxt lite dark" into sPrefs["cScriptEditor,colorization,schemedark"]
   sePrefInit
   local tExpected
   seColorizationLoadScheme "oxt lite dark", tExpected
   check sePrefGet("colorization,config"), tExpected["colorization,config"], "honor schemedark"
   put false into sDark
   sePrefInit
   check (sePrefGet("colorization,config") contains "class identifier none 0,0,0"), true, "restore light scheme"
   if sFailed then quit 1
   write "PASS editor theme preferences" & return to stdout
   quit
end startup
function revIDEAppearanceIsDark
   return sDark
end revIDEAppearanceIsDark
function revIDEGetPreference pKey
   return sPrefs[pKey]
end revIDEGetPreference
command check pActual, pExpected, pName
   if pActual is not pExpected then
      write "FAIL " & pName & ": " & pActual & return to stdout
      put true into sFailed
   end if
end check
