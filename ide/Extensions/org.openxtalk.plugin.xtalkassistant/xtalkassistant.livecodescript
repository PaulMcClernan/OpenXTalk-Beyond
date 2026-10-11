script "org.openxtalk.plugin.xtalkassistant"
-- OXT-Beyond: the xTalk Assistant, an optional AI assistant for writing
-- scripts, with the user's own API key.
--
-- Off by default. The IDE loads this stack as it loads every extension, and
-- while the assistant is off that is all that happens: this stack is not in
-- the message path, the core and the window are not loaded, and nothing
-- talks to the network. The only thing it adds is the "xTalk Assistant"
-- item of Development > Plugins (revmenubar.livecodescript), which asks
-- the user before turning the assistant on. Set the environment variable
-- OXTBEYOND_XTALK_ASSISTANT to "off" to keep it off for good, for example on
-- the computers of a classroom.
--
-- What it does (the first part of the plan): a window to talk to the model
-- the user picks, from Anthropic or OpenAI (or any service or local server
-- with OpenAI's API), with the script open in the Script Editor attached
-- when the user wants, and a button that inserts the code of the answer at
-- the caret in the Script Editor as one undoable step. It never changes a
-- script or an object by itself.
--
-- The key: what the user types is kept in memory until the IDE quits or the
-- user forgets it, and is never written to the preferences, a stack or a
-- log. Without one, ANTHROPIC_API_KEY or OPENAI_API_KEY from the
-- environment is used when it is set. The provider, model and base URL are
-- preferences.
--
-- Files: this stack (the plugin's lifecycle, its settings and the IDE
-- glue), xtalkassistant-core.livecodescript (JSON, the providers, HTTP;
-- tested by tests/lcs/xtalkassistant) and xtalkassistant-window.livecodescript
-- (the window's behavior).
--
-- Public handlers (all reached with dispatch, from the menu bar and the
-- window):
--    xtalkAssistantMenuPick       Development > Plugins > xTalk Assistant
--    xtaSendPrompt, xtaInsertCode, xtaNewConversation, xtaChooseModels,
--    xtaSetIncludeScript, xtaSetProviderByName, xtaSetModel,
--    xtaMoreMenuPick, xtaWindowClosed
--    xtaIsEnabled()

constant kWindow = "revXTalkAssistant"
constant kTitle = "xTalk Assistant"
constant kCore = "org.openxtalk.plugin.xtalkassistant-core"
constant kWindowBehavior = "org.openxtalk.plugin.xtalkassistant-window"
-- Preferences (custom properties of the revPreferences stack)
constant kPrefEnabled = "cXTalkAssistant,enabled"
constant kPrefProvider = "cXTalkAssistant,provider"
constant kPrefModel = "cXTalkAssistant,model,"
constant kPrefBaseUrl = "cXTalkAssistant,baseUrl,"
constant kPrefIncludeScript = "cXTalkAssistant,includeScript"
-- The most of the open script that is sent with a question, in characters
constant kMaxScriptChars = 60000

-- The keys the user typed, by provider. Only ever in memory.
local sKeys
-- The conversation: keys 1 to N, each with "role", "text" (what was typed
-- or answered) and, for a question sent with the open script, "context".
local sTurns
-- True while a question is waiting for its answer
local sBusy
-- Counts the shut-downs, so that an answer that arrives after the assistant
-- was turned off while it waited is dropped rather than kept
local sShutDowns
-- The code blocks of the last answer (as xtaCodeBlocks returns them)
local sLastCode

on extensionInitialize
   if the target is not me then
      pass extensionInitialize
   end if
   -- Part of the IDE, not of the user's work
   set the _ideoverride of me to true
end extensionInitialize

on extensionFinalize
   if the target is not me then
      pass extensionFinalize
   end if
   xtaShutDown
end extensionFinalize

--------------------------------------------------------------------------------
-- On and off

function xtaIsEnabled
   if xtaIsLockedOff() then
      return false
   end if
   return revIDEGetPreference(kPrefEnabled) is true
end xtaIsEnabled

private function xtaIsLockedOff
   return toLower($OXTBEYOND_XTALK_ASSISTANT) is among the items of "off,0,false,no"
end xtaIsLockedOff

command xtalkAssistantMenuPick
   if xtaIsLockedOff() then
      answer information "The xTalk Assistant is turned off on this computer (by the environment variable OXTBEYOND_XTALK_ASSISTANT)." titled kTitle
      exit xtalkAssistantMenuPick
   end if
   if not xtaIsEnabled() then
      answer question "The xTalk Assistant helps you write scripts with an AI model of your choice, from Anthropic or OpenAI (or a service or local server with OpenAI's API), using your own API key." & return & return & \
            "When you press Send, what you typed is sent to that provider, with the script open in the Script Editor while" && quote & "Include the open script" & quote && "is ticked (it is to begin with), and nothing else is. Using it may cost money on your account with the provider." & return & return & \
            "It stays off until you turn it on, and you can turn it off again from its window." \
            with "Cancel" or "Turn On" titled kTitle
      if it is not "Turn On" then
         exit xtalkAssistantMenuPick
      end if
      revIDESetPreference kPrefEnabled, true
      xtaOpenWindow
      -- Just turned on: ask for the key now, so the user sees where it goes
      -- (More > Set API Key... in the window, later). Not for a base URL of
      -- the user's own, which is kept when it is turned off and may need no
      -- key, as Send and Models do.
      get xtaEnsureKey(xtaProvider())
      exit xtalkAssistantMenuPick
   end if
   xtaOpenWindow
end xtalkAssistantMenuPick

private command xtaTurnOff
   answer question "Turn the xTalk Assistant off? Its window closes and the API keys you typed are forgotten. You can turn it on again from Development > Plugins." \
         with "Cancel" or "Turn Off" titled kTitle
   if it is not "Turn Off" then
      exit xtaTurnOff
   end if
   revIDESetPreference kPrefEnabled, false
   xtaShutDown
end xtaTurnOff

-- Forgets everything and unloads what the assistant loaded.
private command xtaShutDown
   add 1 to sShutDowns
   put false into sBusy
   put empty into sKeys
   put empty into sTurns
   put empty into sLastCode
   if there is a stack kWindow then
      close stack kWindow
   end if
   if there is a stack kWindow then
      delete stack kWindow
   end if
   if there is a stack kCore and the long id of stack kCore is among the lines of xtaStacksInUse() then
      stop using stack kCore
   end if
end xtaShutDown

private function xtaStacksInUse
   local tList, tName
   repeat for each line tName in the stacksInUse
      if there is a stack tName then
         put the long id of stack tName & return after tList
      end if
   end repeat
   return tList
end xtaStacksInUse

-- Loads the core and the window's behavior from this stack's folder.
private command xtaLoadParts
   local tFolder
   set the itemDelimiter to slash
   put item 1 to -2 of the effective filename of me into tFolder
   set the itemDelimiter to comma
   if there is not a stack kCore then
      get the short name of stack (tFolder & "/xtalkassistant-core.livecodescript")
   end if
   if the long id of stack kCore is not among the lines of xtaStacksInUse() then
      start using stack kCore
   end if
   if there is not a stack kWindowBehavior then
      get the short name of stack (tFolder & "/xtalkassistant-window.livecodescript")
   end if
   set the _ideoverride of stack kCore to true
   set the _ideoverride of stack kWindowBehavior to true
end xtaLoadParts

--------------------------------------------------------------------------------
-- The window

private command xtaOpenWindow
   local tBuilt
   xtaLoadParts
   if there is not a stack kWindow then
      xtaBuildWindow
      put true into tBuilt
   end if
   xtaRefreshWindow
   -- The window is built invisible, and palette keeps a stack's visible as
   -- it is, so it must be shown: without this the window opened hidden and
   -- turning the assistant on seemed to do nothing. A new window opens in
   -- the middle of the screen; one the user has moved stays where it is.
   lock screen
   if tBuilt is true then
      set the loc of stack kWindow to the screenLoc
   end if
   palette stack kWindow
   set the visible of stack kWindow to true
   unlock screen
   focus on field "Prompt" of stack kWindow
end xtaOpenWindow

on xtaWindowClosed
   -- The conversation stays for the next time the window is opened
end xtaWindowClosed

-- Builds the window: a stack made here rather than shipped as a binary
-- stack, so that all of the plugin is text. Its name begins with "rev", so
-- the IDE treats it as one of its own windows.
private command xtaBuildWindow
   local tOldDefault, tFont
   put the defaultStack into tOldDefault
   lock screen
   lock messages
   create invisible stack kWindow
   set the defaultStack to kWindow
   set the title of stack kWindow to kTitle
   set the width of stack kWindow to 480
   set the height of stack kWindow to 600
   set the minWidth of stack kWindow to 420
   set the minHeight of stack kWindow to 360
   set the resizable of stack kWindow to true
   set the destroyStack of stack kWindow to true

   create button "Provider"
   set the style of button "Provider" to "menu"
   set the menuMode of button "Provider" to "option"
   set the text of button "Provider" to xtaProviderNames()
   set the tooltip of button "Provider" to "The provider of the AI model"

   create button "Model"
   set the style of button "Model" to "menu"
   set the menuMode of button "Model" to "comboBox"
   set the tooltip of button "Model" to "The model: type its name, or press Models to choose from the provider's list"

   create button "Models"
   set the label of button "Models" to "Models"
   set the tooltip of button "Models" to "Ask the provider which models it has"

   create button "More"
   set the style of button "More" to "menu"
   set the menuMode of button "More" to "pulldown"
   set the label of button "More" to "More"
   set the text of button "More" to "Set API Key..." & return & "Forget API Key" & return & \
         "Base URL..." & return & "-" & return & "Turn Off xTalk Assistant"

   create field "Conversation"
   set the lockText of field "Conversation" to true
   set the traversalOn of field "Conversation" to true
   set the dontWrap of field "Conversation" to false
   set the vScrollbar of field "Conversation" to true
   set the threeD of field "Conversation" to false
   set the margins of field "Conversation" to 6

   create button "Include"
   set the style of button "Include" to "checkbox"
   set the label of button "Include" to "Include the open script"
   set the tooltip of button "Include" to "Send the script open in the Script Editor with your question"

   create button "Insert"
   set the label of button "Insert" to "Insert Code"
   set the tooltip of button "Insert" to "Insert the code of the last answer at the caret in the Script Editor (Undo takes it out again)"

   create button "New"
   set the label of button "New" to "New Chat"
   set the tooltip of button "New" to "Start a new conversation"

   create field "Prompt"
   set the dontWrap of field "Prompt" to false
   set the vScrollbar of field "Prompt" to true
   set the threeD of field "Prompt" to false
   set the margins of field "Prompt" to 4
   set the tooltip of field "Prompt" to "Your question. Enter, or Command-Return (Control-Return), sends it."

   create button "Send"
   set the label of button "Send" to "Send"
   set the default of button "Send" to false

   create field "Status"
   set the lockText of field "Status" to true
   set the traversalOn of field "Status" to false
   set the opaque of field "Status" to false
   set the showBorder of field "Status" to false
   set the dontWrap of field "Status" to true
   set the margins of field "Status" to 0
   set the textSize of field "Status" to 11

   put revIDEGetPreference("cScriptEditor,editor,font") into tFont
   if tFont is not empty then
      set the textFont of field "Prompt" to tFont
   end if

   set the behavior of stack kWindow to the long id of stack kWindowBehavior
   unlock messages
   set the defaultStack to tOldDefault
   unlock screen
end xtaBuildWindow

private function xtaProviderNames
   local tList, tProvider
   repeat for each item tProvider in xtaProviders()
      put xtaProviderName(tProvider) & return after tList
   end repeat
   delete the last char of tList
   return tList
end xtaProviderNames

-- Shows the settings and the conversation as they are now.
private command xtaRefreshWindow
   local tProvider
   if there is not a stack kWindow then
      exit xtaRefreshWindow
   end if
   put xtaProvider() into tProvider
   lock screen
   lock messages
   set the label of button "Provider" of stack kWindow to xtaProviderName(tProvider)
   set the label of button "Model" of stack kWindow to xtaModel(tProvider)
   set the hilite of button "Include" of stack kWindow to (revIDEGetPreference(kPrefIncludeScript) is not false)
   unlock messages
   xtaShowConversation
   xtaUpdateButtons
   if sBusy is not true then
      xtaStatus xtaSettingsLine()
   end if
   unlock screen
end xtaRefreshWindow

private command xtaUpdateButtons
   if there is not a stack kWindow then
      exit xtaUpdateButtons
   end if
   set the enabled of button "Send" of stack kWindow to (sBusy is not true)
   set the enabled of button "Models" of stack kWindow to (sBusy is not true)
   set the enabled of button "Insert" of stack kWindow to (sBusy is not true and the number of elements of sLastCode > 0)
end xtaUpdateButtons

private command xtaStatus pText
   if there is a stack kWindow then
      set the text of field "Status" of stack kWindow to pText
   end if
end xtaStatus

private function xtaSettingsLine
   local tProvider, tLine
   put xtaProvider() into tProvider
   put xtaProviderName(tProvider) into tLine
   if xtaKey(tProvider) is empty then
      put " - no API key yet (More > Set API Key...)" after tLine
   else if sKeys[tProvider] is empty then
      put " - API key from the environment" after tLine
   end if
   if xtaModel(tProvider) is empty then
      put " - choose a model" after tLine
   end if
   return tLine
end xtaSettingsLine

-- The conversation, as the window shows it: who said it, in bold, then
-- what they said, the lines of code in the Script Editor's font.
private command xtaShowConversation
   local tText, tIndex, tLine, tInCode, tFont, tLineNumber, tLabelLines
   if there is not a stack kWindow then
      exit xtaShowConversation
   end if
   -- The line numbers of the "You" and "xTalk Assistant" lines, so that a
   -- line of an answer that reads the same is not taken for one
   put 1 into tLineNumber
   repeat with tIndex = 1 to the number of elements of sTurns
      put tLineNumber & comma after tLabelLines
      if sTurns[tIndex]["role"] is "assistant" then
         put "xTalk Assistant" & return & sTurns[tIndex]["text"] after tText
      else
         put "You" & return & sTurns[tIndex]["text"] after tText
         if sTurns[tIndex]["context"] is not empty then
            put return & "(with the script of" && sTurns[tIndex]["contextName"] & ")" after tText
         end if
      end if
      put return & return after tText
      put the number of lines of tText + 1 into tLineNumber
   end repeat
   lock screen
   set the text of field "Conversation" of stack kWindow to tText
   put revIDEGetPreference("cScriptEditor,editor,font") into tFont
   put false into tInCode
   put 0 into tLineNumber
   repeat for each line tLine in tText
      add 1 to tLineNumber
      if tLineNumber is among the items of tLabelLines then
         set the textStyle of line tLineNumber of field "Conversation" of stack kWindow to "bold"
         put false into tInCode
         next repeat
      end if
      if word 1 to -1 of tLine begins with "```" then
         put not tInCode into tInCode
         next repeat
      end if
      if tInCode and tFont is not empty then
         set the textFont of line tLineNumber of field "Conversation" of stack kWindow to tFont
      end if
   end repeat
   set the vScroll of field "Conversation" of stack kWindow to the formattedHeight of field "Conversation" of stack kWindow
   unlock screen
end xtaShowConversation

--------------------------------------------------------------------------------
-- Settings

private function xtaProvider
   local tProvider
   put revIDEGetPreference(kPrefProvider) into tProvider
   if tProvider is not among the items of xtaProviders() then
      put "anthropic" into tProvider
   end if
   return tProvider
end xtaProvider

private function xtaModel pProvider
   return revIDEGetPreference(kPrefModel & pProvider)
end xtaModel

private function xtaBaseUrl pProvider
   return revIDEGetPreference(kPrefBaseUrl & pProvider)
end xtaBaseUrl

-- The key the user typed, or else the one in the environment
private function xtaKey pProvider
   if sKeys[pProvider] is not empty then
      return sKeys[pProvider]
   end if
   switch pProvider
      case "anthropic"
         return $ANTHROPIC_API_KEY
      case "openai"
         return $OPENAI_API_KEY
   end switch
   return empty
end xtaKey

-- The settings xtaAsk and xtaListModels take
private function xtaSettings
   local tSettings, tProvider
   put xtaProvider() into tProvider
   put tProvider into tSettings["provider"]
   put xtaBaseUrl(tProvider) into tSettings["baseUrl"]
   put xtaKey(tProvider) into tSettings["key"]
   put xtaModel(tProvider) into tSettings["model"]
   return tSettings
end xtaSettings

on xtaSetProviderByName pName
   local tProvider
   repeat for each item tProvider in xtaProviders()
      if xtaProviderName(tProvider) is pName then
         revIDESetPreference kPrefProvider, tProvider
      end if
   end repeat
   xtaRefreshWindow
end xtaSetProviderByName

on xtaSetModel pModel
   put word 1 to -1 of pModel into pModel
   if pModel is not xtaModel(xtaProvider()) then
      revIDESetPreference kPrefModel & xtaProvider(), pModel
   end if
   xtaStatus xtaSettingsLine()
end xtaSetModel

on xtaSetIncludeScript pInclude
   revIDESetPreference kPrefIncludeScript, (pInclude is true)
end xtaSetIncludeScript

on xtaMoreMenuPick pItem
   switch pItem
      case "Set API Key..."
         get xtaAskForKey()
         break
      case "Forget API Key"
         put empty into sKeys[xtaProvider()]
         xtaStatus xtaSettingsLine()
         break
      case "Base URL..."
         xtaAskForBaseUrl
         break
      case "Turn Off xTalk Assistant"
         xtaTurnOff
         break
   end switch
end xtaMoreMenuPick

-- Asks for the key of the current provider. Returns false when the user
-- cancelled.
private function xtaAskForKey
   local tProvider
   put xtaProvider() into tProvider
   ask password clear "Your" && xtaProviderName(tProvider) && "API key:" & return & \
         "(It is kept in memory until you quit OXT-Beyond, and never saved.)" titled kTitle
   if the result is "cancel" or word 1 to -1 of it is empty then
      return false
   end if
   put word 1 to -1 of it into sKeys[tProvider]
   xtaStatus xtaSettingsLine()
   return true
end xtaAskForKey

private command xtaAskForBaseUrl
   local tProvider, tUrl
   put xtaProvider() into tProvider
   put xtaBaseUrl(tProvider) into tUrl
   if tUrl is empty then
      put xtaDefaultBaseUrl(tProvider) into tUrl
   end if
   ask "The base URL of the" && xtaProviderName(tProvider) && "API. For a local server with OpenAI's API, for example http://localhost:11434/v1 (Ollama). Empty means" && xtaDefaultBaseUrl(tProvider) & "." \
         with tUrl titled kTitle
   if the result is "cancel" then
      exit xtaAskForBaseUrl
   end if
   put word 1 to -1 of it into tUrl
   if tUrl is xtaDefaultBaseUrl(tProvider) then
      put empty into tUrl
   end if
   if tUrl is not empty and not (tUrl begins with "https://" or tUrl begins with "http://") then
      answer warning "A base URL begins with https:// (or http:// for a server on this computer)." titled kTitle
      exit xtaAskForBaseUrl
   end if
   revIDESetPreference kPrefBaseUrl & tProvider, tUrl
end xtaAskForBaseUrl

-- Asks the provider for its models and lets the user pick one from the
-- combo box.
on xtaChooseModels
   local tProvider, tResult, tShutDowns
   if sBusy is true then
      exit xtaChooseModels
   end if
   put xtaProvider() into tProvider
   if not xtaEnsureKey(tProvider) then
      exit xtaChooseModels
   end if
   put true into sBusy
   xtaUpdateButtons
   xtaStatus "Asking" && xtaProviderName(tProvider) && "for its models..."
   put sShutDowns into tShutDowns
   put xtaListModels(xtaSettings()) into tResult
   if sShutDowns is not tShutDowns then
      exit xtaChooseModels
   end if
   put false into sBusy
   if there is not a stack kWindow then
      exit xtaChooseModels
   end if
   xtaUpdateButtons
   if tResult["error"] is not empty then
      xtaStatus xtaSettingsLine()
      answer warning tResult["error"] titled kTitle
      exit xtaChooseModels
   end if
   sort lines of tResult["models"]
   lock messages
   set the text of button "Model" of stack kWindow to tResult["models"]
   set the label of button "Model" of stack kWindow to xtaModel(tProvider)
   unlock messages
   xtaStatus "The provider has" && the number of lines of tResult["models"] && \
         "models: pick one from the model menu."
end xtaChooseModels

-- True when there is a key for the provider, asking the user for one if
-- needed. A base URL of the user's own (a local server) may need none.
private function xtaEnsureKey pProvider
   if xtaKey(pProvider) is not empty then
      return true
   end if
   if xtaBaseUrl(pProvider) is not empty then
      return true
   end if
   return xtaAskForKey()
end xtaEnsureKey

--------------------------------------------------------------------------------
-- Asking

on xtaNewConversation
   if sBusy is true then
      exit xtaNewConversation
   end if
   put empty into sTurns
   put empty into sLastCode
   xtaRefreshWindow
end xtaNewConversation

on xtaSendPrompt
   local tPrompt, tProvider, tCount, tContext, tReply, tStatus, tShutDowns
   if sBusy is true or there is not a stack kWindow then
      exit xtaSendPrompt
   end if
   put field "Prompt" of stack kWindow into tPrompt
   if word 1 to -1 of tPrompt is empty then
      exit xtaSendPrompt
   end if
   -- A model name typed into the combo box counts even if it was not
   -- confirmed
   xtaSetModel the label of button "Model" of stack kWindow
   put xtaProvider() into tProvider
   if xtaModel(tProvider) is empty then
      answer information "Choose a model first: type its name, or press Models to choose from the provider's list." titled kTitle
      exit xtaSendPrompt
   end if
   if not xtaEnsureKey(tProvider) then
      exit xtaSendPrompt
   end if

   put the number of elements of sTurns + 1 into tCount
   put "user" into sTurns[tCount]["role"]
   put tPrompt into sTurns[tCount]["text"]
   if the hilite of button "Include" of stack kWindow then
      put xtaScriptContext() into tContext
      if tContext["script"] is not empty then
         put tContext["script"] into sTurns[tCount]["context"]
         put tContext["name"] into sTurns[tCount]["contextName"]
      end if
   end if
   put empty into field "Prompt" of stack kWindow
   put true into sBusy
   xtaShowConversation
   xtaUpdateButtons
   xtaStatus "Waiting for" && xtaProviderName(tProvider) & "..."

   put sShutDowns into tShutDowns
   put xtaAsk(xtaSettings(), xtaSystemPrompt(), xtaTurnsToSend()) into tReply
   if sShutDowns is not tShutDowns then
      exit xtaSendPrompt
   end if

   put false into sBusy
   if tReply["ok"] is true then
      put "assistant" into sTurns[tCount + 1]["role"]
      put tReply["text"] into sTurns[tCount + 1]["text"]
      put xtaCodeBlocks(tReply["text"]) into sLastCode
      put xtaProviderName(tProvider) && "-" && xtaModel(tProvider) into tStatus
      if tReply["inputTokens"] is not empty then
         put " -" && tReply["inputTokens"] && "tokens in," && tReply["outputTokens"] && "out" after tStatus
      end if
      if tReply["stop"] is "max_tokens" or tReply["stop"] is "length" then
         put " - the answer was cut off at its length limit" after tStatus
      end if
   else
      -- The question stays in the prompt, to send again
      delete variable sTurns[tCount]
      if there is a stack kWindow then
         put tPrompt into field "Prompt" of stack kWindow
      end if
      put xtaSettingsLine() into tStatus
   end if
   if there is not a stack kWindow then
      exit xtaSendPrompt
   end if
   xtaShowConversation
   xtaUpdateButtons
   xtaStatus tStatus
   if tReply["ok"] is not true then
      if line 1 of tReply["error"] contains "API key" then
         put empty into sKeys[tProvider]
      end if
      answer warning tReply["error"] titled kTitle
   end if
end xtaSendPrompt

-- The conversation as it is sent: the open script goes with the latest
-- question that had one, so that it is sent once rather than with every
-- question.
private function xtaTurnsToSend
   local tTurns, tIndex, tLast
   put 0 into tLast
   repeat with tIndex = 1 to the number of elements of sTurns
      if sTurns[tIndex]["context"] is not empty then
         put tIndex into tLast
      end if
   end repeat
   repeat with tIndex = 1 to the number of elements of sTurns
      put sTurns[tIndex]["role"] into tTurns[tIndex]["role"]
      put sTurns[tIndex]["text"] into tTurns[tIndex]["text"]
      if tIndex is tLast then
         put return & return & "The script I am editing, of" && sTurns[tIndex]["contextName"] & ":" & return & \
               "```livecodescript" & return & sTurns[tIndex]["context"] & return & "```" after tTurns[tIndex]["text"]
      end if
   end repeat
   return tTurns
end xtaTurnsToSend

--------------------------------------------------------------------------------
-- The Script Editor

private function xtaTopScriptEditor
   local tEditor
   try
      put revTopMostScriptEditor() into tEditor
   catch tError
      put empty into tEditor
   end try
   if tEditor is not empty and there is not a tEditor then
      put empty into tEditor
   end if
   return tEditor
end xtaTopScriptEditor

-- The script open in the topmost Script Editor, as it is being edited
-- (applied or not): "script", and "name", the object it belongs to, named
-- without the path of its stack file.
private function xtaScriptContext
   local tEditor, tObject, tContext, tScript, tStack, tPassword
   put xtaTopScriptEditor() into tEditor
   if tEditor is empty then
      return tContext
   end if
   try
      dispatch "revSEGetCurrentObject" to tEditor
      put the result into tObject
      dispatch function "revSEGetScript" to tEditor
      put the result into tScript
   catch tError
      return tContext
   end try
   if tObject is empty or there is not a tObject then
      return tContext
   end if
   -- A password-protected stack's scripts are not sent (the test the
   -- IDE's documentation builder makes, revidelibrary.8.livecodescript)
   put revIDEStackOfObject(tObject) into tStack
   put "protected" into tPassword
   try
      put the password of tStack into tPassword
   catch tError
   end try
   if tPassword is not empty then
      return tContext
   end if
   if the number of chars of tScript > kMaxScriptChars then
      put char 1 to kMaxScriptChars of tScript & return & "-- (the rest of the script was left out)" into tScript
   end if
   put tScript into tContext["script"]
   if word 1 of the name of tObject is "stack" then
      put the name of tObject into tContext["name"]
   else
      put the name of tObject && "of stack" && quote & the short name of tStack & quote into tContext["name"]
   end if
   return tContext
end xtaScriptContext

on xtaInsertCode
   local tCode, tIndex, tEditor
   if the number of elements of sLastCode is 0 then
      exit xtaInsertCode
   end if
   if the number of elements of sLastCode is 1 then
      put sLastCode[1]["code"] into tCode
   else
      answer question "The answer has" && the number of elements of sLastCode && "pieces of code. Insert which?" \
            with "Cancel" or "Last" or "First" or "All" titled kTitle
      switch it
         case "All"
            repeat with tIndex = 1 to the number of elements of sLastCode
               if tCode is not empty then
                  put return & return after tCode
               end if
               put sLastCode[tIndex]["code"] after tCode
            end repeat
            break
         case "First"
            put sLastCode[1]["code"] into tCode
            break
         case "Last"
            put sLastCode[the number of elements of sLastCode]["code"] into tCode
            break
         default
            exit xtaInsertCode
      end switch
   end if
   put xtaTopScriptEditor() into tEditor
   if tEditor is empty then
      set the clipboardData["text"] to tCode
      answer information "Open a script in the Script Editor first. The code is on the clipboard meanwhile." titled kTitle
      exit xtaInsertCode
   end if
   dispatch "revSEInsertText" to tEditor with tCode
   if it is not "handled" then
      set the clipboardData["text"] to tCode
      answer information "This Script Editor cannot take the code; it is on the clipboard to paste." titled kTitle
      exit xtaInsertCode
   end if
   xtaStatus "Inserted. Apply the script to keep it, or Undo to take it out."
end xtaInsertCode
