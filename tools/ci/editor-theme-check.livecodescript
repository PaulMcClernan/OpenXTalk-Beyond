script "editor-theme-check"
-- Run with a development engine and -ui. Uses isolated preference stubs;
-- no user preferences are loaded or written.
local sDark, sPrefs, sFailed
on startup
   create invisible stack "revPreferences"
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
   check sePrefGet("editor,debugBackgroundcolor"), "30,30,30", "dark debugger background"
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
   -- Saving the mode must stay readable by older builds and plugins.
   sePrefSet "editor,backgroundcolor", "default"
   sePrefSet "editor,debugBackgroundcolor", "default"
   sePrefSave
   check sPrefs["cScriptEditor,editor,backgroundcolor"], empty, "save compatible editor default"
   check sPrefs["cScriptEditor,editor,debugBackgroundcolor"], empty, "save compatible debugger default"
   sePrefInit
   check sePrefGet("editor,backgroundcolor"), "255,255,255", "reload empty as light default"
   sePrefSet "editor,backgroundcolor", "12,34,56"
   sePrefSave
   check sPrefs["cScriptEditor,editor,backgroundcolor"], "12,34,56", "save explicit RGB unchanged"

   -- Model the real message path: utilities are the editor's behavior,
   -- never a global library for Preferences. A fresh Preferences card and
   -- the Follow menu must work without access to sePrefInit/sePrefGet.
   stop using stack (tRoot & "/ide/Toolset/palettes/script editor/behaviors/revseutilities.livecodescript")
   create invisible stack "revNewScriptEditor"
   set the behavior of stack "revNewScriptEditor" to the long id of stack "revseutilities"
   get the short name of stack (tRoot & "/ide/Toolset/palettes/revpreferencesgui.rev")
   dispatch "sePrefInit" to stack "revPreferencesGUI"
   check it, "unhandled", "utilities are outside Preferences message path"
   revIDESetPreference "cScriptEditor,editor,backgroundcolor", empty
   revIDESetPreference "cScriptEditor,editor,debugBackgroundcolor", empty
   revIDESetPreference "cScriptEditor,colorization,schemedark", empty
   put true into sDark
   dispatch "update" to group "Script Editor" of card "Script Editor" of stack "revPreferencesGUI"
   check the cColor of button "Background Color" of card "Script Editor" of stack "revPreferencesGUI", "30,30,30", "fresh Preferences resolves dark background"
   dispatch "menuPick" to button "Colorization Scheme" of card "Script Editor" of stack "revPreferencesGUI" with "Follow System Appearance"
   check sPrefs["cScriptEditor,editor,backgroundcolor"], empty, "Follow menu saves compatible mode"
   check sPrefs["cScriptEditor,editor,debugBackgroundcolor"], empty, "Follow menu resets debugger mode"
   check the cColor of button "Debug Background Color" of card "Script Editor" of stack "revPreferencesGUI", "30,30,30", "Follow menu resolves debugger swatch"
   put false into sDark
   dispatch "update" to group "Script Editor" of card "Script Editor" of stack "revPreferencesGUI"
   check the cColor of button "Background Color" of card "Script Editor" of stack "revPreferencesGUI", "255,255,255", "Preferences resolves light background"
   revIDESetPreference "cScriptEditor,editor,backgroundcolor", "12,34,56"
   dispatch "update" to group "Script Editor" of card "Script Editor" of stack "revPreferencesGUI"
   check the cColor of button "Background Color" of card "Script Editor" of stack "revPreferencesGUI", "12,34,56", "Preferences preserves explicit RGB"
   -- Suppress only the popup's UI in memory; exercise its real menuPick.
   local tMenu, tScript, tStart
   put the long id of button "Colorization Scheme" of card "Script Editor" of stack "revPreferencesGUI" into tMenu
   put the script of tMenu into tScript
   put offset("on doCustomPopup", tScript) into tStart
   delete char tStart to -1 of tScript
   put "on doCustomPopup" & return & "end doCustomPopup" after tScript
   set the script of tMenu to tScript
   dispatch "menuPick" to tMenu with "Custom"
   check sPrefs["cScriptEditor,editor,backgroundcolor"], "12,34,56", "opening Custom preserves background"
   check sPrefs["cScriptEditor,colorization,scheme"], "default", "opening Custom preserves active scheme"
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

command revIDESetPreference pKey, pValue
   put pValue into sPrefs[pKey]
   set the pKey of stack "revPreferences" to pValue
end revIDESetPreference
function revScriptEditorMain
   return the long id of stack "revNewScriptEditor"
end revScriptEditorMain
function revListScriptEditors
   return empty
end revListScriptEditors
