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
-- What it does: a window to talk to the model the user picks, from
-- Anthropic or OpenAI (or any service or local server with OpenAI's API),
-- with the script open in the Script Editor attached when the user wants,
-- and a button that inserts the xTalk code of the answer at the caret in
-- the Script Editor as one undoable step. The model is given the guide
-- (xtalk-guide.md, in this folder) and the notes the user keeps for it (its
-- memory, a file in the preferences folder). Every xTalk block of an answer
-- is compiled before the user reads it, and one that does not compile goes
-- back to the model with the errors, a few rounds at most (the "fix
-- rounds"). It never runs code, and never changes a script or an object by
-- itself.
--
-- The key: what the user types is kept in memory until the IDE quits or the
-- user forgets it, and is never written to the preferences, a stack or a
-- log. Without one, ANTHROPIC_API_KEY or OPENAI_API_KEY from the
-- environment is used when it is set. The provider, model and base URL are
-- preferences.
--
-- Files: this stack (the plugin's lifecycle, its settings and the IDE
-- glue), xtalkassistant-core.livecodescript (JSON, the providers, HTTP,
-- the compile checks and the memory; tested by tests/lcs/xtalkassistant),
-- xtalkassistant-window.livecodescript (the window's behavior) and
-- xtalk-guide.md (the guide).
--
-- Public handlers (all reached with dispatch, from the menu bar and the
-- window):
--    xtalkAssistantMenuPick       Development > Plugins > xTalk Assistant
--    xtaSendPrompt, xtaSendOrStop, xtaInsertCode, xtaNewConversation,
--    xtaChooseModels, xtaSetIncludeScript, xtaSetProviderByName, xtaSetModel,
--    xtaMoreMenuPick, xtaNoteClicked, xtaWindowClosed
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
constant kPrefFixRounds = "cXTalkAssistant,fixRounds"
constant kPrefShortGuide = "cXTalkAssistant,shortGuide"
-- The most of the open script that is sent with a question, in characters
constant kMaxScriptChars = 60000
-- How many times, by default and at most, code that does not compile goes
-- back to the model for each question
constant kDefaultFixRounds = 5
constant kMaxFixRounds = 10
constant kGuideFile = "xtalk-guide.md"
-- The memory's file, in the user's preferences folder
constant kMemoryFile = "xTalk Assistant Memory.txt"
constant kMemoryWindow = "revXTalkAssistantMemory"

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
-- The xTalk blocks of the latest answer that had any (as xtaXTalkBlocks
-- returns them)
local sLastCode
-- The guide, read once from its file
local sGuide
-- True when the user pressed Stop while a question was being answered
local sStopAsked

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
      -- key, as Send and Models do. Then the provider's models, which tells
      -- the user at once whether the key works, and chooses a model when
      -- none is chosen yet: in 0.2.5-rc.3 the key was taken and nothing
      -- else happened until the user found the Models button.
      if xtaEnsureKey(xtaProvider()) then
         xtaChooseModels
      end if
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

-- Forgets everything and unloads what the assistant loaded. The memory's
-- file stays, for the next time it is turned on.
private command xtaShutDown
   add 1 to sShutDowns
   put false into sBusy
   put false into sStopAsked
   put empty into sKeys
   put empty into sTurns
   put empty into sLastCode
   put empty into sGuide
   if there is a stack kMemoryWindow then
      delete stack kMemoryWindow
   end if
   if there is a stack kWindow then
      close stack kWindow
   end if
   if there is a stack kWindow then
      delete stack kWindow
   end if
   if there is a stack kCore and the long id of stack kCore is among the lines of xtaStacksInUse() then
      xtaCheckCleanup
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
   put xtaPluginFolder() into tFolder
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
   set the text of button "More" to xtaMoreMenuText()

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
   set the text of button "More" of stack kWindow to xtaMoreMenuText()
   unlock messages
   xtaShowConversation
   xtaUpdateButtons
   if sBusy is not true then
      xtaStatus xtaSettingsLine()
   end if
   unlock screen
end xtaRefreshWindow

-- While a question is being answered, Send is Stop, which ends the rounds
-- of corrections after the answer that is on its way.
private command xtaUpdateButtons
   if there is not a stack kWindow then
      exit xtaUpdateButtons
   end if
   if sBusy is true then
      set the label of button "Send" of stack kWindow to "Stop"
      set the tooltip of button "Send" of stack kWindow to "Stop after the answer that is on its way"
      set the enabled of button "Send" of stack kWindow to (sStopAsked is not true)
   else
      set the label of button "Send" of stack kWindow to "Send"
      set the tooltip of button "Send" of stack kWindow to empty
      set the enabled of button "Send" of stack kWindow to true
   end if
   set the enabled of button "Models" of stack kWindow to (sBusy is not true)
   set the enabled of button "Insert" of stack kWindow to (sBusy is not true and the number of elements of sLastCode > 0)
end xtaUpdateButtons

-- The items of the More menu; the short guide's is ticked while it is used
private function xtaMoreMenuText
   local tShort
   if revIDEGetPreference(kPrefShortGuide) is true then
      put "!c" into tShort
   else
      put "!n" into tShort
   end if
   return "Set API Key..." & return & "Forget API Key" & return & "Base URL..." & return & "-" & return & \
         "Memory..." & return & "Fix Rounds..." & return & tShort & "Short Guide (for small local models)" & return & "-" & return & \
         "Turn Off xTalk Assistant"
end xtaMoreMenuText

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
      put " - no model yet (Send chooses one)" after tLine
   end if
   return tLine
end xtaSettingsLine

-- The conversation, as the window shows it: who said it, in bold, then
-- what they said, the lines of code in the Script Editor's font. After an
-- answer, in italics, what the compile check found, and each note the
-- answer proposes to remember, with Remember and Dismiss as links (the
-- answer's memory block itself is not shown). A compile check sent back
-- to the model shows as a turn of its own.
private command xtaShowConversation
   local tText, tIndex, tLine, tInCode, tFont, tLineNumber, tLabelLines, tItalicLines
   local tLinks, tLink, tNote, tCount, tWords, tBody
   if there is not a stack kWindow then
      exit xtaShowConversation
   end if
   -- The line numbers of the labels and of the italic lines, so that a line
   -- of an answer that reads the same is not taken for one; and for each
   -- note's line, its links ("line,turn,note")
   put 0 into tCount
   repeat with tIndex = 1 to the number of elements of sTurns
      put tCount + 1 & comma after tLabelLines
      if sTurns[tIndex]["kind"] is "check" then
         put sTurns[tIndex]["text"] into tBody
         if tBody begins with "Compile check: " then
            delete char 1 to the number of chars of "Compile check: " of tBody
         end if
         xtaAddLines tText, tCount, "Compile check" & return & tBody
      else if sTurns[tIndex]["role"] is "assistant" then
         xtaAddLines tText, tCount, "xTalk Assistant" & return & xtaWithoutMemoryBlocks(sTurns[tIndex]["text"])
         if sTurns[tIndex]["check"] is not empty then
            put tCount + 1 & comma after tItalicLines
            xtaAddLines tText, tCount, sTurns[tIndex]["check"]
         end if
         repeat with tNote = 1 to the number of elements of sTurns[tIndex]["notes"]
            switch sTurns[tIndex]["notes"][tNote]["state"]
               case "dismissed"
                  break
               case "kept"
                  put tCount + 1 & comma after tItalicLines
                  xtaAddLines tText, tCount, "Remembered" && xtaNoteScope(tIndex, tNote) & ":" && sTurns[tIndex]["notes"][tNote]["note"]
                  break
               default
                  put tCount + 1 & comma after tItalicLines
                  put tCount + 1 & comma & tIndex & comma & tNote & return after tLinks
                  xtaAddLines tText, tCount, "Note to keep" && xtaNoteScope(tIndex, tNote) & ":" && \
                        sTurns[tIndex]["notes"][tNote]["note"] & "    Remember  Dismiss"
                  break
            end switch
         end repeat
      else
         put sTurns[tIndex]["text"] into tBody
         if sTurns[tIndex]["context"] is not empty then
            put return & "(with the script of" && sTurns[tIndex]["contextName"] & ")" after tBody
         end if
         xtaAddLines tText, tCount, "You" & return & tBody
      end if
      xtaAddLines tText, tCount, empty
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
      if tLineNumber is among the items of tItalicLines then
         set the textStyle of line tLineNumber of field "Conversation" of stack kWindow to "italic"
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
   -- The last two words of a note's line are its links
   repeat for each line tLink in tLinks
      put item 1 of tLink into tLineNumber
      put the number of words of line tLineNumber of field "Conversation" of stack kWindow into tWords
      set the textStyle of word tWords - 1 of line tLineNumber of field "Conversation" of stack kWindow to "link"
      set the linkText of word tWords - 1 of line tLineNumber of field "Conversation" of stack kWindow to "remember," & item 2 to 3 of tLink
      set the textStyle of word tWords of line tLineNumber of field "Conversation" of stack kWindow to "link"
      set the linkText of word tWords of line tLineNumber of field "Conversation" of stack kWindow to "dismiss," & item 2 to 3 of tLink
   end repeat
   set the vScroll of field "Conversation" of stack kWindow to the formattedHeight of field "Conversation" of stack kWindow
   unlock screen
end xtaShowConversation

-- Adds pLines (one or more lines) to xText as lines of their own, and
-- counts them in xCount, the number of lines xText has so far
private command xtaAddLines @xText, @xCount, pLines
   local tWithout
   put pLines & return after xText
   put pLines into tWithout
   replace return with empty in tWithout
   add the number of chars of pLines - the number of chars of tWithout + 1 to xCount
end xtaAddLines

-- Whom a proposed note is about, as the window says it
private function xtaNoteScope pTurn, pNote
   if sTurns[pTurn]["notes"][pNote]["scope"] is "stack" then
      if sTurns[pTurn]["stackName"] is not empty then
         return "about the stack" && quote & sTurns[pTurn]["stackName"] & quote
      end if
      return "about this stack"
   end if
   return "about you"
end xtaNoteScope

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
      if xtaProviderName(tProvider) is pName and tProvider is not xtaProvider() then
         revIDESetPreference kPrefProvider, tProvider
         -- The model menu lists the other provider's models
         if there is a stack kWindow then
            lock messages
            set the text of button "Model" of stack kWindow to empty
            unlock messages
         end if
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
         -- The models tell the user at once whether the provider takes the key
         if xtaAskForKey() then
            xtaChooseModels
         end if
         break
      case "Forget API Key"
         put empty into sKeys[xtaProvider()]
         xtaStatus xtaSettingsLine()
         break
      case "Base URL..."
         xtaAskForBaseUrl
         break
      case "Memory..."
         xtaEditMemory
         break
      case "Fix Rounds..."
         xtaAskForFixRounds
         break
      case "Short Guide (for small local models)"
         revIDESetPreference kPrefShortGuide, (revIDEGetPreference(kPrefShortGuide) is not true)
         xtaRefreshWindow
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
-- combo box (Models, and after a key is typed).
on xtaChooseModels
   local tProvider, tError
   if sBusy is true then
      exit xtaChooseModels
   end if
   put xtaProvider() into tProvider
   if not xtaEnsureKey(tProvider) then
      exit xtaChooseModels
   end if
   put xtaLoadModels() into tError
   if tError is not empty then
      exit xtaChooseModels
   end if
   xtaStatus xtaProviderName(tProvider) && "has" && the number of lines of the text of button "Model" of stack kWindow && \
         "models. Using" && xtaModel(tProvider) & ": choose another from the model menu."
end xtaChooseModels

-- Asks the provider for its models and puts them in the model menu. When no
-- model is chosen yet, it chooses the one the provider's list suggests
-- (xtaDefaultModel), so that the assistant works without the user knowing
-- a model's name. Returns empty; or why there are none, which the user has
-- been told; or "stopped" when the user pressed Stop meanwhile (the menu is
-- filled all the same); or "closed" when the window went away.
private function xtaLoadModels
   local tProvider, tResult, tShutDowns, tModels, tStopped
   put xtaProvider() into tProvider
   put true into sBusy
   put false into sStopAsked
   xtaUpdateButtons
   xtaStatus "Asking" && xtaProviderName(tProvider) && "for its models..."
   put sShutDowns into tShutDowns
   put xtaListModels(xtaSettings()) into tResult
   if sShutDowns is not tShutDowns then
      return "closed"
   end if
   put false into sBusy
   put (sStopAsked is true) into tStopped
   put false into sStopAsked
   if there is not a stack kWindow then
      return "closed"
   end if
   xtaUpdateButtons
   if tResult["error"] is not empty then
      -- As Send does: a key the provider refused is asked for again
      if line 1 of tResult["error"] contains "API key" then
         put empty into sKeys[tProvider]
      end if
      xtaStatus xtaSettingsLine()
      answer warning tResult["error"] titled kTitle
      return tResult["error"]
   end if
   if xtaModel(tProvider) is empty then
      revIDESetPreference kPrefModel & tProvider, tResult["default"]
   end if
   put tResult["models"] into tModels
   sort lines of tModels
   lock messages
   set the text of button "Model" of stack kWindow to tModels
   set the label of button "Model" of stack kWindow to xtaModel(tProvider)
   unlock messages
   if tStopped then
      xtaStatus xtaSettingsLine()
      return "stopped"
   end if
   return empty
end xtaLoadModels

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

private command xtaAskForFixRounds
   local tRounds
   ask "How many times may the assistant correct code that does not compile, for each question? From 0 (it checks the code, and sends nothing back) to" && kMaxFixRounds & "." \
         with xtaFixRounds() titled kTitle
   if the result is "cancel" then
      exit xtaAskForFixRounds
   end if
   put word 1 to -1 of it into tRounds
   if tRounds is an integer then
      if tRounds >= 0 and tRounds <= kMaxFixRounds then
         revIDESetPreference kPrefFixRounds, tRounds + 0
         exit xtaAskForFixRounds
      end if
   end if
   answer warning "Give a whole number from 0 to" && kMaxFixRounds & "." titled kTitle
end xtaAskForFixRounds

-- How many times code that does not compile goes back to the model
private function xtaFixRounds
   local tRounds
   put revIDEGetPreference(kPrefFixRounds) into tRounds
   if tRounds is an integer then
      if tRounds >= 0 and tRounds <= kMaxFixRounds then
         return tRounds
      end if
   end if
   return kDefaultFixRounds
end xtaFixRounds

-- The folder of the plugin's files
private function xtaPluginFolder
   set the itemDelimiter to slash
   return item 1 to -2 of the effective filename of me
end xtaPluginFolder

-- What the model is told first: the guide, the same in every request and
-- so marked for the provider's cache, then the notes the user keeps, about
-- themselves and about the stack pWork (as xtaWorkStack gives it). The
-- short guide is used when the user asks for it, or when the guide's file
-- cannot be read.
private function xtaSystem pWork
   local tSystem
   if revIDEGetPreference(kPrefShortGuide) is true then
      put xtaSystemPrompt() into tSystem[1]["text"]
   else
      if sGuide is empty then
         put xtaReadGuide(xtaPluginFolder() & slash & kGuideFile) into sGuide
      end if
      if sGuide is empty then
         put xtaSystemPrompt() into tSystem[1]["text"]
      else
         put sGuide into tSystem[1]["text"]
      end if
   end if
   put true into tSystem[1]["cache"]
   put xtaMemoryPrompt(xtaCurrentMemory(), pWork["path"], pWork["name"]) into tSystem[2]["text"]
   put false into tSystem[2]["cache"]
   return tSystem
end xtaSystem

-- The stack the user is working on: that of the script open in the Script
-- Editor, or else the topmost stack that is not one of the IDE's. An array
-- with "path" (its main stack's file) and "name" (its main stack's name),
-- both empty when there is none, or it was never saved.
private function xtaWorkStack
   local tEditor, tObject, tStack, tWork, tPath
   put xtaTopScriptEditor() into tEditor
   if tEditor is not empty then
      try
         dispatch "revSEGetCurrentObject" to tEditor
         put the result into tObject
      catch tError
         put empty into tObject
      end try
   end if
   if tObject is not empty and there is a tObject then
      put revIDEStackOfObject(tObject) into tStack
   else
      put the topStack into tStack
   end if
   if tStack is empty or there is not a tStack then
      return tWork
   end if
   if the short name of tStack begins with "rev" or the _ideoverride of tStack is true then
      return tWork
   end if
   put the effective filename of tStack into tPath
   if tPath is empty then
      return tWork
   end if
   put tPath into tWork["path"]
   put the mainStack of tStack into tWork["name"]
   return tWork
end xtaWorkStack

--------------------------------------------------------------------------------
-- Memory

-- The memory's file, in the user's preferences folder, or empty when the
-- IDE does not say where that is
private function xtaMemoryPath
   local tFolder
   try
      put revEnvironmentUserPreferencesPath() into tFolder
   catch tError
      put empty into tFolder
   end try
   if tFolder is empty then
      return empty
   end if
   return tFolder & slash & kMemoryFile
end xtaMemoryPath

-- The memory as its file has it now (the user may have edited the file)
private function xtaCurrentMemory
   return xtaMemoryLoad(xtaMemoryPath())
end xtaCurrentMemory

-- Writes the memory; the result is empty, or why it could not
private command xtaSaveMemory pMemory
   local tPath
   put xtaMemoryPath() into tPath
   if tPath is empty then
      return "The preferences folder is not known, so the notes cannot be kept."
   end if
   xtaMemorySave tPath, pMemory
   if the result is not empty then
      return "The notes could not be saved in" && tPath & ":" && the result
   end if
   return empty
end xtaSaveMemory

-- Remember or Dismiss, clicked under an answer: pLink is "remember" or
-- "dismiss", the turn and the note
on xtaNoteClicked pLink
   local tAction, tTurn, tIndex, tNote, tScope, tPath, tMemory, tProblem
   put item 1 of pLink into tAction
   put item 2 of pLink into tTurn
   put item 3 of pLink into tIndex
   if tTurn is not an integer or tIndex is not an integer then
      exit xtaNoteClicked
   end if
   put sTurns[tTurn]["notes"][tIndex]["note"] into tNote
   if tNote is empty or sTurns[tTurn]["notes"][tIndex]["state"] is not empty then
      exit xtaNoteClicked
   end if
   if tAction is "dismiss" then
      put "dismissed" into sTurns[tTurn]["notes"][tIndex]["state"]
      xtaShowConversation
      exit xtaNoteClicked
   end if
   if tAction is not "remember" then
      exit xtaNoteClicked
   end if
   put sTurns[tTurn]["notes"][tIndex]["scope"] into tScope
   put sTurns[tTurn]["stackPath"] into tPath
   if tScope is "stack" and tPath is empty then
      answer question "This note is about a stack, and the stack has never been saved, so there is no file to keep the note with. Keep it as a note about you?" \
            with "Cancel" or "Keep About Me" titled kTitle
      if it is not "Keep About Me" then
         exit xtaNoteClicked
      end if
      put "you" into tScope
      put tScope into sTurns[tTurn]["notes"][tIndex]["scope"]
   end if
   put xtaCurrentMemory() into tMemory
   xtaMemoryAdd tMemory, tScope, tPath, tNote
   put the result into tProblem
   if tProblem is empty then
      xtaSaveMemory tMemory
      put the result into tProblem
   end if
   if tProblem is not empty then
      answer warning tProblem titled kTitle
      exit xtaNoteClicked
   end if
   put "kept" into sTurns[tTurn]["notes"][tIndex]["state"]
   xtaShowConversation
end xtaNoteClicked

-- More > Memory...: the notes about the user and about the stack they are
-- working on, to read and edit, and Forget All
private command xtaEditMemory
   local tWork, tMemory, tYou, tStackNotes, tChoice, tProblem
   put xtaWorkStack() into tWork
   put xtaCurrentMemory() into tMemory
   put xtaMemoryNotes(tMemory, "you", empty) into tYou
   put xtaMemoryNotes(tMemory, "stack", tWork["path"]) into tStackNotes
   repeat forever
      put xtaMemoryDialog(tWork, tYou, tStackNotes) into tChoice
      if tChoice["choice"] is "save" then
         put tChoice["you"] into tYou
         put tChoice["stack"] into tStackNotes
         xtaMemorySetNotes tMemory, "you", empty, tYou
         put the result into tProblem
         if tProblem is empty and tWork["path"] is not empty then
            xtaMemorySetNotes tMemory, "stack", tWork["path"], tStackNotes
            put the result into tProblem
         end if
         if tProblem is empty then
            xtaSaveMemory tMemory
            put the result into tProblem
         end if
         if tProblem is empty then
            exit repeat
         end if
         answer warning tProblem titled kTitle
         -- What was refused is shown again, to correct; the memory is read
         -- again, so that nothing half-changed is kept
         put xtaCurrentMemory() into tMemory
      else if tChoice["choice"] is "forget" then
         answer question "Forget every note, about you and about every stack? This cannot be undone." \
               with "Cancel" or "Forget All" titled kTitle
         if it is "Forget All" then
            put empty into tMemory
            xtaSaveMemory tMemory
            put the result into tProblem
            if tProblem is not empty then
               answer warning tProblem titled kTitle
            end if
            exit repeat
         end if
         put tChoice["you"] into tYou
         put tChoice["stack"] into tStackNotes
      else
         exit repeat
      end if
   end repeat
end xtaEditMemory

-- Shows the memory's notes in a modal window, and returns what the user
-- chose ("choice": "save", "forget" or "cancel") and the notes as they
-- left them ("you", "stack"). The window is made here, like the
-- assistant's, and deleted when it closes.
private function xtaMemoryDialog pWork, pYou, pStackNotes
   local tOldDefault, tResult, tScript
   if there is a stack kMemoryWindow then
      delete stack kMemoryWindow
   end if
   put the defaultStack into tOldDefault
   lock screen
   lock messages
   create invisible stack kMemoryWindow
   set the defaultStack to kMemoryWindow
   set the title of stack kMemoryWindow to kTitle && "Memory"
   set the width of stack kMemoryWindow to 460
   set the height of stack kMemoryWindow to 440
   set the resizable of stack kMemoryWindow to false
   set the _ideoverride of stack kMemoryWindow to true

   create field "YouLabel"
   xtaMakeLabel the long id of field "YouLabel"
   put "About you, for every stack: one note per line. The notes go to the provider with every question." into field "YouLabel"
   set the rect of field "YouLabel" to 12, 8, 448, 44
   create field "You"
   xtaMakeNotesField the long id of field "You"
   set the rect of field "You" to 12, 48, 448, 176
   put pYou into field "You"

   create field "StackLabel"
   xtaMakeLabel the long id of field "StackLabel"
   set the rect of field "StackLabel" to 12, 188, 448, 224
   create field "Stack"
   xtaMakeNotesField the long id of field "Stack"
   set the rect of field "Stack" to 12, 228, 448, 356
   if pWork["path"] is empty then
      put "About a stack: open a saved stack, or save this one, to keep notes about it." into field "StackLabel"
      set the lockText of field "Stack" to true
      set the enabled of field "Stack" to false
   else
      put "About the stack" && quote & pWork["name"] & quote & ", kept with its file's path (never in the stack): one note per line." into field "StackLabel"
      put pStackNotes into field "Stack"
   end if

   put "on mouseUp" & return & "   set the cXtaChoice of stack " & quote & kMemoryWindow & quote & " to " & quote & "[[choice]]" & quote & return & \
         "   close stack " & quote & kMemoryWindow & quote & return & "end mouseUp" into tScript
   create button "Forget"
   set the label of button "Forget" to "Forget All..."
   set the rect of button "Forget" to 12, 396, 122, 420
   set the script of button "Forget" to replaceText(tScript, "\[\[choice\]\]", "forget")
   create button "Cancel"
   set the rect of button "Cancel" to 250, 396, 340, 420
   set the script of button "Cancel" to replaceText(tScript, "\[\[choice\]\]", "cancel")
   create button "Save"
   set the rect of button "Save" to 358, 396, 448, 420
   set the script of button "Save" to replaceText(tScript, "\[\[choice\]\]", "save")
   set the cXtaChoice of stack kMemoryWindow to "cancel"

   unlock messages
   set the defaultStack to tOldDefault
   set the loc of stack kMemoryWindow to the screenLoc
   -- Made invisible, so it is shown before it opens as a modal window (as
   -- the assistant's window must be)
   set the visible of stack kMemoryWindow to true
   unlock screen
   modal stack kMemoryWindow

   if there is not a stack kMemoryWindow then
      put "cancel" into tResult["choice"]
      return tResult
   end if
   put the cXtaChoice of stack kMemoryWindow into tResult["choice"]
   put field "You" of stack kMemoryWindow into tResult["you"]
   put field "Stack" of stack kMemoryWindow into tResult["stack"]
   lock messages
   delete stack kMemoryWindow
   unlock messages
   return tResult
end xtaMemoryDialog

private command xtaMakeLabel pField
   set the lockText of pField to true
   set the traversalOn of pField to false
   set the opaque of pField to false
   set the showBorder of pField to false
   set the dontWrap of pField to false
   -- Two lines of the IDE's text fit in the label's 36 pixels only without
   -- the default margins
   set the margins of pField to 0
end xtaMakeLabel

private command xtaMakeNotesField pField
   set the dontWrap of pField to false
   set the vScrollbar of pField to true
   set the threeD of pField to false
   set the margins of pField to 4
end xtaMakeNotesField

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

-- Send, or Stop while a question is being answered
on xtaSendOrStop
   if sBusy is true then
      put true into sStopAsked
      xtaUpdateButtons
      xtaStatus "Stopping after the answer that is on its way..."
      exit xtaSendOrStop
   end if
   xtaSendPrompt
end xtaSendOrStop

-- Sends the question in the prompt, with the conversation so far, and shows
-- the answer. Every xTalk block of an answer is compiled first; one that
-- does not compile goes back to the model with the errors, as a turn of
-- the conversation the user sees ("Compile check"), until the code
-- compiles, the fix rounds are used up, the model sends the same code
-- again or none, or the user presses Stop.
on xtaSendPrompt
   local tPrompt, tProvider, tCount, tContext, tReply, tStatus, tShutDowns
   local tWork, tSystem, tDeclared, tRound, tRounds, tBlocks, tCheck, tLastCode
   local tIn, tOut, tCached, tAnswered, tError
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
   if not xtaEnsureKey(tProvider) then
      exit xtaSendPrompt
   end if
   -- No model chosen yet: the provider's list names one (in 0.2.5-rc.3 Send
   -- only said to choose one first)
   if xtaModel(tProvider) is empty then
      if xtaLoadModels() is not empty then
         exit xtaSendPrompt
      end if
   end if

   put the number of elements of sTurns + 1 into tCount
   put "user" into sTurns[tCount]["role"]
   put tPrompt into sTurns[tCount]["text"]
   if the hilite of button "Include" of stack kWindow then
      put xtaScriptContext() into tContext
      if tContext["script"] is not empty then
         put tContext["script"] into sTurns[tCount]["context"]
         put tContext["name"] into sTurns[tCount]["contextName"]
         put xtaDeclaredNames(tContext["script"]) into tDeclared
      end if
   end if
   -- The stack the question is about, for the notes about it
   put xtaWorkStack() into tWork
   put tWork["path"] into sTurns[tCount]["stackPath"]
   put tWork["name"] into sTurns[tCount]["stackName"]
   put xtaSystem(tWork) into tSystem
   put empty into field "Prompt" of stack kWindow
   put true into sBusy
   put false into sStopAsked
   xtaShowConversation
   xtaUpdateButtons

   put xtaFixRounds() into tRounds
   put 0 into tRound
   put 0 into tIn
   put 0 into tOut
   put 0 into tCached
   put false into tAnswered
   put sShutDowns into tShutDowns
   repeat forever
      if tRound is 0 then
         xtaStatus "Waiting for" && xtaProviderName(tProvider) & "..."
      else
         xtaStatus "Waiting for" && xtaProviderName(tProvider) && "to correct the code (round" && tRound && "of" && tRounds & ")..."
      end if
      put xtaAsk(xtaSettings(), tSystem, xtaTurnsToSend()) into tReply
      if sShutDowns is not tShutDowns then
         exit xtaSendPrompt
      end if
      if tReply["ok"] is not true then
         exit repeat
      end if
      put true into tAnswered
      add tReply["inputTokens"] to tIn
      add tReply["outputTokens"] to tOut
      add tReply["cachedTokens"] to tCached
      put the number of elements of sTurns + 1 into tCount
      put "assistant" into sTurns[tCount]["role"]
      put tReply["text"] into sTurns[tCount]["text"]
      put xtaMemoryProposals(tReply["text"]) into sTurns[tCount]["notes"]
      put sTurns[tCount - 1]["stackPath"] into sTurns[tCount]["stackPath"]
      put sTurns[tCount - 1]["stackName"] into sTurns[tCount]["stackName"]
      -- Insert takes the code of the latest answer, or none when it has none
      put xtaXTalkBlocks(xtaCodeBlocks(tReply["text"])) into tBlocks
      put tBlocks into sLastCode
      if the number of elements of tBlocks is 0 then
         exit repeat
      end if
      xtaShowConversation
      xtaStatus "Checking the code..."
      put xtaCheckBlocks(tBlocks, tDeclared) into tCheck
      put tCheck["summary"] into sTurns[tCount]["check"]
      if tCheck["ok"] is true or tRound >= tRounds or sStopAsked is true or tCheck["code"] is tLastCode then
         exit repeat
      end if
      put tCheck["code"] into tLastCode
      add 1 to tRound
      put the number of elements of sTurns + 1 into tCount
      put "user" into sTurns[tCount]["role"]
      put "check" into sTurns[tCount]["kind"]
      put tCheck["report"] into sTurns[tCount]["text"]
      put sTurns[tCount - 1]["stackPath"] into sTurns[tCount]["stackPath"]
      put sTurns[tCount - 1]["stackName"] into sTurns[tCount]["stackName"]
      xtaShowConversation
   end repeat

   put false into sBusy
   put false into sStopAsked
   if tReply["ok"] is not true then
      put tReply["error"] into tError
      -- The turn that was not answered is taken back: the question stays in
      -- the prompt, to send again; a compile check is dropped, and the
      -- answer before it stays
      put the number of elements of sTurns into tCount
      delete variable sTurns[tCount]
      if not tAnswered and there is a stack kWindow then
         put tPrompt into field "Prompt" of stack kWindow
      end if
   end if
   if there is not a stack kWindow then
      exit xtaSendPrompt
   end if
   xtaShowConversation
   xtaUpdateButtons
   if tAnswered then
      put xtaProviderName(tProvider) && "-" && xtaModel(tProvider) into tStatus
      if tIn > 0 or tOut > 0 then
         put " -" && tIn && "tokens in," && tOut && "out" after tStatus
         if tCached > 0 then
            put " (" & tCached && "read from the cache)" after tStatus
         end if
      end if
      if tReply["stop"] is "max_tokens" or tReply["stop"] is "length" then
         put " - the answer was cut off at its length limit" after tStatus
      end if
      if tCheck["summary"] is not empty and tCheck["ok"] is not true then
         put " - the code does not compile" after tStatus
      end if
      xtaStatus tStatus
   else
      xtaStatus xtaSettingsLine()
   end if
   if tError is not empty then
      if line 1 of tError contains "API key" then
         put empty into sKeys[tProvider]
      end if
      answer warning tError titled kTitle
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
