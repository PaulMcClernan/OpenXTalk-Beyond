script "stack_revPreferencesGUI_button_id_1505"
-- Stack file: ide/Toolset/palettes/revpreferencesgui.rev
-- Object: stack "revPreferencesGUI" > card "Script Editor" (id 1010) > group "Script Editor" (id 1142) > button "editorsList" (id 1505)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseenter
   tUpdateEditors
end mouseenter

on menupick pitem
   -- OXT-Beyond: "Other..." asks for any editor (#173)
   if pitem is "Other..." then
      tChooseOtherEditor
      exit menupick
   end if
   put the cCommands of me into tCommandsList
   -- OXT-Beyond: the command on the line of the item picked. lineOffset
   -- alone took the first command that only contained the name: "ed"
   -- picked /usr/bin/gedit, and "code" would pick any path with "code"
   put the menuHistory of me into tLine
   if tLine is not an integer or line tLine of the text of me is not pitem then
      put lineOffset(pitem,tCommandsList) into tFoundOnLine
      put tFoundOnLine into tLine
   end if
   put line tLine of tCommandsList into tExternalEditorCommand
   set the cExternalScriptEditorName of stack "revPreferences" to pitem
   set the cExternalEditorCommand of stack "revPreferences" to tExternalEditorCommand
   set the showname of btn "editorsList" of this card to true
   
end menupick

on tUpdateEditors
   local tEditProgs
   local tcount
   put "" into tEditProgs
   set the cCommands of me to ""
   if the platform contains "lin" then
      -- look for linux text editors
      put the itemdelimiter into tOldDelim
      set the itemdelimiter to ","
      -- OXT-Beyond: also code, codium, geany, pulsar, subl, xed and zed (#173)
      put "bluefish,bvi,code,codium,cream,dav-text,dte,e3,ed,eftp,emacs,emacs-gtk,featherpad,fte,geany,gedit,ghostwriter,gnome-text-editor,gobby,gprompter,jed,joe,jove,juffed,jupp,kakoune,kate,kephra,kwrite,l3afpad,leafpad,le,levee,micro,mousepad,nano,nano-tiny,ne,nedit,notepadqq,nvi,omegat,pluma,pulsar,retext,subl,tea,the,tilde,vile,vis,xed,yudit,zed,zim" into tProgs
      put 0 into tcount
      repeat the number of items in tProgs
         add 1 to tcount
         put item tcount of tProgs into tBinName
         if tCheckForLinuxBinary(tBinName, the number of lines of tEditProgs +1) is true then put tBinName into line (the number of lines of tEditProgs +1) of tEditProgs
      end repeat
      set the itemdelimiter to tOldDelim
      filter lines of tEditProgs without empty
      set the text of me to tEditProgs
   end if
   -- mac version
   if the platform contains "mac" then
      -- look for mac text editors
      put the itemdelimiter into tOldDelim
      set the itemdelimiter to ","
      -- OXT-Beyond: the usual Mac editors, not only BBEdit and TextEdit (#173)
      put "BBEdit,CotEditor,Sublime Text,Visual Studio Code,VSCodium,Pulsar,Nova,TextMate,Zed,MacVim,CodeEdit,TextEdit" into tProgs
      put 0 into tcount
      repeat the number of items in tProgs
         add 1 to tcount
         put item tcount of tProgs into tAppName
         if tCheckForMacApp(tAppName, the number of lines of tEditProgs +1) is true then put tAppName into line (the number of lines of tEditProgs +1) of tEditProgs
      end repeat
      set the itemdelimiter to tOldDelim
      filter lines of tEditProgs without empty
      set the text of me to tEditProgs
   end if
   
   -- OXT-Beyond: an editor chosen with "Other..." stays in the menu, and
   -- "Other..." lets the user pick any application (Mac) or program (Linux)
   -- that the lists above do not have (#173)
   if the platform contains "mac" or the platform contains "lin" then
      local tSavedName, tSavedCommand, tSavedCommands
      put the cExternalScriptEditorName of stack "revPreferences" into tSavedName
      put the cExternalEditorCommand of stack "revPreferences" into tSavedCommand
      if tSavedName is not empty and tSavedCommand is not empty and tSavedName is not among the lines of tEditProgs then
         put the cCommands of me into tSavedCommands
         if tEditProgs is empty then
            put tSavedName into tEditProgs
            put tSavedCommand into tSavedCommands
         else
            put return & tSavedName after tEditProgs
            put return & tSavedCommand after tSavedCommands
         end if
         set the cCommands of me to tSavedCommands
      end if
      if tEditProgs is empty then
         put "Other..." into tEditProgs
      else
         put return & "Other..." after tEditProgs
      end if
      set the text of me to tEditProgs
      if tSavedName is among the lines of tEditProgs then
         lock messages
         repeat with tcount = 1 to the number of lines of tEditProgs
            if line tcount of tEditProgs is tSavedName then
               set the menuHistory of me to tcount
               exit repeat
            end if
         end repeat
         unlock messages
      end if
   end if
   if tEditProgs is not empty then set the showname of btn "editorsList" of this card to true
end tUpdateEditors

-- OXT-Beyond: "Other..." in the menu: any application (Mac) or program
-- (Linux) as the external script editor (#173). The command is stored as
-- the lists store theirs: the application's folder with a slash (Mac), the
-- program's path (Linux, quoted when it has a space)
on tChooseOtherEditor
   local tPath, tName, tCommand
   if the platform contains "mac" then
      answer file "Choose the application to edit scripts in:" with "/Applications" with type "Applications|app|APPL"
   else
      answer file "Choose the program to edit scripts with:" with "/usr/bin"
   end if
   put it into tPath
   if tPath is empty then
      -- cancelled: the menu shows the editor chosen before
      tUpdateEditors
      exit tChooseOtherEditor
   end if
   if the last char of tPath is "/" then delete the last char of tPath
   set the itemdelimiter to "/"
   put the last item of tPath into tName
   set the itemdelimiter to ","
   if the platform contains "mac" then
      if tName ends with ".app" then delete char -4 to -1 of tName
      put tPath & "/" into tCommand
   else if tPath contains space then
      put "'" & tPath & "'" into tCommand
   else
      put tPath into tCommand
   end if
   set the cExternalScriptEditorName of stack "revPreferences" to tName
   set the cExternalEditorCommand of stack "revPreferences" to tCommand
   tUpdateEditors
   set the showname of btn "editorsList" of this card to true
end tChooseOtherEditor

function tCheckForLinuxBinary tBin tnum
   local tExecCommand
   put ("/usr/bin/" & tBin) into tExecCommand
   if there is a file tExecCommand then
      put the cCommands of btn "editorsList" into tCommands
      put tExecCommand into line tnum of tCommands
      filter lines of tCommands without empty
      set the cCommands of btn "editorsList" to tCommands
      return true
   else
      return false
   end if
end tCheckForLinuxBinary

function tCheckForMacApp tApp tnum
   local tExecCommand
   put ("/Applications/" & tApp & ".app/") into tExecCommand
   put ("/System/Applications/" & tApp & ".app/") into tExecCommandDoubleTap
   -- OXT-Beyond: also the Applications folder in the user's home folder (#173)
   if there is not a folder tExecCommand and there is a folder (specialFolderPath("home") & "/Applications/" & tApp & ".app/") then
      put (specialFolderPath("home") & "/Applications/" & tApp & ".app/") into tExecCommand
   end if
   
   if there is a folder tExecCommand then
      put the cCommands of btn "editorsList" into tCommands
      put tExecCommand into line tnum of tCommands
      filter lines of tCommands without empty
      set the cCommands of btn "editorsList" to tCommands
      return true
   end if
   if there is a folder tExecCommandDoubleTap then
      -- when did Apple change this to prefix "/system/" at the start?
      put the cCommands of btn "editorsList" into tCommands
      put tExecCommandDoubleTap into line tnum of tCommands
      filter lines of tCommands without empty
      set the cCommands of btn "editorsList" to tCommands
      return true
   else
      return false
   end if
end tCheckForMacApp
