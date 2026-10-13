script "org.openxtalk.plugin.mcpbridge"
-- OXT-Beyond: the xTalk MCP Bridge, which lets Claude, in the Claude
-- desktop app or Claude Code, signed in with the user's own Claude plan
-- (Free, Pro, Max, Team or Enterprise), read and build the stacks open in
-- this IDE: their cards, controls and scripts, new stacks, code run in a
-- sandbox, all with the xTalk Assistant's tools.
--
-- Why a bridge. The xTalk Assistant talks to a model with an API key the
-- user pastes; a Claude plan cannot be used that way, because Anthropic lets
-- no program but its own sign in to a Claude account (its terms for Claude
-- Code and the Agent SDK). So the bridge turns it around: the user adds
-- OXT-Beyond to Claude's own app as an MCP server (mcp/server.js in this
-- folder, which that app starts and signs nothing in), and the server asks
-- this IDE, over a socket only this computer reaches, to do what Claude
-- asks for. The plan pays for the model; this IDE holds no key, account or
-- password, and sends nothing to the internet. It is an addition beside the
-- assistant, which stays as it is: either, both or neither can be on.
--
-- Off by default. The IDE loads this stack as it loads every extension,
-- and while the bridge is off that is all that happens: nothing listens,
-- nothing is loaded. The only thing it adds is the "xTalk MCP Bridge" item
-- of Development > Plugins (revmenubar.livecodescript), which asks the user
-- before turning it on. Once on, it stays on from one session to the next
-- (it starts a moment after the IDE does) until the user turns it off from
-- the same item. Set the environment variable OXTBEYOND_MCP_BRIDGE to "off"
-- to keep it off for good.
--
-- Files: this stack (the plugin's lifecycle, its dialogs, and the
-- functions the bridge asks: mcbConfirm, mcbEditorStack and
-- mcbEditorContext), mcpbridge-errors.livecodescript (notes the errors the
-- IDE shows the user, for ide_context),
-- mcpbridge-tools.livecodescript (the socket and the tools, tested by
-- tests/lcs/mcpbridge), mcp/server.js (the MCP server, tested by
-- tools/ci/tests/test_mcp_bridge_server.py) and mcp/manifest.json (what
-- makes it a Claude desktop extension, a .mcpb file the setup dialog
-- saves). The tools come from the xTalk Assistant's folder
-- (org.openxtalk.plugin.xtalkassistant), its core and build library and
-- its guide.
--
-- Public handlers (all reached with dispatch):
--    mcpBridgeMenuPick           Development > Plugins > xTalk MCP Bridge
--    mcbIsEnabled()
--    mcbConfirm(pTitle, pDetail, pYes), mcbEditorStack(),
--    mcbEditorContext()          (the bridge's)

constant kTitle = "xTalk MCP Bridge"
constant kTools = "org.openxtalk.plugin.mcpbridge-tools"
constant kAssistantFolderName = "org.openxtalk.plugin.xtalkassistant"
-- Preferences (custom properties of the revPreferences stack)
constant kPrefEnabled = "cMcpBridge,enabled"
-- The name Claude's apps show for the server
constant kServerName = "oxt-beyond"

-- Why the bridge could not start when it last tried, for the menu item
local sStartProblem

on extensionInitialize
   if the target is not me then
      pass extensionInitialize
   end if
   -- Part of the IDE, not of the user's work
   set the _ideoverride of me to true
   -- Turned on in an earlier session: started once the IDE is up
   if mcbIsEnabled() then
      send "mcbAutoStart" to me in 2 seconds
   end if
end extensionInitialize

on extensionFinalize
   if the target is not me then
      pass extensionFinalize
   end if
   mcbStop
end extensionFinalize

on mcbAutoStart
   if not mcbIsEnabled() then
      exit mcbAutoStart
   end if
   put mcbStart() into sStartProblem
end mcbAutoStart

--------------------------------------------------------------------------------
-- On and off

function mcbIsEnabled
   if mcbIsLockedOff() then
      return false
   end if
   return revIDEGetPreference(kPrefEnabled) is true
end mcbIsEnabled

private function mcbIsLockedOff
   return toLower($OXTBEYOND_MCP_BRIDGE) is among the items of "off,0,false,no"
end mcbIsLockedOff

command mcpBridgeMenuPick
   local tProblem, tPort, tClients, tText
   if mcbIsLockedOff() then
      answer information "The xTalk MCP Bridge is turned off on this computer (by the environment variable OXTBEYOND_MCP_BRIDGE)." titled kTitle
      exit mcpBridgeMenuPick
   end if
   if not mcbIsEnabled() then
      answer question "The xTalk MCP Bridge lets Claude, in the Claude desktop app or in Claude Code, work on the stacks you have open here: read them, build cards, controls, scripts and new stacks, and try code. It uses your own Claude plan (Free, Pro, Max, Team or Enterprise): you sign in to Claude's app as usual, and this IDE needs no API key." & return & return & \
            "Turning it on starts a connection that only programs on this computer can reach, with a key that is kept in a file only you can read, and OXT-Beyond sends nothing to the internet. Then you add OXT-Beyond to Claude once (the next window shows how)." & return & return & \
            "Claude's app asks you before it uses each tool. Here you are asked before any code Claude sends runs (you see the code), and before a stack is saved; everything else Claude changes can be undone from this menu item." \
            with "Cancel" or "Turn On" titled kTitle
      if it is not "Turn On" then
         exit mcpBridgeMenuPick
      end if
      put mcbStart() into tProblem
      if tProblem is not empty then
         answer error "The bridge could not start:" && tProblem titled kTitle
         exit mcpBridgeMenuPick
      end if
      revIDESetPreference kPrefEnabled, true
      mcbSetupDialog
      exit mcpBridgeMenuPick
   end if
   -- On: started at launch, or not when that failed
   if mcbPort() is empty then
      put mcbStart() into sStartProblem
   end if
   put mcbPort() into tPort
   if tPort is empty then
      answer error "The xTalk MCP Bridge is on but could not start:" && sStartProblem with "Turn Off" or "Close" titled kTitle
      if it is "Turn Off" then
         mcbTurnOff
      end if
      exit mcpBridgeMenuPick
   end if
   put mcbClients() into tClients
   if tClients is 0 then
      put "The xTalk MCP Bridge is on. Claude is not connected yet: in Claude's app, ask it to do something with OXT-Beyond." into tText
   else
      put "The xTalk MCP Bridge is on, and Claude is connected." into tText
   end if
   put return & return & "Undo Last Change takes back the newest change Claude made to a stack, or the newest run of its code on one." after tText
   answer information tText with "Turn Off" or "Undo Last Change" or "Claude Setup..." or "Close" titled kTitle
   switch it
      case "Turn Off"
         mcbTurnOff
         break
      case "Undo Last Change"
         mcbUndoLastChange
         break
      case "Claude Setup..."
         mcbSetupDialog
         break
   end switch
end mcpBridgeMenuPick

private command mcbTurnOff
   answer question "Turn the xTalk MCP Bridge off? Claude can no longer reach OXT-Beyond, and what it changed can no longer be undone from here (it stays as it is). You can turn it on again from Development > Plugins." \
         with "Cancel" or "Turn Off" titled kTitle
   if it is not "Turn Off" then
      exit mcbTurnOff
   end if
   revIDESetPreference kPrefEnabled, false
   mcbStop
end mcbTurnOff

private command mcbUndoLastChange
   local tUndone
   put mcbUndoLast() into tUndone
   answer information tUndone["text"] titled kTitle
end mcbUndoLastChange

-- Loads the bridge's library and starts it; empty, or why it could not
private function mcbStart
   local tFolder, tError
   put mcbPluginFolder() into tFolder
   try
      if there is not a stack kTools then
         get the short name of stack (tFolder & "/mcpbridge-tools.livecodescript")
      end if
      if not mcbToolsInUse() then
         start using stack kTools
      end if
      set the _ideoverride of stack kTools to true
      get mcbServerStart(mcbAssistantFolder(), the long id of me, empty)
   catch tError
      return line 1 of tError
   end try
   return empty
end mcbStart

private command mcbStop
   local tError
   if mcbToolsInUse() then
      try
         mcbServerStop
      catch tError
      end try
      stop using stack kTools
   end if
   put empty into sStartProblem
end mcbStop

private function mcbToolsInUse
   local tLine
   if there is not a stack kTools then
      return false
   end if
   repeat for each line tLine in the stacksInUse
      if there is a stack tLine and the long id of stack tLine is the long id of stack kTools then
         return true
      end if
   end repeat
   return false
end mcbToolsInUse

private function mcbPort
   if not mcbToolsInUse() then
      return empty
   end if
   return mcbServerPort()
end mcbPort

private function mcbClients
   if not mcbToolsInUse() then
      return 0
   end if
   return mcbServerClients()
end mcbClients

private function mcbPluginFolder
   set the itemDelimiter to slash
   return item 1 to -2 of the effective filename of me
end mcbPluginFolder

-- The xTalk Assistant's folder, beside this one
private function mcbAssistantFolder
   set the itemDelimiter to slash
   return item 1 to -2 of mcbPluginFolder() & slash & kAssistantFolderName
end mcbAssistantFolder

--------------------------------------------------------------------------------
-- Setting Claude up

private command mcbSetupDialog
   local tText
   put "Add OXT-Beyond to Claude once, in the app you use:" & return & return & \
         "Claude desktop app: press Save Desktop Extension..., then open the file it saves (or, in Claude, Settings > Extensions > Advanced settings > Install Extension... and choose it). Claude's app runs it with its own Node.js; you install nothing else." & return & return & \
         "Claude Code: press Copy Claude Code Command and paste it into a terminal. It needs Node.js 16 or later." & return & return & \
         "Copy Desktop Config gives the entry for Claude's claude_desktop_config.json instead, for a computer with Node.js." & return & return & \
         "Then sign in to Claude with your own account, as usual, and ask it to work on your stack. This IDE must be open with the bridge on." into tText
   answer information tText with "Save Desktop Extension..." or "Copy Claude Code Command" or "Copy Desktop Config" or "Close" titled kTitle
   switch it
      case "Save Desktop Extension..."
         mcbSaveDesktopExtension
         break
      case "Copy Claude Code Command"
         set the clipboardData["text"] to mcbClaudeCodeCommand()
         answer information "Copied. Paste it into a terminal, then start Claude Code (claude) and ask it to work on your stack:" & return & return & mcbClaudeCodeCommand() titled kTitle
         break
      case "Copy Desktop Config"
         set the clipboardData["text"] to mcbDesktopConfig()
         answer information "Copied. In the Claude desktop app, open Settings > Developer > Edit Config, put this entry under" && quote & "mcpServers" & quote & ", save, and restart Claude:" & return & return & mcbDesktopConfig() titled kTitle
         break
   end switch
end mcbSetupDialog

-- The server's file, in the form of the platform's paths
private function mcbServerPath
   local tPath
   put mcbPluginFolder() & "/mcp/server.js" into tPath
   if the platform is "Win32" then
      replace slash with backslash in tPath
   end if
   return tPath
end mcbServerPath

private function mcbClaudeCodeCommand
   return "claude mcp add --scope user" && kServerName && "-- node" && quote & mcbServerPath() & quote
end mcbClaudeCodeCommand

private function mcbDesktopConfig
   local tPath
   put mcbServerPath() into tPath
   replace backslash with backslash & backslash in tPath
   replace quote with backslash & quote in tPath
   return quote & kServerName & quote & ": {" & return & \
         "  " & quote & "command" & quote & ": " & quote & "node" & quote & "," & return & \
         "  " & quote & "args" & quote & ": [" & quote & tPath & quote & "]" & return & "}"
end mcbDesktopConfig

-- A Claude desktop extension (.mcpb): a zip of the manifest and the
-- server, which Claude's app installs and runs with its own Node.js
private command mcbSaveDesktopExtension
   local tFile, tArchive, tProblem, tError
   ask file "Save the Claude desktop extension as:" with "OXT-Beyond.mcpb"
   if it is empty then
      exit mcbSaveDesktopExtension
   end if
   put it into tFile
   if not (tFile ends with ".mcpb") then
      put ".mcpb" after tFile
   end if
   if there is a file tFile then
      delete file tFile
   end if
   try
      revZipOpenArchive tFile, "write"
      put the result into tProblem
      if tProblem is empty then
         revZipAddItemWithFile tFile, "manifest.json", mcbPluginFolder() & "/mcp/manifest.json"
         put the result into tProblem
      end if
      if tProblem is empty then
         revZipAddItemWithFile tFile, "server.js", mcbPluginFolder() & "/mcp/server.js"
         put the result into tProblem
      end if
      revZipCloseArchive tFile
      if tProblem is empty then
         put the result into tProblem
      end if
   catch tError
      put "the zip library is not available (" & line 1 of tError & ")" into tProblem
   end try
   if tProblem is not empty then
      answer error "The extension could not be saved:" && tProblem & return & return & \
            "Copy Desktop Config sets Claude up another way." titled kTitle
      exit mcbSaveDesktopExtension
   end if
   answer information "Saved" && tFile & "." & return & return & \
         "Open it (double-click it) to install it in the Claude desktop app, or in Claude choose Settings > Extensions > Advanced settings > Install Extension... and choose it." titled kTitle
end mcbSaveDesktopExtension

--------------------------------------------------------------------------------
-- What the bridge asks

-- Asks the user before what cannot be undone; true when they said yes
function mcbConfirm pTitle, pDetail, pYes
   answer question pTitle & return & return & pDetail with "Cancel" or pYes titled kTitle
   return it is pYes
end mcbConfirm

-- The stack of the script open in the Script Editor, or empty
function mcbEditorStack
   local tEditor, tObject, tError
   try
      put revTopMostScriptEditor() into tEditor
      if tEditor is empty or there is not a tEditor then
         return empty
      end if
      dispatch "revSEGetCurrentObject" to tEditor
      put the result into tObject
      if tObject is empty or there is not a tObject then
         return empty
      end if
      return revIDEStackOfObject(tObject)
   catch tError
      return empty
   end try
end mcbEditorStack

-- The script open in the topmost Script Editor: an array with "object"
-- (its long id), "line" (the line the caret was last on, or empty) and
-- "unapplied" (true when the editor holds changes not yet applied), or
-- empty when no script is open
function mcbEditorContext
   local tEditor, tObject, tContext, tLine, tError
   try
      put revTopMostScriptEditor() into tEditor
      if tEditor is empty or there is not a tEditor then
         return empty
      end if
      dispatch "revSEGetCurrentObject" to tEditor
      put the result into tObject
      if tObject is empty or there is not a tObject then
         return empty
      end if
      put the long id of tObject into tContext["object"]
      dispatch function "revSEGetLastSelectedLine" to tEditor
      put the result into tContext["line"]
      -- The objects whose scripts the user changed and has not applied
      put false into tContext["unapplied"]
      dispatch "revSEGetModifiedObjects" to tEditor
      repeat for each line tLine in the result
         if there is a tLine then
            if the long id of tLine is tContext["object"] then
               put true into tContext["unapplied"]
            end if
         end if
      end repeat
   catch tError
      return empty
   end try
   return tContext
end mcbEditorContext
