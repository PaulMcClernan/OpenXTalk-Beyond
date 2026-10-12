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
-- rounds"). The model can ask for tools that read: the Dictionary, a
-- compile check, the user's stack (after the user allows it), the last
-- error the IDE showed the user, which a front script notes while the
-- assistant is on (xtalkassistant-errors.livecodescript), and where a
-- script paused in the debugger is. And it can ask for tools that build
-- and run (xtalkassistant-build.livecodescript): a batch of changes to the
-- user's stack (controls, cards, a new stack, properties, scripts), and
-- code to run in a sandbox or on the stack. Nothing changes and nothing
-- runs until the user says yes, in a bar the window shows: Apply for
-- changes, every time; Run for code, which the user can allow for the
-- session (code that reaches files, the network or other programs is
-- always asked about). Undo, next to what was applied in the
-- conversation, takes it back exactly, and a run on the stack goes back
-- to the checkpoint saved before it. The Settings switch "Let the model
-- change stacks and run code" takes those two tools away.
--
-- The key: what the user types or pastes in the Settings dialog is kept in
-- memory until the IDE quits or the user forgets it, and is never written
-- to the preferences, a stack or a log. Without one, ANTHROPIC_API_KEY or
-- OPENAI_API_KEY from the environment is used when it is set. Everything
-- else the dialog sets (the provider, model and base URL, the longest
-- answer, how long to wait, the fix rounds, the tools, the short guide,
-- whether the open script goes with a question) is a preference.
--
-- Files: this stack (the plugin's lifecycle, its settings, its windows
-- and the IDE glue), xtalkassistant-core.livecodescript (JSON, the
-- providers, HTTP, the compile checks, the memory and what the tools
-- read), xtalkassistant-build.livecodescript (what the tools that build
-- and run do, and Undo; both tested by tests/lcs/xtalkassistant),
-- xtalkassistant-window.livecodescript (the window's behavior),
-- xtalkassistant-settings.livecodescript (the Settings dialog's),
-- xtalkassistant-errors.livecodescript (the error hook) and
-- xtalk-guide.md (the guide).
--
-- The windows wear the xTalk Suite's look (its UI kit v2,
-- tools/ui-kit.livecodescript in the xtalk-suite repository): an accent
-- band with the title, one status line under it, white panels on a cool
-- page, flat entry fields in the platform's mono face, and a footer. The
-- kit's colors and builders are matched here by value (xtaUi...), not
-- carried, since this is not one of the suite's stacks.
--
-- Public handlers (all reached with dispatch, from the menu bar and the
-- window):
--    xtalkAssistantMenuPick       Development > Plugins > xTalk Assistant
--    xtaSendPrompt, xtaSendOrStop, xtaInsertCode, xtaNewConversation,
--    xtaChooseModels, xtaSetIncludeScript, xtaSetProviderByName, xtaSetModel,
--    xtaMoreMenuPick, xtaNoteClicked, xtaConversationLink, xtaAnswerAsk,
--    xtaWindowClosed,
--    xtaSettingsSave, xtaSettingsGetModels, xtaSettingsForgetKey,
--    xtaSettingsProvider             (the Settings dialog)
--    xtaSettingsPrepare, xtaSettingsDone()   (before and after it)
--    xtaIsEnabled()

constant kWindow = "revXTalkAssistant"
constant kTitle = "xTalk Assistant"
constant kCore = "org.openxtalk.plugin.xtalkassistant-core"
constant kBuild = "org.openxtalk.plugin.xtalkassistant-build"
constant kWindowBehavior = "org.openxtalk.plugin.xtalkassistant-window"
constant kErrorHook = "org.openxtalk.plugin.xtalkassistant-errors"
constant kSettingsWindow = "revXTalkAssistantSettings"
constant kSettingsBehavior = "org.openxtalk.plugin.xtalkassistant-settings"
-- Preferences (custom properties of the revPreferences stack)
constant kPrefEnabled = "cXTalkAssistant,enabled"
constant kPrefProvider = "cXTalkAssistant,provider"
constant kPrefModel = "cXTalkAssistant,model,"
constant kPrefBaseUrl = "cXTalkAssistant,baseUrl,"
constant kPrefIncludeScript = "cXTalkAssistant,includeScript"
constant kPrefFixRounds = "cXTalkAssistant,fixRounds"
constant kPrefShortGuide = "cXTalkAssistant,shortGuide"
constant kPrefTools = "cXTalkAssistant,tools"
constant kPrefMaxTokens = "cXTalkAssistant,maxTokens"
constant kPrefTimeout = "cXTalkAssistant,timeout"
constant kPrefBuild = "cXTalkAssistant,build"
-- The most of the open script that is sent with a question, in characters
constant kMaxScriptChars = 60000
-- How many times, by default and at most, code that does not compile goes
-- back to the model for each question
constant kDefaultFixRounds = 5
constant kMaxFixRounds = 10
-- How many tools the model may use for one question: building a stack,
-- trying it and correcting it takes more than reading did
constant kMaxToolCalls = 25
-- The limits of the Settings dialog's numbers: the longest answer, in
-- tokens (the provider refuses more than its model takes, and says so),
-- and how many seconds a request may go without data
constant kMaxMaxTokens = 1000000
-- What an empty wait means, as the core's kRequestTimeoutMilliseconds
constant kDefaultTimeout = 180
constant kMinTimeout = 10
constant kMaxTimeout = 3600
constant kGuideFile = "xtalk-guide.md"
-- The memory's file, in the user's preferences folder
constant kMemoryFile = "xTalk Assistant Memory.txt"
constant kMemoryWindow = "revXTalkAssistantMemory"
-- The tools that change or run something, which the Settings switch takes
-- away
constant kBuildTools = "make_changes,run_code"
-- How many of the changes of a batch the conversation lists under it
constant kShownChanges = 8

-- The xTalk Suite's UI kit v2, by value (its tools/ui-kit.livecodescript):
-- the page, the panels and their hairline, the accent band and its text,
-- the inks, the status colors, the entry fields' line, and the code's
-- ground and line
constant kUiBg = "240,242,246"
constant kUiCard = "255,255,255"
constant kUiCardLine = "225,229,236"
constant kUiAccent = "44,90,160"
constant kUiAccentText = "255,255,255"
constant kUiAccentSub = "199,216,241"
constant kUiInk = "28,34,46"
constant kUiInkSoft = "95,104,118"
constant kUiMuted = "138,146,158"
constant kUiOk = "23,128,63"
constant kUiWarn = "150,110,40"
constant kUiBad = "176,58,46"
constant kUiFieldLine = "203,210,222"
constant kUiCodeBg = "244,246,250"
constant kUiCodeLine = "210,217,229"
-- The kit's title band, and the windows' sizes (each fits 1200 x 640, a
-- 720p screen, as the kit asks)
constant kUiBand = 30
constant kWindowWidth = 560
constant kWindowHeight = 640
constant kSettingsWidth = 640
constant kMemoryWidth = 480

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
-- The stacks the user allowed the model to read (by the long id of the main
-- stack), until the assistant is turned off; and those they did not, for
-- the question being answered
local sReadAllowed, sReadRefused
-- The models of a server that refused tools ("provider,model"), which are
-- then asked without them until the assistant is turned off
local sNoTools
-- The model menu each provider's list gave, by provider, until the
-- assistant is turned off (empty: the suggested models are offered)
local sModelMenus
-- While the Settings dialog is open: what was typed for a provider before
-- the dialog was switched to another (by provider: "key", "baseUrl",
-- "model"), and whether Save was pressed
local sDrafts, sSettingsSaved, sSettingsProvider
-- After Save: true when the provider's models are to be asked for (a new
-- key, base URL or provider, or no model, and Get Models did not just)
local sSettingsFetch
-- True once the window has asked for a key this session, so that it asks
-- only once
local sKeyAsked
-- While the window's bar asks the user something: "kind" ("changes", "run"
-- or "read") and "answer" ("yes", "session", "no" or "stop"; empty until
-- one is given)
local sAsk
-- Where the user let code run without asking, until the assistant is
-- turned off: "sandbox", or the long id of a main stack
local sRunAllowed
-- What the user undid since the last question, a line each, to tell the
-- model with the next one
local sUndone

on extensionInitialize
   if the target is not me then
      pass extensionInitialize
   end if
   -- Part of the IDE, not of the user's work
   set the _ideoverride of me to true
   -- Turned on in an earlier session: the error hook notes the errors the
   -- user hits from the start, so that they can be explained
   if xtaIsEnabled() then
      try
         xtaStartErrorHook
      catch tError
      end try
   end if
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
      -- Just turned on: ask for the key now, in the Settings dialog, so the
      -- user sees where it goes (More > Settings... later). Not for a base
      -- URL of the user's own, which is kept when it is turned off and may
      -- need no key, as Send and Models do. Then the provider's models,
      -- which tells the user at once whether the key works, and chooses a
      -- model when none is chosen yet.
      put true into sKeyAsked
      if xtaEnsureKey(xtaProvider()) then
         xtaModelsIfNeeded true
      end if
      exit xtalkAssistantMenuPick
   end if
   xtaOpenWindow
   -- On from an earlier session: the key is asked for (once a session),
   -- and the models fetched when one was just typed or no model is chosen,
   -- as when it is turned on. In 0.2.5-rc.3 the window opened with an
   -- empty model menu and nothing more happened.
   if xtaKey(xtaProvider()) is empty and xtaBaseUrl(xtaProvider()) is empty then
      if sKeyAsked is true then
         exit xtalkAssistantMenuPick
      end if
      put true into sKeyAsked
      if xtaEnsureKey(xtaProvider()) then
         xtaModelsIfNeeded true
      end if
      exit xtalkAssistantMenuPick
   end if
   xtaModelsIfNeeded false
end xtalkAssistantMenuPick

-- The provider's models when no model is chosen yet, or (with
-- pIfNotListed) when its list has not come this session: after a key is
-- typed, they tell the user at once whether it works
private command xtaModelsIfNeeded pIfNotListed
   local tProvider
   put xtaProvider() into tProvider
   if xtaModel(tProvider) is empty or (pIfNotListed and sModelMenus[tProvider] is empty) then
      xtaChooseModels
   end if
end xtaModelsIfNeeded

private command xtaTurnOff
   local tQuestion
   put "Turn the xTalk Assistant off? Its window closes and the API keys you typed are forgotten. You can turn it on again from Development > Plugins." into tQuestion
   if xtaAppliedCount() > 0 then
      put return & return & "The changes it made to your stacks stay as they are, and can no longer be undone from the assistant." after tQuestion
   end if
   answer question tQuestion with "Cancel" or "Turn Off" titled kTitle
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
   put empty into sReadAllowed
   put empty into sReadRefused
   put empty into sNoTools
   put empty into sModelMenus
   put empty into sDrafts
   put empty into sKeyAsked
   put empty into sAsk
   put empty into sRunAllowed
   put empty into sUndone
   xtaStopErrorHook
   if there is a stack kMemoryWindow then
      delete stack kMemoryWindow
   end if
   if there is a stack kSettingsWindow then
      close stack kSettingsWindow
   end if
   if there is a stack kSettingsWindow then
      delete stack kSettingsWindow
   end if
   if there is a stack kWindow then
      close stack kWindow
   end if
   if there is a stack kWindow then
      delete stack kWindow
   end if
   -- The journal goes, with the hidden stacks and the checkpoints: what
   -- was applied stays
   if there is a stack kBuild and the long id of stack kBuild is among the lines of xtaStacksInUse() then
      xtaBuildCleanup
      stop using stack kBuild
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

-- Loads the core, the library that builds and runs, and the windows'
-- behaviors from this stack's folder.
private command xtaLoadParts
   local tFolder
   put xtaPluginFolder() into tFolder
   if there is not a stack kCore then
      get the short name of stack (tFolder & "/xtalkassistant-core.livecodescript")
   end if
   if the long id of stack kCore is not among the lines of xtaStacksInUse() then
      start using stack kCore
   end if
   if there is not a stack kBuild then
      get the short name of stack (tFolder & "/xtalkassistant-build.livecodescript")
   end if
   if the long id of stack kBuild is not among the lines of xtaStacksInUse() then
      start using stack kBuild
   end if
   set the _ideoverride of stack kBuild to true
   if there is not a stack kWindowBehavior then
      get the short name of stack (tFolder & "/xtalkassistant-window.livecodescript")
   end if
   if there is not a stack kSettingsBehavior then
      get the short name of stack (tFolder & "/xtalkassistant-settings.livecodescript")
   end if
   set the _ideoverride of stack kCore to true
   set the _ideoverride of stack kWindowBehavior to true
   set the _ideoverride of stack kSettingsBehavior to true
   xtaStartErrorHook
end xtaLoadParts

-- Puts the error hook in the front of the message path, where it notes
-- each error the IDE shows the user and passes it on
private command xtaStartErrorHook
   if there is not a stack kErrorHook then
      get the short name of stack (xtaPluginFolder() & "/xtalkassistant-errors.livecodescript")
      set the _ideoverride of stack kErrorHook to true
   end if
   if not (the long id of stack kErrorHook is among the lines of the frontScripts) then
      insert the script of stack kErrorHook into front
   end if
end xtaStartErrorHook

-- Takes the error hook out of the message path, and forgets the errors
private command xtaStopErrorHook
   if there is not a stack kErrorHook then
      exit xtaStopErrorHook
   end if
   if the long id of stack kErrorHook is among the lines of the frontScripts then
      remove the script of stack kErrorHook from front
   end if
   delete stack kErrorHook
end xtaStopErrorHook

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
   -- The conversation stays for the next time the window is opened; what
   -- the bar was asking is answered as Stop would
   if sAsk["kind"] is not empty and sAsk["answer"] is empty then
      put "stop" into sAsk["answer"]
   end if
end xtaWindowClosed

-- Builds the window: a stack made here rather than shipped as a binary
-- stack, so that all of the plugin is text. Its name begins with "rev", so
-- the IDE treats it as one of its own windows. It wears the suite's look:
-- the band with the title and, at its right, the pill that says what the
-- assistant is doing; the status line; the conversation on a panel; the
-- bar that asks the user (Ask...), on a panel of its own and hidden until
-- something is asked; flat entry fields; and a footer. The behavior
-- (xtalkassistant-window.livecodescript) lays it out, as the kit leaves
-- the layout to each window.
private command xtaBuildWindow
   local tOldDefault, tName
   put the defaultStack into tOldDefault
   lock screen
   lock messages
   create invisible stack kWindow
   set the defaultStack to kWindow
   set the resizable of stack kWindow to true
   set the destroyStack of stack kWindow to true
   xtaUiChrome kTitle, kWindowWidth, kWindowHeight
   set the minWidth of stack kWindow to 460
   set the minHeight of stack kWindow to 520
   set the linkColor of stack kWindow to kUiAccent
   set the linkHiliteColor of stack kWindow to kUiAccent
   set the linkVisitedColor of stack kWindow to kUiAccent
   xtaUiPill "Pill", (kWindowWidth - 108) & ",6," & (kWindowWidth - 16) & ",24"

   create button "Provider"
   set the style of button "Provider" to "menu"
   set the menuMode of button "Provider" to "option"
   set the text of button "Provider" to xtaProviderNames()
   set the tooltip of button "Provider" to "The provider of the AI model"

   create button "Model"
   set the style of button "Model" to "menu"
   set the menuMode of button "Model" to "comboBox"
   set the tooltip of button "Model" to "The model: choose one, or type its name; Models asks the provider for its list"

   create button "Models"
   set the label of button "Models" to "Models"
   set the tooltip of button "Models" to "Ask the provider which models it has"

   create button "More"
   set the style of button "More" to "menu"
   set the menuMode of button "More" to "pulldown"
   set the label of button "More" to "More"
   set the text of button "More" to xtaMoreMenuText()

   -- The conversation, on a panel (made first, so that it is behind)
   xtaUiPanel "ConversationPanel", "16,90," & (kWindowWidth - 16) & ",400"
   create field "Conversation"
   set the lockText of field "Conversation" to true
   set the traversalOn of field "Conversation" to true
   set the dontWrap of field "Conversation" to false
   set the vScrollbar of field "Conversation" to true
   set the threeD of field "Conversation" to false
   set the borderWidth of field "Conversation" to 0
   set the opaque of field "Conversation" to false
   set the margins of field "Conversation" to "6,6,6,6"
   set the textSize of field "Conversation" to 12
   set the foregroundColor of field "Conversation" to kUiInk

   -- The bar that asks the user: what is asked, its details (the changes,
   -- or the code), and the buttons that answer it
   xtaUiPanel "AskPanel", "16,230," & (kWindowWidth - 16) & ",400"
   xtaUiLabel "AskTitle", empty, "28,240," & (kWindowWidth - 28) & ",274", 13
   set the textStyle of field "AskTitle" to "bold"
   xtaUiArea "AskDetail", "28,278," & (kWindowWidth - 28) & ",358"
   set the traversalOn of field "AskDetail" to true
   repeat for each item tName in "AskNo,AskSession,AskYes"
      create button tName
   end repeat
   set the default of button "AskYes" to false
   repeat for each item tName in "AskPanel,AskTitle,AskDetail,AskNo,AskSession,AskYes"
      if tName begins with "AskP" then
         set the visible of graphic tName to false
      else if tName begins with "AskT" or tName begins with "AskD" then
         set the visible of field tName to false
      else
         set the visible of button tName to false
      end if
   end repeat

   create button "Include"
   set the style of button "Include" to "checkbox"
   -- Ticked, a checkbox made by script is drawn with a raised frame
   -- (hiliteBorder); the Tools palette's have none
   set the hiliteBorder of button "Include" to false
   set the label of button "Include" to "Include the open script"
   set the tooltip of button "Include" to "Send the script open in the Script Editor with your question"

   create button "Insert"
   set the label of button "Insert" to "Insert Code"
   set the tooltip of button "Insert" to "Insert the code of the last answer at the caret in the Script Editor (Undo takes it out again)"

   create button "New"
   set the label of button "New" to "New Chat"
   set the tooltip of button "New" to "Start a new conversation"

   xtaUiInput "Prompt", "16,500," & (kWindowWidth - 104) & ",572"
   set the dontWrap of field "Prompt" to false
   set the vScrollbar of field "Prompt" to true
   set the autoTab of field "Prompt" to false
   set the tooltip of field "Prompt" to "Your question. Enter, or Command-Return (Control-Return), sends it."

   create button "Send"
   set the label of button "Send" to "Send"
   set the default of button "Send" to false

   xtaUiFooter xtaFooterText(), "16,614," & (kWindowWidth - 16) & ",632"
   set the dontWrap of field "uiFooter" to true

   set the behavior of stack kWindow to the long id of stack kWindowBehavior
   unlock messages
   set the defaultStack to tOldDefault
   unlock screen
end xtaBuildWindow

-- What the footer says: what the assistant may do to the user's stacks
private function xtaFooterText
   if xtaBuildOn() then
      return "Nothing changes or runs until you say yes, and Undo takes it back."
   end if
   return "The model reads and answers: it cannot change your stacks."
end xtaFooterText

--------------------------------------------------------------------------------
-- The suite's look
--
-- The xTalk Suite's UI kit v2 (tools/ui-kit.livecodescript), its builders
-- matched by value and named xtaUi...: each makes a control of the
-- defaultStack, which is the window being built, as the kit's do. Labels
-- here also take no focus (traversalOn false), since these windows are
-- the IDE's and Tab should go from field to field.

-- The platform's own mono face
private function xtaUiMonoFont
   if the platform is "MacOS" then
      return "Menlo"
   else if the platform is "Win32" then
      return "Consolas"
   end if
   return "DejaVu Sans Mono"
end xtaUiMonoFont

-- The page, the accent band with the title, and the status line under it
-- (field "Status", which xtaStatus and the dialogs write)
private command xtaUiChrome pTitle, pWidth, pHeight
   local tHeight
   set the width of this stack to pWidth
   set the height of this stack to pHeight
   set the backgroundColor of this card to kUiBg
   set the title of this stack to pTitle
   xtaUiGfx "uiBand", "0,0," & pWidth & comma & kUiBand
   set the style of graphic "uiBand" to "rectangle"
   set the filled of graphic "uiBand" to true
   set the backgroundColor of graphic "uiBand" to kUiAccent
   set the lineSize of graphic "uiBand" to 0
   xtaUiLabel "uiTitle", "  " & pTitle, "0,0," & pWidth & comma & kUiBand, 15
   set the foregroundColor of field "uiTitle" to kUiAccentText
   set the textStyle of field "uiTitle" to "bold"
   set the dontWrap of field "uiTitle" to true
   -- Centered on the band by its measured height, as the kit does
   put the formattedHeight of field "uiTitle" into tHeight
   if tHeight > 0 and tHeight < kUiBand then
      set the height of field "uiTitle" to tHeight
      set the top of field "uiTitle" to (kUiBand - tHeight) div 2
   end if
   xtaUiLabel "Status", empty, "16," & (kUiBand + 4) & comma & (pWidth - 16) & comma & (kUiBand + 22), 11
   set the dontWrap of field "Status" to true
   set the foregroundColor of field "Status" to kUiInkSoft
end xtaUiChrome

-- A caption at a fixed rect
private command xtaUiLabel pName, pText, pRect, pSize
   if there is not a field pName then
      create field pName
   end if
   set the rect of field pName to pRect
   set the lockText of field pName to true
   set the traversalOn of field pName to false
   set the borderWidth of field pName to 0
   set the opaque of field pName to false
   set the threeD of field pName to false
   set the textSize of field pName to pSize
   set the foregroundColor of field pName to kUiInk
   put pText into field pName
end xtaUiLabel

-- A caption fit to the height of its text, its top where pRect says
private command xtaUiWrap pName, pText, pRect, pSize
   local tHeight
   xtaUiLabel pName, pText, pRect, pSize
   if pText is not empty then
      put the formattedHeight of field pName into tHeight
      if tHeight > 0 then
         set the height of field pName to tHeight
         set the top of field pName to item 2 of pRect
      end if
   end if
end xtaUiWrap

-- A small, muted caption
private command xtaUiCap pName, pText, pRect
   xtaUiWrap pName, pText, pRect, 10
   set the foregroundColor of field pName to kUiMuted
end xtaUiCap

-- A numbered section's header, with a hairline under it
private command xtaUiSection pName, pText, pRect
   local tBottom
   xtaUiWrap pName, pText, pRect, 13
   set the textStyle of field pName to "bold"
   put the bottom of field pName into tBottom
   xtaUiGfx pName & "Line", (item 1 of pRect) & comma & (tBottom + 1) & comma & (item 3 of pRect) & comma & (tBottom + 2)
   set the style of graphic (pName & "Line") to "rectangle"
   set the filled of graphic (pName & "Line") to true
   set the backgroundColor of graphic (pName & "Line") to kUiCardLine
   set the lineSize of graphic (pName & "Line") to 0
end xtaUiSection

-- An entry field: flat, a hairline border, the mono face
private command xtaUiInput pName, pRect
   if there is not a field pName then
      create field pName
   end if
   set the rect of field pName to pRect
   set the lockText of field pName to false
   set the traversalOn of field pName to true
   set the threeD of field pName to false
   set the borderWidth of field pName to 1
   set the borderColor of field pName to kUiFieldLine
   set the opaque of field pName to true
   set the backgroundColor of field pName to kUiCard
   set the margins of field pName to "6,6,6,6"
   set the textSize of field pName to 11
   set the textFont of field pName to xtaUiMonoFont()
end xtaUiInput

-- A read-only area for code and data: mono, flat, scrolling
private command xtaUiArea pName, pRect
   if there is not a field pName then
      create field pName
   end if
   set the rect of field pName to pRect
   set the lockText of field pName to true
   set the traversalOn of field pName to false
   set the threeD of field pName to false
   set the borderWidth of field pName to 1
   set the borderColor of field pName to kUiCardLine
   set the opaque of field pName to true
   set the backgroundColor of field pName to kUiCard
   set the margins of field pName to "6,6,6,6"
   set the vScrollbar of field pName to true
   set the textSize of field pName to 10
   set the textFont of field pName to xtaUiMonoFont()
end xtaUiArea

private command xtaUiGfx pName, pRect
   if there is not a graphic pName then
      create graphic pName
   end if
   set the rect of graphic pName to pRect
   set the style of graphic pName to "roundRect"
   set the antialiased of graphic pName to true
end xtaUiGfx

-- A panel: white, rounded, a hairline and a soft shadow (an engine
-- without shadows shows the hairline alone)
private command xtaUiPanel pName, pRect
   local tShadow, tError
   xtaUiGfx pName, pRect
   set the roundRadius of graphic pName to 14
   set the filled of graphic pName to true
   set the backgroundColor of graphic pName to kUiCard
   set the lineSize of graphic pName to 1
   set the foregroundColor of graphic pName to kUiCardLine
   set the borderColor of graphic pName to kUiCardLine
   try
      put "90,98,114" into tShadow["color"]
      put 30 into tShadow["opacity"]
      put 10 into tShadow["size"]
      put 0 into tShadow["spread"]
      put 2 into tShadow["distance"]
      put 90 into tShadow["angle"]
      set the dropShadow of graphic pName to tShadow
   catch tError
   end try
end xtaUiPanel

-- A pill: a rounded chip (graphic pName & "Bg") and its label (field
-- pName), colored by xtaSetPill
private command xtaUiPill pName, pRect
   local tTop, tBottom, tHeight
   put item 2 of pRect into tTop
   put item 4 of pRect into tBottom
   xtaUiGfx pName & "Bg", pRect
   set the roundRadius of graphic (pName & "Bg") to tBottom - tTop
   set the filled of graphic (pName & "Bg") to true
   set the lineSize of graphic (pName & "Bg") to 0
   xtaUiLabel pName, "Ready", pRect, 10
   set the textAlign of field pName to "center"
   set the dontWrap of field pName to true
   -- Centered on the chip by its measured height
   put the formattedHeight of field pName into tHeight
   if tHeight > 0 and tHeight < tBottom - tTop then
      set the height of field pName to tHeight
      set the top of field pName to tTop + ((tBottom - tTop - tHeight) div 2)
   end if
end xtaUiPill

-- A footer: italic, muted
private command xtaUiFooter pText, pRect
   xtaUiLabel "uiFooter", pText, pRect, 11
   set the textStyle of field "uiFooter" to "italic"
   set the foregroundColor of field "uiFooter" to kUiMuted
end xtaUiFooter

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
   set the text of button "Model" of stack kWindow to xtaModelMenu(tProvider, sModelMenus[tProvider])
   set the label of button "Model" of stack kWindow to xtaModel(tProvider)
   set the hilite of button "Include" of stack kWindow to (revIDEGetPreference(kPrefIncludeScript) is not false)
   set the text of button "More" of stack kWindow to xtaMoreMenuText()
   set the text of field "uiFooter" of stack kWindow to xtaFooterText()
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
   xtaPaintPill
end xtaUpdateButtons

-- The pill at the right of the band says what the assistant is doing:
-- waiting for the user's answer in the bar, working on a question, without
-- a key, or ready
private command xtaPaintPill
   local tProvider
   if there is not a stack kWindow then
      exit xtaPaintPill
   end if
   put xtaProvider() into tProvider
   if sAsk["kind"] is not empty then
      xtaSetPill "Needs you", "wait"
   else if sBusy is true then
      xtaSetPill "Working", "wait"
   else if xtaKey(tProvider) is empty and xtaBaseUrl(tProvider) is empty then
      xtaSetPill "No key", "bad"
   else
      xtaSetPill "Ready", "ok"
   end if
end xtaPaintPill

-- The kit's pill colors, by kind: ok green, wait amber, bad red, and
-- otherwise the muted blue of the band
private command xtaSetPill pText, pKind
   local tGround, tInk
   switch pKind
      case "ok"
         put "205,240,214" into tGround
         put "22,101,52" into tInk
         break
      case "wait"
         put "250,240,199" into tGround
         put "133,98,14" into tInk
         break
      case "bad"
         put "243,215,213" into tGround
         put "135,44,38" into tInk
         break
      default
         put "31,64,116" into tGround
         put kUiAccentSub into tInk
   end switch
   lock messages
   set the backgroundColor of graphic "PillBg" of stack kWindow to tGround
   set the text of field "Pill" of stack kWindow to pText
   set the foregroundColor of field "Pill" of stack kWindow to tInk
   unlock messages
end xtaSetPill

-- The items of the More menu; the short guide's is ticked while it is used
-- (and with it no tools are sent, which small models mistake), and Undo
-- All Changes is there while something the assistant did can be undone
private function xtaMoreMenuText
   local tShort, tUndo
   if revIDEGetPreference(kPrefShortGuide) is true then
      put "!c" into tShort
   else
      put "!n" into tShort
   end if
   if xtaAppliedCount() is 0 then
      put "(" into tUndo
   end if
   return "Settings..." & return & "Set API Key..." & return & "Forget API Key" & return & "-" & return & \
         "Explain the Last Error" & return & tUndo & "Undo All Changes..." & return & "Memory..." & return & \
         tShort & "Short Guide, No Tools (for small local models)" & return & "-" & return & \
         "Turn Off xTalk Assistant"
end xtaMoreMenuText

-- The status line, colored as the kit colors it: pKind "ok" green, "warn"
-- amber, "bad" red, anything else the soft ink
private command xtaStatus pText, pKind
   local tColor
   if there is not a stack kWindow then
      exit xtaStatus
   end if
   switch pKind
      case "ok"
         put kUiOk into tColor
         break
      case "warn"
         put kUiWarn into tColor
         break
      case "bad"
         put kUiBad into tColor
         break
      default
         put kUiInkSoft into tColor
   end switch
   lock messages
   set the text of field "Status" of stack kWindow to pText
   set the foregroundColor of field "Status" of stack kWindow to tColor
   unlock messages
end xtaStatus

private function xtaSettingsLine
   local tProvider, tLine
   put xtaProvider() into tProvider
   put xtaProviderName(tProvider) into tLine
   if xtaKey(tProvider) is empty then
      put " - no API key yet (More > Settings...)" after tLine
   else if sKeys[tProvider] is empty then
      put " - API key from the environment" after tLine
   end if
   if xtaModel(tProvider) is empty then
      put " - no model yet (Send chooses one)" after tLine
   else
      put " -" && xtaModel(tProvider) after tLine
   end if
   return tLine
end xtaSettingsLine

-- The conversation, as the window shows it: who said it, in bold in the
-- accent, then what they said, code on the code ground in the Script
-- Editor's font (else the platform's mono face). After an answer, in
-- italics, what the compile check found, and each note the answer
-- proposes to remember, with Remember and Dismiss as links (the answer's
-- memory block itself is not shown). A compile check sent back to the
-- model shows as a turn of its own; what the model's tools did, as a line
-- each in italics, with Undo after changes it made and runs on a stack
-- (and under changes, what they were).
private command xtaShowConversation
   local tText, tIndex, tLine, tInCode, tFont, tLineNumber, tLabelLines, tItalicLines
   local tLinks, tLink, tNote, tCount, tWords, tBody, tCall, tSummary, tResult, tEntry
   local tStates, tEntries, tUndoLinks, tShown, tMore
   if there is not a stack kWindow then
      exit xtaShowConversation
   end if
   -- What became of what the tools changed: applied or undone, by entry
   if xtaBuildLoaded() then
      put xtaBuildEntries() into tEntries
      repeat with tIndex = 1 to the number of elements of tEntries
         put tEntries[tIndex]["state"] into tStates[tEntries[tIndex]["number"]]
      end repeat
   end if
   -- The line numbers of the labels and of the italic lines, so that a line
   -- of an answer that reads the same is not taken for one; and for each
   -- note's line, its links ("line,turn,note"), and for each line that can
   -- be undone, its entry ("line,entry")
   put 0 into tCount
   repeat with tIndex = 1 to the number of elements of sTurns
      if sTurns[tIndex]["kind"] is "tools" then
         repeat with tCall = 1 to the number of elements of sTurns[tIndex]["results"]
            put sTurns[tIndex]["results"][tCall] into tResult
            put tResult["summary"] into tSummary
            replace return with space in tSummary
            put tResult["entry"] into tEntry
            if tEntry is not empty then
               if tStates[tEntry] is "applied" then
                  put "    Undo" after tSummary
                  put tCount + 1 & comma & tEntry & return after tUndoLinks
               else if tStates[tEntry] is "undone" then
                  put "    (undone)" after tSummary
               end if
            end if
            put tCount + 1 & comma after tItalicLines
            xtaAddLines tText, tCount, tSummary
            -- What a batch changed, a line each (the first few)
            put 0 into tShown
            repeat for each line tLine in tResult["lines"]
               add 1 to tShown
               if tShown > kShownChanges then
                  put the number of lines of tResult["lines"] - kShownChanges into tMore
                  put tCount + 1 & comma after tItalicLines
                  xtaAddLines tText, tCount, "      ... and" && tMore && "more"
                  exit repeat
               end if
               put tCount + 1 & comma after tItalicLines
               xtaAddLines tText, tCount, "      " & tLine
            end repeat
         end repeat
         xtaAddLines tText, tCount, empty
         next repeat
      end if
      -- An answer that only asked for tools shows as what they did
      if sTurns[tIndex]["role"] is "assistant" and the number of elements of sTurns[tIndex]["calls"] > 0 \
            and word 1 to -1 of xtaWithoutMemoryBlocks(sTurns[tIndex]["text"]) is empty \
            and the number of elements of sTurns[tIndex]["notes"] is 0 then
         next repeat
      end if
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
         if sTurns[tIndex]["attach"] is not empty then
            put return & "(with the last error, in" && sTurns[tIndex]["attachName"] & ")" after tBody
         end if
         if sTurns[tIndex]["context"] is not empty then
            put return & "(with the script of" && sTurns[tIndex]["contextName"] & ")" after tBody
         end if
         xtaAddLines tText, tCount, "You" & return & tBody
      end if
      xtaAddLines tText, tCount, empty
   end repeat
   lock screen
   lock messages
   set the text of field "Conversation" of stack kWindow to tText
   put revIDEGetPreference("cScriptEditor,editor,font") into tFont
   if tFont is empty then
      put xtaUiMonoFont() into tFont
   end if
   put false into tInCode
   put 0 into tLineNumber
   repeat for each line tLine in tText
      add 1 to tLineNumber
      if tLineNumber is among the items of tLabelLines then
         set the textStyle of line tLineNumber of field "Conversation" of stack kWindow to "bold"
         set the foregroundColor of line tLineNumber of field "Conversation" of stack kWindow to kUiAccent
         put false into tInCode
         next repeat
      end if
      if tLineNumber is among the items of tItalicLines then
         set the textStyle of line tLineNumber of field "Conversation" of stack kWindow to "italic"
         set the foregroundColor of line tLineNumber of field "Conversation" of stack kWindow to kUiInkSoft
         next repeat
      end if
      -- Code, with its fences, on the code ground (a line's backgroundColor
      -- is its paragraph's, the width of the field)
      if word 1 to -1 of tLine begins with "```" then
         set the textFont of line tLineNumber of field "Conversation" of stack kWindow to tFont
         set the foregroundColor of line tLineNumber of field "Conversation" of stack kWindow to kUiMuted
         set the backgroundColor of line tLineNumber of field "Conversation" of stack kWindow to kUiCodeBg
         put not tInCode into tInCode
         next repeat
      end if
      if tInCode then
         set the textFont of line tLineNumber of field "Conversation" of stack kWindow to tFont
         set the backgroundColor of line tLineNumber of field "Conversation" of stack kWindow to kUiCodeBg
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
   -- And Undo, the last word of the line of what can be undone
   repeat for each line tLink in tUndoLinks
      put item 1 of tLink into tLineNumber
      put the number of words of line tLineNumber of field "Conversation" of stack kWindow into tWords
      set the textStyle of word tWords of line tLineNumber of field "Conversation" of stack kWindow to "link"
      set the linkText of word tWords of line tLineNumber of field "Conversation" of stack kWindow to "undo," & item 2 of tLink
   end repeat
   unlock messages
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
   put revIDEGetPreference(kPrefMaxTokens) into tSettings["maxTokens"]
   put revIDEGetPreference(kPrefTimeout) into tSettings["timeout"]
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
      case "Settings..."
         xtaSettingsDialog empty
         break
      case "Set API Key..."
         xtaSettingsDialog "Key"
         break
      case "Forget API Key"
         put empty into sKeys[xtaProvider()]
         xtaStatus xtaSettingsLine()
         break
      case "Explain the Last Error"
         xtaExplainLastError
         break
      case "Undo All Changes..."
         xtaUndoAll
         break
      case "Memory..."
         xtaEditMemory
         break
      case "Short Guide, No Tools (for small local models)"
         revIDESetPreference kPrefShortGuide, (revIDEGetPreference(kPrefShortGuide) is not true)
         xtaRefreshWindow
         break
      case "Turn Off xTalk Assistant"
         xtaTurnOff
         break
   end switch
end xtaMoreMenuPick

--------------------------------------------------------------------------------
-- The Settings dialog
--
-- Every setting in one place (More > Settings...): the provider, its key,
-- base URL and model, the longest answer, how long to wait for one, the
-- fix rounds, the tools, the short guide and whether the open script goes
-- with a question. The key is typed or pasted into an ordinary field: the
-- engine's "ask password" dialog keeps only keys typed one by one, so a
-- pasted key came back empty and the assistant said there was no key
-- (0.2.5-rc.3). Get Models asks the provider for its list with what is in
-- the dialog, which also tells the user whether the key works. Nothing is
-- kept until Save, and Save keeps nothing until all of it checks out.

-- Opens the dialog and waits for it to close; pFocus "Key" puts the caret
-- in the key's field. Returns true when the user pressed Save. The dialog
-- is built each time, and goes when it closes.
private function xtaOpenSettings pFocus
   xtaSettingsPrepare pFocus
   -- It is built invisible, and "modal" returns at once for an invisible
   -- stack, so it is shown first
   lock screen
   set the visible of stack kSettingsWindow to true
   unlock screen
   modal stack kSettingsWindow
   return xtaSettingsDone()
end xtaOpenSettings

-- The steps before and after the dialog's modal loop, apart so that the
-- engine tests can take them (outside the IDE "modal" returns at once)
on xtaSettingsPrepare pFocus
   local tProvider
   xtaLoadParts
   if there is a stack kSettingsWindow then
      delete stack kSettingsWindow
   end if
   xtaBuildSettings
   put xtaProvider() into tProvider
   put tProvider into sSettingsProvider
   put empty into sDrafts
   put false into sSettingsSaved
   put false into sSettingsFetch
   xtaFillSettings tProvider, true
   if pFocus is "Key" then
      set the cFocus of stack kSettingsWindow to "Key"
   end if
   if there is a stack kWindow and the visible of stack kWindow then
      set the loc of stack kSettingsWindow to the loc of stack kWindow
   else
      set the loc of stack kSettingsWindow to the screenLoc
   end if
end xtaSettingsPrepare

function xtaSettingsDone
   put empty into sDrafts
   if there is a stack kSettingsWindow then
      delete stack kSettingsWindow
   end if
   xtaRefreshWindow
   return sSettingsSaved is true
end xtaSettingsDone

-- More > Settings... and More > Set API Key...: after a new key, base URL
-- or provider, the models, which tell the user at once whether it works
-- (unless Get Models just did)
private command xtaSettingsDialog pFocus
   local tProvider
   if not xtaOpenSettings(pFocus) or sSettingsFetch is not true then
      exit xtaSettingsDialog
   end if
   put xtaProvider() into tProvider
   if xtaKey(tProvider) is not empty or xtaBaseUrl(tProvider) is not empty then
      xtaChooseModels
   end if
end xtaSettingsDialog

-- Builds the dialog, invisible: a stack made here, as the window is, in
-- the suite's look: the band, then what Save and Get Models found on the
-- status line (field "Result", two lines high, since a provider's refusal
-- can be long), then numbered sections. It fits a 720p screen.
private command xtaBuildSettings
   local tOldDefault, tTop, tLeft, tRight, tWidth
   put the defaultStack into tOldDefault
   put kSettingsWidth into tWidth
   put 168 into tLeft
   put tWidth - 16 into tRight
   lock screen
   lock messages
   create invisible stack kSettingsWindow
   set the defaultStack to kSettingsWindow
   set the resizable of stack kSettingsWindow to false
   set the destroyStack of stack kSettingsWindow to true
   xtaUiChrome kTitle && "Settings", tWidth, 600
   set the name of field "Status" to "Result"
   set the rect of field "Result" to 16, kUiBand + 4, tRight, kUiBand + 34
   set the dontWrap of field "Result" to false

   put 68 into tTop
   xtaSettingsSection "Section1", "1  Provider and key", tTop
   xtaSettingsLabel "Provider", tTop
   create button "Provider"
   set the style of button "Provider" to "menu"
   set the menuMode of button "Provider" to "option"
   set the text of button "Provider" to xtaProviderNames()
   set the rect of button "Provider" to tLeft, tTop, tLeft + 180, tTop + 24

   add 30 to tTop
   xtaSettingsLabel "API key", tTop
   xtaSettingsField "Key", tLeft, tTop, tRight - 108
   set the tooltip of field "Key" to "Type or paste the API key"
   create button "Forget Key"
   set the rect of button "Forget Key" to tRight - 100, tTop, tRight, tTop + 24
   set the tooltip of button "Forget Key" to "Forget the key typed for this provider"
   add 25 to tTop
   xtaSettingsNote "Key Note", tLeft, tTop, tRight, 31

   add 35 to tTop
   xtaSettingsLabel "Base URL", tTop
   xtaSettingsField "Base URL", tLeft, tTop, tRight
   add 25 to tTop
   xtaSettingsNote "Base URL Note", tLeft, tTop, tRight, 31

   add 35 to tTop
   xtaSettingsSection "Section2", "2  Model", tTop
   xtaSettingsLabel "Model", tTop
   create button "Model"
   set the style of button "Model" to "menu"
   set the menuMode of button "Model" to "comboBox"
   set the rect of button "Model" to tLeft, tTop, tRight - 108, tTop + 24
   set the tooltip of button "Model" to "Choose a model, or type its name"
   create button "Get Models"
   set the rect of button "Get Models" to tRight - 100, tTop, tRight, tTop + 24
   set the tooltip of button "Get Models" to "Ask the provider for its models (this also tries the key)"
   add 25 to tTop
   xtaSettingsNote "Model Note", tLeft, tTop, tRight, 31
   put "Choose a model or type its name. Get Models asks the provider for all of them, and tells you whether the key works." \
         into field "Model Note"

   add 35 to tTop
   xtaSettingsSection "Section3", "3  Answers", tTop
   xtaSettingsLabel "Longest answer", tTop
   xtaSettingsField "Max Tokens", tLeft, tTop, tLeft + 80
   xtaSettingsNote "Max Tokens Note", tLeft + 88, tTop + 2, tRight, 20
   put "tokens (empty: 4096 for Anthropic; OpenAI's model decides)" into field "Max Tokens Note"

   add 30 to tTop
   xtaSettingsLabel "Fix rounds", tTop
   xtaSettingsField "Fix Rounds", tLeft, tTop, tLeft + 80
   xtaSettingsNote "Fix Rounds Note", tLeft + 88, tTop + 2, tRight, 20
   put "0 to" && kMaxFixRounds & ": tries to correct code that does not compile" into field "Fix Rounds Note"

   add 30 to tTop
   xtaSettingsLabel "Wait for an answer", tTop
   xtaSettingsField "Timeout", tLeft, tTop, tLeft + 80
   xtaSettingsNote "Timeout Note", tLeft + 88, tTop + 2, tRight, 20
   put "seconds (" & kMinTimeout && "to" && kMaxTimeout & "; empty:" && kDefaultTimeout & ")" into field "Timeout Note"

   add 34 to tTop
   xtaSettingsSection "Section4", "4  What the model may do", tTop
   xtaSettingsCheckbox "Include", "Send the open script with each question", tLeft, tTop, tRight
   set the tooltip of button "Include" to "Send the script open in the Script Editor with each question"
   add 22 to tTop
   xtaSettingsCheckbox "Tools", "Let the model look things up, check its code and read your stack", tLeft, tTop, tRight
   set the tooltip of button "Tools" to "The Dictionary, a compile check, your stack and a paused script (when you allow it), and the last error"
   add 22 to tTop
   xtaSettingsCheckbox "Build", "Let the model change your stacks and run code (it asks you first)", tLeft, tTop, tRight
   set the tooltip of button "Build" to "Changes you apply or not, and code you let run; Undo takes them back"
   add 22 to tTop
   xtaSettingsCheckbox "Short Guide", "Short guide, no tools (for small local models)", tLeft, tTop, tRight

   -- The dialog is no taller than 640, the suite's limit (a 720p screen)
   add 28 to tTop
   create button "Cancel"
   set the rect of button "Cancel" to tRight - 196, tTop, tRight - 106, tTop + 24
   create button "Save"
   set the rect of button "Save" to tRight - 98, tTop, tRight, tTop + 24
   set the default of button "Save" to true
   set the height of stack kSettingsWindow to tTop + 24 + 16

   set the behavior of stack kSettingsWindow to the long id of stack kSettingsBehavior
   unlock messages
   set the defaultStack to tOldDefault
   unlock screen
end xtaBuildSettings

-- A numbered section's header at xTop, which then is where its first row
-- goes (the dialog is the defaultStack while it is built)
private command xtaSettingsSection pName, pText, @xTop
   xtaSettingsSectionIn pName, pText, xTop, kSettingsWidth
   add 2 to xTop
end xtaSettingsSection

-- A label at the left of a row
private command xtaSettingsLabel pText, pTop
   xtaUiLabel "Label" && pText, pText, "16," & (pTop + 4) & ",158," & (pTop + 20), 11
   set the textAlign of field ("Label" && pText) to "right"
   set the dontWrap of field ("Label" && pText) to true
end xtaSettingsLabel

-- A one-line entry field
private command xtaSettingsField pName, pLeft, pTop, pRight
   xtaUiInput pName, pLeft & comma & pTop & comma & pRight & comma & (pTop + 24)
   set the dontWrap of field pName to true
   set the autoTab of field pName to false
end xtaSettingsField

-- Small text that explains the row above it (or beside it, one line).
-- The top margin is 4: with less, the engine clips the tops of the first
-- line's letters; and the margins are given as four numbers, the form
-- the suite's kit found OXT keeps.
private command xtaSettingsNote pName, pLeft, pTop, pRight, pHeight
   xtaUiLabel pName, empty, pLeft & comma & pTop & comma & pRight & comma & (pTop + pHeight), 10
   set the foregroundColor of field pName to kUiMuted
   set the dontWrap of field pName to (pHeight < 24)
   set the margins of field pName to "1,4,1,1"
end xtaSettingsNote

private command xtaSettingsCheckbox pName, pLabel, pLeft, pTop, pRight
   create button pName
   set the style of button pName to "checkbox"
   set the hiliteBorder of button pName to false
   set the label of button pName to pLabel
   set the foregroundColor of button pName to kUiInk
   set the rect of button pName to pLeft, pTop, pRight, pTop + 20
end xtaSettingsCheckbox

-- Shows pProvider's settings: what was typed for it before the dialog was
-- switched to another, else what is kept. With pAll, the settings that are
-- the same for every provider too.
private command xtaFillSettings pProvider, pAll
   local tMenu, tModel, tNote
   lock messages
   set the label of button "Provider" of stack kSettingsWindow to xtaProviderName(pProvider)
   put sDrafts[pProvider]["key"] into field "Key" of stack kSettingsWindow
   if "baseUrl" is among the keys of sDrafts[pProvider] then
      put sDrafts[pProvider]["baseUrl"] into field "Base URL" of stack kSettingsWindow
   else
      put xtaBaseUrl(pProvider) into field "Base URL" of stack kSettingsWindow
   end if
   if "model" is among the keys of sDrafts[pProvider] then
      put sDrafts[pProvider]["model"] into tModel
   else
      put xtaModel(pProvider) into tModel
   end if
   put sDrafts[pProvider]["menu"] into tMenu
   if tMenu is empty then
      put xtaModelMenu(pProvider, sModelMenus[pProvider]) into tMenu
   end if
   set the text of button "Model" of stack kSettingsWindow to tMenu
   set the label of button "Model" of stack kSettingsWindow to tModel
   put xtaKeyNote(pProvider) into field "Key Note" of stack kSettingsWindow
   put "Empty means" && xtaDefaultBaseUrl(pProvider) & "." into tNote
   if pProvider is "openai" then
      put " For a local server with OpenAI's API, for example http://localhost:11434/v1 (Ollama), which may need no key." after tNote
   end if
   put tNote into field "Base URL Note" of stack kSettingsWindow
   xtaSettingsResult empty
   if pAll then
      put revIDEGetPreference(kPrefMaxTokens) into field "Max Tokens" of stack kSettingsWindow
      put xtaFixRounds() into field "Fix Rounds" of stack kSettingsWindow
      put revIDEGetPreference(kPrefTimeout) into field "Timeout" of stack kSettingsWindow
      set the hilite of button "Include" of stack kSettingsWindow to (revIDEGetPreference(kPrefIncludeScript) is not false)
      set the hilite of button "Tools" of stack kSettingsWindow to (revIDEGetPreference(kPrefTools) is not false)
      set the hilite of button "Build" of stack kSettingsWindow to (revIDEGetPreference(kPrefBuild) is not false)
      set the hilite of button "Short Guide" of stack kSettingsWindow to (revIDEGetPreference(kPrefShortGuide) is true)
   end if
   unlock messages
   xtaSettingsSwitches
end xtaFillSettings

-- The switches that do something with the others as they are: the tools
-- not with the short guide, and changing stacks only with the tools
on xtaSettingsSwitches
   local tTools
   if there is not a stack kSettingsWindow then
      exit xtaSettingsSwitches
   end if
   put not the hilite of button "Short Guide" of stack kSettingsWindow into tTools
   set the enabled of button "Tools" of stack kSettingsWindow to tTools
   set the enabled of button "Build" of stack kSettingsWindow to (tTools and the hilite of button "Tools" of stack kSettingsWindow)
end xtaSettingsSwitches

-- What the dialog says on its status line (what Save and Get Models
-- found), colored as the kit colors the status line
private command xtaSettingsResult pText, pKind
   local tColor
   switch pKind
      case "ok"
         put kUiOk into tColor
         break
      case "warn"
         put kUiWarn into tColor
         break
      case "bad"
         put kUiBad into tColor
         break
      default
         put kUiInkSoft into tColor
   end switch
   lock messages
   set the text of field "Result" of stack kSettingsWindow to pText
   set the foregroundColor of field "Result" of stack kSettingsWindow to tColor
   unlock messages
end xtaSettingsResult

-- What the dialog says about pProvider's key. Only its last four
-- characters are ever shown.
private function xtaKeyNote pProvider
   local tName
   put xtaProviderName(pProvider) into tName
   if sKeys[pProvider] is not empty then
      return "A key is set, ending in" && quote & char -4 to -1 of sKeys[pProvider] & quote & \
            ". Paste another here to change it. It is kept in memory until you quit OXT-Beyond, and never saved."
   end if
   if xtaKey(pProvider) is not empty then
      return "The key in the environment variable" && xtaKeyVariable(pProvider) && \
            "is used. Paste one here to use it instead (kept in memory until you quit, never saved)."
   end if
   return "Paste your" && tName && "API key here. It is kept in memory until you quit OXT-Beyond, and never saved."
end xtaKeyNote

private function xtaKeyVariable pProvider
   switch pProvider
      case "anthropic"
         return "ANTHROPIC_API_KEY"
      case "openai"
         return "OPENAI_API_KEY"
   end switch
   return empty
end xtaKeyVariable

-- The Provider menu of the dialog: what was typed for the one shown is
-- kept as a draft, and the other's settings shown
on xtaSettingsProvider pName
   local tProvider
   if there is not a stack kSettingsWindow then
      exit xtaSettingsProvider
   end if
   repeat for each item tProvider in xtaProviders()
      if xtaProviderName(tProvider) is pName and tProvider is not sSettingsProvider then
         xtaKeepDraft sSettingsProvider
         put tProvider into sSettingsProvider
         xtaFillSettings tProvider, false
      end if
   end repeat
end xtaSettingsProvider

private command xtaKeepDraft pProvider
   put field "Key" of stack kSettingsWindow into sDrafts[pProvider]["key"]
   put field "Base URL" of stack kSettingsWindow into sDrafts[pProvider]["baseUrl"]
   put the label of button "Model" of stack kSettingsWindow into sDrafts[pProvider]["model"]
end xtaKeepDraft

on xtaSettingsForgetKey
   if there is not a stack kSettingsWindow then
      exit xtaSettingsForgetKey
   end if
   put empty into sKeys[sSettingsProvider]
   put empty into sDrafts[sSettingsProvider]["key"]
   put empty into field "Key" of stack kSettingsWindow
   put xtaKeyNote(sSettingsProvider) into field "Key Note" of stack kSettingsWindow
   xtaSettingsResult "The key is forgotten.", "ok"
end xtaSettingsForgetKey

-- Get Models: the provider's list, asked with what is in the dialog
on xtaSettingsGetModels
   local tProvider, tSettings, tResult, tMenu, tCount
   if there is not a stack kSettingsWindow then
      exit xtaSettingsGetModels
   end if
   put sSettingsProvider into tProvider
   xtaKeepDraft tProvider
   put xtaSettingsChecked() into tSettings
   if tSettings["error"] is not empty then
      xtaSettingsResult tSettings["error"], "bad"
      exit xtaSettingsGetModels
   end if
   put tProvider into tSettings["provider"]
   put tSettings["drafts"][tProvider]["baseUrl"] into tSettings["baseUrl"]
   put tSettings["drafts"][tProvider]["key"] into tSettings["key"]
   if tSettings["key"] is empty then
      put xtaKey(tProvider) into tSettings["key"]
   end if
   if tSettings["key"] is empty and tSettings["baseUrl"] is empty then
      xtaSettingsResult "Paste the API key first.", "warn"
      exit xtaSettingsGetModels
   end if
   xtaSettingsResult "Asking" && xtaProviderName(tProvider) && "for its models..."
   set the enabled of button "Get Models" of stack kSettingsWindow to false
   put xtaListModels(tSettings) into tResult
   put empty into tSettings
   -- Closed meanwhile (Cancel works while it waits), or switched provider
   if there is not a stack kSettingsWindow then
      exit xtaSettingsGetModels
   end if
   set the enabled of button "Get Models" of stack kSettingsWindow to true
   if sSettingsProvider is not tProvider then
      exit xtaSettingsGetModels
   end if
   if tResult["error"] is not empty then
      xtaSettingsResult "That did not work:" && tResult["error"], "bad"
      exit xtaSettingsGetModels
   end if
   put xtaModelMenu(tProvider, tResult["models"]) into tMenu
   put tMenu into sDrafts[tProvider]["menu"]
   put the number of lines of tResult["models"] into tCount
   lock messages
   set the text of button "Model" of stack kSettingsWindow to tMenu
   if word 1 to -1 of the label of button "Model" of stack kSettingsWindow is empty then
      set the label of button "Model" of stack kSettingsWindow to tResult["default"]
   end if
   unlock messages
   xtaSettingsResult xtaProviderName(tProvider) && "listed" && tCount && "models, so it takes the key. Choose one, then Save.", "ok"
end xtaSettingsGetModels

-- What the dialog holds, checked: "drafts" (by provider: "key", "baseUrl"
-- and "model", trimmed, a base URL that is the provider's own as empty),
-- "maxTokens", "fixRounds" and "timeout"; or "error", why it cannot be
-- kept, in words for the user. The shown provider's fields must be in
-- sDrafts already (xtaKeepDraft).
private function xtaSettingsChecked
   local tChecked, tProvider, tKey, tUrl, tNumber
   repeat for each key tProvider in sDrafts
      put word 1 to -1 of sDrafts[tProvider]["key"] into tKey
      if tKey contains numToChar(10) or tKey contains numToChar(13) or tKey contains space or tKey contains tab then
         put "The" && xtaProviderName(tProvider) && "key has a space or a line break in it: paste it again, just the key." into tChecked["error"]
         return tChecked
      end if
      put tKey into tChecked["drafts"][tProvider]["key"]
      put word 1 to -1 of sDrafts[tProvider]["baseUrl"] into tUrl
      if tUrl is xtaDefaultBaseUrl(tProvider) then
         put empty into tUrl
      end if
      if tUrl is not empty and not (tUrl begins with "https://" or tUrl begins with "http://") then
         put "A base URL begins with https:// (or http:// for a server on this computer)." into tChecked["error"]
         return tChecked
      end if
      put tUrl into tChecked["drafts"][tProvider]["baseUrl"]
      put word 1 to -1 of sDrafts[tProvider]["model"] into tChecked["drafts"][tProvider]["model"]
   end repeat
   put word 1 to -1 of field "Max Tokens" of stack kSettingsWindow into tNumber
   if tNumber is not empty and not (tNumber is an integer and tNumber >= 1 and tNumber <= kMaxMaxTokens) then
      put "The longest answer is a whole number of tokens, from 1 to" && kMaxMaxTokens & ", or empty." into tChecked["error"]
      return tChecked
   end if
   put tNumber into tChecked["maxTokens"]
   put word 1 to -1 of field "Fix Rounds" of stack kSettingsWindow into tNumber
   if tNumber is empty then
      put kDefaultFixRounds into tNumber
   end if
   if not (tNumber is an integer and tNumber >= 0 and tNumber <= kMaxFixRounds) then
      put "The fix rounds are a whole number from 0 to" && kMaxFixRounds & "." into tChecked["error"]
      return tChecked
   end if
   put tNumber into tChecked["fixRounds"]
   put word 1 to -1 of field "Timeout" of stack kSettingsWindow into tNumber
   if tNumber is not empty and not (tNumber is an integer and tNumber >= kMinTimeout and tNumber <= kMaxTimeout) then
      put "The wait for an answer is a whole number of seconds, from" && kMinTimeout && "to" && kMaxTimeout & ", or empty." into tChecked["error"]
      return tChecked
   end if
   put tNumber into tChecked["timeout"]
   return tChecked
end xtaSettingsChecked

-- Save: keeps what the dialog holds, for every provider it showed, and
-- closes it; or says what is wrong and keeps it open
on xtaSettingsSave
   local tProvider, tChecked, tOther, tKey, tUrl
   if there is not a stack kSettingsWindow then
      exit xtaSettingsSave
   end if
   put sSettingsProvider into tProvider
   xtaKeepDraft tProvider
   put xtaSettingsChecked() into tChecked
   if tChecked["error"] is not empty then
      xtaSettingsResult tChecked["error"], "bad"
      exit xtaSettingsSave
   end if
   put false into sSettingsFetch
   repeat for each key tOther in tChecked["drafts"]
      put tChecked["drafts"][tOther]["key"] into tKey
      if tKey is not empty and tKey is not sKeys[tOther] then
         put tKey into sKeys[tOther]
         put empty into sModelMenus[tOther]
         if tOther is tProvider then
            put true into sSettingsFetch
         end if
      end if
      put tChecked["drafts"][tOther]["baseUrl"] into tUrl
      if tUrl is not xtaBaseUrl(tOther) then
         revIDESetPreference kPrefBaseUrl & tOther, tUrl
         -- The list was another server's
         put empty into sModelMenus[tOther]
         if tOther is tProvider then
            put true into sSettingsFetch
         end if
      end if
      if sDrafts[tOther]["menu"] is not empty then
         put sDrafts[tOther]["menu"] into sModelMenus[tOther]
      end if
      if tChecked["drafts"][tOther]["model"] is not xtaModel(tOther) then
         revIDESetPreference kPrefModel & tOther, tChecked["drafts"][tOther]["model"]
      end if
   end repeat
   if tProvider is not xtaProvider() then
      revIDESetPreference kPrefProvider, tProvider
      put true into sSettingsFetch
   end if
   -- The list was just asked for with these settings
   if sDrafts[tProvider]["menu"] is not empty then
      put false into sSettingsFetch
   else if xtaModel(tProvider) is empty then
      put true into sSettingsFetch
   end if
   revIDESetPreference kPrefMaxTokens, tChecked["maxTokens"]
   revIDESetPreference kPrefFixRounds, tChecked["fixRounds"] + 0
   revIDESetPreference kPrefTimeout, tChecked["timeout"]
   revIDESetPreference kPrefIncludeScript, the hilite of button "Include" of stack kSettingsWindow
   revIDESetPreference kPrefTools, the hilite of button "Tools" of stack kSettingsWindow
   revIDESetPreference kPrefBuild, the hilite of button "Build" of stack kSettingsWindow
   revIDESetPreference kPrefShortGuide, the hilite of button "Short Guide" of stack kSettingsWindow
   put empty into tChecked
   put true into sSettingsSaved
   close stack kSettingsWindow
end xtaSettingsSave

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
   put xtaModelMenu(tProvider, tResult["models"]) into tModels
   put tModels into sModelMenus[tProvider]
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

-- True when there is a key for the provider, asking the user for one (in
-- the Settings dialog) if needed. A base URL of the user's own (a local
-- server) may need none. The user may switch the provider in the dialog,
-- so the caller reads xtaProvider() again after it.
private function xtaEnsureKey pProvider
   if xtaKey(pProvider) is not empty or xtaBaseUrl(pProvider) is not empty then
      return true
   end if
   if not xtaOpenSettings("Key") then
      return false
   end if
   put xtaProvider() into pProvider
   return xtaKey(pProvider) is not empty or xtaBaseUrl(pProvider) is not empty
end xtaEnsureKey

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
-- with "stack" (the long id of its main stack), "path" (the main stack's
-- file) and "name" (the main stack's name), all empty when there is none,
-- and the last two when it was never saved.
private function xtaWorkStack
   local tEditor, tObject, tStack, tWork, tPath, tName
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
      -- The topStack can be one of the IDE's windows (the Project Browser,
      -- the Dictionary, ...), in front of the user's stack: then the
      -- frontmost open stack that is not (the openStacks lists them from
      -- the front)
      put the topStack into tStack
      if tStack is empty or there is not a tStack or xtaIsIDEStack(tStack) then
         put empty into tStack
         repeat for each line tName in the openStacks
            if there is a stack tName then
               if the visible of stack tName and not xtaIsIDEStack(the long id of stack tName) then
                  put the long id of stack tName into tStack
                  exit repeat
               end if
            end if
         end repeat
      end if
   end if
   if tStack is empty or there is not a tStack then
      return tWork
   end if
   if xtaIsIDEStack(tStack) then
      return tWork
   end if
   -- A substack's owner is its main stack
   if the owner of tStack is empty then
      put the long id of tStack into tWork["stack"]
   else
      put the long id of the owner of tStack into tWork["stack"]
   end if
   put the effective filename of tStack into tPath
   if tPath is empty then
      return tWork
   end if
   put tPath into tWork["path"]
   put the mainStack of tStack into tWork["name"]
   return tWork
end xtaWorkStack

-- True for one of the IDE's stacks, as revIDEStackNameIsIDEStack has it
-- (which this does not call, so that the tests need no IDE)
private function xtaIsIDEStack pStack
   local tName
   put the short name of pStack into tName
   if tName begins with "rev" or tName begins with "com.livecode." then
      return true
   end if
   if tName is among the items of "Message Box,Answer Dialog,Ask Dialog,Home" then
      return true
   end if
   return the _ideoverride of pStack is true
end xtaIsIDEStack

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
-- assistant's and in its look, and deleted when it closes.
private function xtaMemoryDialog pWork, pYou, pStackNotes
   local tOldDefault, tResult, tScript, tTop, tRight
   if there is a stack kMemoryWindow then
      delete stack kMemoryWindow
   end if
   put kMemoryWidth - 16 into tRight
   put the defaultStack into tOldDefault
   lock screen
   lock messages
   create invisible stack kMemoryWindow
   set the defaultStack to kMemoryWindow
   set the resizable of stack kMemoryWindow to false
   set the _ideoverride of stack kMemoryWindow to true
   xtaUiChrome kTitle && "Memory", kMemoryWidth, 480
   put "The notes go to the provider with every question. Notes that look like a key or a password are refused." into field "Status"
   set the dontWrap of field "Status" to false
   set the rect of field "Status" to 16, kUiBand + 4, tRight, kUiBand + 34

   put 72 into tTop
   xtaSettingsSectionIn "Section1", "1  About you", tTop, kMemoryWidth
   xtaUiCap "YouLabel", "For every stack: one note per line.", "16," & tTop & comma & tRight & comma & (tTop + 16)
   put (the bottom of field "YouLabel") + 6 into tTop
   xtaMemoryNotesField "You", 16, tTop, tRight, tTop + 112
   put pYou into field "You"

   put tTop + 124 into tTop
   xtaSettingsSectionIn "Section2", "2  About this stack", tTop, kMemoryWidth
   xtaUiCap "StackLabel", empty, "16," & tTop & comma & tRight & comma & (tTop + 28)
   set the height of field "StackLabel" to 28
   xtaMemoryNotesField "Stack", 16, tTop + 32, tRight, tTop + 144
   if pWork["path"] is empty then
      put "Open a saved stack, or save this one, to keep notes about it." into field "StackLabel"
      set the lockText of field "Stack" to true
      set the enabled of field "Stack" to false
   else
      put "The stack" && quote & pWork["name"] & quote & ", kept with its file's path (never in the stack): one note per line." into field "StackLabel"
      put pStackNotes into field "Stack"
   end if
   put tTop + 156 into tTop

   put "on mouseUp" & return & "   set the cXtaChoice of stack " & quote & kMemoryWindow & quote & " to " & quote & "[[choice]]" & quote & return & \
         "   close stack " & quote & kMemoryWindow & quote & return & "end mouseUp" into tScript
   create button "Forget"
   set the label of button "Forget" to "Forget All..."
   set the rect of button "Forget" to 16, tTop, 126, tTop + 24
   set the script of button "Forget" to replaceText(tScript, "\[\[choice\]\]", "forget")
   create button "Cancel"
   set the rect of button "Cancel" to tRight - 188, tTop, tRight - 98, tTop + 24
   set the script of button "Cancel" to replaceText(tScript, "\[\[choice\]\]", "cancel")
   create button "Save"
   set the rect of button "Save" to tRight - 90, tTop, tRight, tTop + 24
   set the script of button "Save" to replaceText(tScript, "\[\[choice\]\]", "save")
   set the cXtaChoice of stack kMemoryWindow to "cancel"
   xtaUiFooter "Kept in" && quote & kMemoryFile & quote & ", in the preferences folder.", "16," & (tTop + 32) & comma & tRight & comma & (tTop + 50)
   set the height of stack kMemoryWindow to tTop + 58

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

-- A numbered section's header at xTop in a window pWidth wide, which then
-- is where what follows it goes
private command xtaSettingsSectionIn pName, pText, @xTop, pWidth
   xtaUiSection pName, pText, "16," & xTop & comma & (pWidth - 16) & comma & (xTop + 20)
   put (the bottom of graphic (pName & "Line")) + 8 into xTop
end xtaSettingsSectionIn

-- A field of notes, one per line: an entry field of the kit's that wraps
-- and scrolls
private command xtaMemoryNotesField pName, pLeft, pTop, pRight, pBottom
   xtaUiInput pName, pLeft & comma & pTop & comma & pRight & comma & pBottom
   set the dontWrap of field pName to false
   set the vScrollbar of field pName to true
end xtaMemoryNotesField

--------------------------------------------------------------------------------
-- Tools
--
-- What the model may ask the plugin to do while it answers. Five read: the
-- Dictionary, a compile check, the user's stack and where a script of
-- theirs is paused in the debugger (which the user is asked to allow
-- first, since their scripts then go to the provider), and the last error
-- the IDE showed the user. The core makes what they read into text for the
-- model. Two change or run something (xtalkassistant-build.livecodescript
-- does both), and the window's bar asks the user first: make_changes, a
-- batch of changes to a stack, which the user applies or not, every time;
-- and run_code, code to run in a sandbox or on the user's stack, which the
-- user can allow for the session, except code that reaches files, the
-- network or other programs, which is asked about every time.

-- The tools as xtaRequestBody takes them. A backquote in a schema stands
-- for a double quote.
private function xtaTools
   local tTools, tIndex
   put "lookup_dictionary" into tTools[1]["name"]
   put "Looks up an entry of the OXT-Beyond Dictionary: a command, function, property, message, keyword, constant or control structure of LiveCode Script " & \
         "(put, split, topStack, mouseUp, repeat...). Gives its syntax, parameters, description and examples. Look up what you are not sure exists " & \
         "or how it is written before you use it in code, rather than guess." into tTools[1]["description"]
   put "{`type`:`object`,`properties`:{`term`:{`type`:`string`,`description`:`The entry's name alone: topStack, not the topStack`}},`required`:[`term`]}" \
         into tTools[1]["schema"]
   put "check_code" into tTools[2]["name"]
   put "Compiles LiveCode Script on OXT-Beyond's engine as the Script Editor does, without running it, and gives each problem with its line: " & \
         "compile errors, curly quotes, lines outside any handler, a handler defined twice and, in handlers, names never declared. " & \
         "Give whole handlers, or statements (checked inside a handler of their own). Every livecodescript block of your answer is checked " & \
         "anyway; this lets you correct code before you answer with it." into tTools[2]["description"]
   put "{`type`:`object`,`properties`:{`code`:{`type`:`string`,`description`:`The code, as it would be in a script`}},`required`:[`code`]}" \
         into tTools[2]["schema"]
   put "read_stack" into tTools[3]["name"]
   put "Reads the stack the user is working on (that of the script open in the Script Editor, or else the stack in front). With nothing given: " & \
         "an outline of it and its substacks, their cards and their controls with ids and rects, and how long each script is. With an id from " & \
         "the outline, and the stack it is in (ids repeat from stack to stack): that card's or control's properties and script, and a card's " & \
         "controls. With only a stack: that stack's properties, cards and script. The user is asked to allow it the first time; when they do " & \
         "not, go on without it." into tTools[3]["description"]
   put "{`type`:`object`,`properties`:{`stack`:{`type`:`string`,`description`:`The name of the stack or substack, as the outline gives it`}," & \
         "`id`:{`type`:`integer`,`description`:`The id of a card or control, as the outline gives it`}}}" into tTools[3]["schema"]
   put "last_error" into tTools[4]["name"]
   put "Gives the last error the IDE showed the user while the assistant was on: the engine's messages, the object and handler it was in, " & \
         "and the lines of the script around it. Use it when the user asks about an error they hit." into tTools[4]["description"]
   put "{`type`:`object`,`properties`:{}}" into tTools[4]["schema"]
   put "debug_state" into tTools[5]["name"]
   put "Reads where a script of the user's is paused in the debugger (at a breakpoint, or at an error with Script Debug Mode on): the line " & \
         "and handler, the handlers that led there, their variables with their values, and the script around the line. Use it when the user " & \
         "asks about a script that is paused. It only reads: stepping and going on are the user's, in the Script Editor. When nothing is " & \
         "paused it says how the user can pause a script. The user is asked to allow it, as for read_stack." into tTools[5]["description"]
   put "{`type`:`object`,`properties`:{}}" into tTools[5]["schema"]
   put "make_changes" into tTools[6]["name"]
   put "Changes the user's stack, as a batch the user sees and applies or not in the assistant's window: creates controls, cards or a new " & \
         "stack; sets properties, custom properties and scripts; deletes controls or cards. Use it to build or correct what the user asks " & \
         "for, rather than telling them how or giving them code to paste. The batch is checked first, and a mistake (a property the engine " & \
         "does not have, a value it refuses, a script that does not compile) comes back to you with nothing changed, to correct and send " & \
         "again. A batch is applied whole or not at all, with messages locked (none of the user's handlers runs), and the user can undo it. " & \
         "The result gives the ids of what was created. Read the stack first (read_stack) to know its cards, ids and scripts. Each change " & \
         "has an action: create (kind: button, default button, checkbox, radio button, option menu, pulldown menu, popup menu, combo box, " & \
         "tab panel, field, text area, label, list field, table field, rectangle, round rectangle, oval, line, polygon, regular polygon, " & \
         "curve, scrollbar, slider, progress bar, image, player, group, widget (give its widget_kind), card or stack; with name, rect, " & \
         "properties, custom_properties, script, and ref, a word the later changes of the batch can use for it as object, card or group); " & \
         "set (object, and properties, custom_properties or script); or delete (object: a control or a card). A new stack is the first " & \
         "change of its batch, and the rest of the batch is in it; a new card goes after the current card. A script replaces the object's " & \
         "whole script and is made of handlers. Properties are the engine's, by name; a list of numbers is one value ([10, 20] is 10,20)." \
         into tTools[6]["description"]
   put "{`type`:`object`,`properties`:{" & \
         "`stack`:{`type`:`string`,`description`:`The stack or substack to change, by name; empty for the one the user is working on`}," & \
         "`changes`:{`type`:`array`,`description`:`The changes, made in order`,`items`:{`type`:`object`,`properties`:{" & \
         "`action`:{`type`:`string`,`enum`:[`create`,`set`,`delete`]}," & \
         "`kind`:{`type`:`string`,`description`:`create: what to create`}," & \
         "`name`:{`type`:`string`,`description`:`create: its name`}," & \
         "`ref`:{`type`:`string`,`description`:`create: a word the later changes of this batch name it by`}," & \
         "`card`:{`description`:`create: the card to put it on (an id, a ref or a card's name); the current card when none`}," & \
         "`group`:{`description`:`create: the group to put it in (an id or a ref)`}," & \
         "`rect`:{`type`:`array`,`items`:{`type`:`integer`},`description`:`create: left, top, right, bottom`}," & \
         "`widget_kind`:{`type`:`string`,`description`:`create, a widget: its kind, such as com.livecode.widget.svgpath`}," & \
         "`object`:{`description`:`set and delete: an id, a ref, or the word stack for the stack itself`}," & \
         "`properties`:{`type`:`object`,`description`:`Properties of the engine's, by name`}," & \
         "`custom_properties`:{`type`:`object`,`description`:`Custom properties, by name`}," & \
         "`script`:{`type`:`string`,`description`:`The object's whole new script: handlers`}}," & \
         "`required`:[`action`]}}},`required`:[`changes`]}" into tTools[6]["schema"]
   put "run_code" into tTools[7]["name"]
   put "Runs LiveCode Script statements and gives back what they put into the Message Box (put with no container), what they returned, " & \
         "and any error with its line. Use it to try code before you give it to the user or put it in their stack, and to see what a stack " & \
         "does, rather than asking the user to run it in the Message Box. Where: sandbox (the default), a hidden stack made for the run and " & \
         "deleted after it, where the code can call the handlers you give; or stack, the user's stack, as the Message Box runs code there " & \
         "(with the stack's own handlers, me being the card or control given by target, the current card when none), after a checkpoint " & \
         "the user can go back to (on the stack, return gives nothing back: put the value instead). The user is asked first, and always " & \
         "when the code reaches files, the network or other programs. Do not use answer or ask: the run would wait for the user. A run " & \
         "that never ends is stopped only by the user (Control-period)." into tTools[7]["description"]
   put "{`type`:`object`,`properties`:{" & \
         "`code`:{`type`:`string`,`description`:`Statements, as typed into the Message Box`}," & \
         "`where`:{`type`:`string`,`enum`:[`sandbox`,`stack`]}," & \
         "`handlers`:{`type`:`string`,`description`:`sandbox: whole handlers the code can call`}," & \
         "`stack`:{`type`:`string`,`description`:`stack: the stack or substack, by name; empty for the one the user is working on`}," & \
         "`target`:{`type`:`integer`,`description`:`stack: the id of the card or control that is me`}}," & \
         "`required`:[`code`]}" into tTools[7]["schema"]
   repeat with tIndex = 1 to the number of elements of tTools
      replace "`" with quote in tTools[tIndex]["schema"]
   end repeat
   return tTools
end xtaTools

-- The tools to send for this question: none with the short guide (for
-- small local models) or with the tools turned off, or for a model whose
-- server refused them; and those that change or run something only while
-- the Settings let the model do that
private function xtaToolsToSend pProvider
   local tEmpty, tTools, tKept, tIndex, tCount
   if not xtaToolsOn() or sNoTools[pProvider & comma & xtaModel(pProvider)] is true then
      return tEmpty
   end if
   put xtaTools() into tTools
   if xtaBuildOn() then
      return tTools
   end if
   put 0 into tCount
   repeat with tIndex = 1 to the number of elements of tTools
      if tTools[tIndex]["name"] is among the items of kBuildTools then
         next repeat
      end if
      add 1 to tCount
      put tTools[tIndex] into tKept[tCount]
   end repeat
   return tKept
end xtaToolsToSend

-- Whether the model may ask for tools: not with the short guide, nor when
-- the user turned them off in the Settings
private function xtaToolsOn
   return revIDEGetPreference(kPrefShortGuide) is not true and revIDEGetPreference(kPrefTools) is not false
end xtaToolsOn

-- Whether the model may also change stacks and run code (it asks first):
-- with the tools, unless the user turned it off in the Settings
private function xtaBuildOn
   return xtaToolsOn() and revIDEGetPreference(kPrefBuild) is not false
end xtaBuildOn

-- True when an answer that is not one says the server cannot take tools:
-- a local server whose model has none (Ollama), or that was started
-- without them (vLLM, llama.cpp). Only for a server of the user's own: the
-- providers' own APIs take tools, and an error of theirs that names one is
-- a mistake to show.
private function xtaToolsRefused pProvider, pReply
   if xtaBaseUrl(pProvider) is empty then
      return false
   end if
   if pReply["status"] is not among the items of "400,404,422,500,501" then
      return false
   end if
   return pReply["error"] contains "tool"
end xtaToolsRefused

-- Carries out one call the model asked for (pCall, as xtaParseReply gives
-- it). pDeclared are the names the user's open script declares, for the
-- compile check. Returns "text" (for the model), "error" (true when the
-- tool could not do it) and "summary" (one line for the window).
private function xtaRunTool pCall, pDeclared, pProvider
   local tInput, tError, tResult
   try
      put xtaJsonParse(pCall["input"]) into tInput
   catch tError
      put empty into tInput
   end try
   switch pCall["name"]
      case "lookup_dictionary"
         return xtaToolDictionary(xtaJsonText(xtaJsonMember(tInput, "term")))
      case "check_code"
         return xtaToolCheck(xtaJsonText(xtaJsonMember(tInput, "code")), pDeclared)
      case "read_stack"
         return xtaToolReadStack(xtaJsonText(xtaJsonMember(tInput, "stack")), xtaJsonText(xtaJsonMember(tInput, "id")), pProvider)
      case "last_error"
         return xtaToolLastError()
      case "debug_state"
         return xtaToolDebugState(pProvider)
      case "make_changes"
      case "run_code"
         -- Turned off in the Settings since the model was told of them
         if not xtaBuildOn() then
            put "The user has not let the assistant change stacks or run code (in its Settings). Tell them what to do instead, step by step." \
                  into tResult["text"]
            put true into tResult["error"]
            put "Did not use" && pCall["name"] & ": changing stacks and running code are turned off in the Settings" into tResult["summary"]
            return tResult
         end if
         if pCall["name"] is "make_changes" then
            return xtaToolMakeChanges(tInput)
         end if
         return xtaToolRunCode(tInput)
   end switch
   put "There is no tool named" && quote & pCall["name"] & quote & "." into tResult["text"]
   put true into tResult["error"]
   put "Asked for a tool there is not:" && pCall["name"] into tResult["summary"]
   return tResult
end xtaRunTool

private function xtaToolDictionary pTerm
   local tTerm, tEntries, tError, tResult
   put word 1 to -1 of pTerm into tTerm
   if tTerm is empty then
      put "Give the term to look up." into tResult["text"]
      put true into tResult["error"]
      put "Looked up nothing in the Dictionary" into tResult["summary"]
      return tResult
   end if
   xtaStatus "Looking up" && quote & tTerm & quote && "in the Dictionary..."
   try
      put ideDocsFetchLCSData(tTerm) into tEntries
      -- "the topStack" is the entry "topStack"
      if the number of elements of tEntries is 0 and word 1 of tTerm is "the" and the number of words of tTerm > 1 then
         put word 2 to -1 of tTerm into tTerm
         put ideDocsFetchLCSData(tTerm) into tEntries
      end if
   catch tError
      put "The Dictionary cannot be read here." into tResult["text"]
      put true into tResult["error"]
      put "Could not look up" && quote & tTerm & quote && "(the Dictionary cannot be read)" into tResult["summary"]
      return tResult
   end try
   put xtaDictionaryText(tTerm, tEntries) into tResult["text"]
   put false into tResult["error"]
   if the number of elements of tEntries is 0 then
      put "Looked up" && quote & tTerm & quote && "in the Dictionary: no entry" into tResult["summary"]
   else
      put "Looked up" && quote & tTerm & quote && "in the Dictionary" into tResult["summary"]
   end if
   return tResult
end xtaToolDictionary

private function xtaToolCheck pCode, pDeclared
   local tCheck, tResult, tLine
   if word 1 to -1 of pCode is empty then
      put "Give the code to check." into tResult["text"]
      put true into tResult["error"]
      put "Checked no code" into tResult["summary"]
      return tResult
   end if
   xtaStatus "Checking code..."
   put xtaCheckScript(pCode, pDeclared) into tCheck
   put false into tResult["error"]
   if tCheck["ok"] is true then
      put "The code compiles on OXT-Beyond's engine. That is not the same as doing what was asked." into tResult["text"]
      put "Checked code: it compiles" into tResult["summary"]
   else
      put "The code does not compile on OXT-Beyond's engine:" into tResult["text"]
      repeat for each line tLine in tCheck["issues"]
         put return & "- " & tLine after tResult["text"]
      end repeat
      put "Checked code: it does not compile" into tResult["summary"]
   end if
   return tResult
end xtaToolCheck

-- The user's stack: an outline, or one stack, card or control (pStackName
-- and pId as the outline gives them). The first time for a stack, the user
-- is asked to allow it.
private function xtaToolReadStack pStackName, pId, pProvider
   local tWork, tMain, tName, tPassword, tError, tStack, tObject, tSub, tResult
   put xtaWorkStack() into tWork
   put tWork["stack"] into tMain
   if tMain is empty or there is not a tMain then
      put "The user has no stack of their own open." into tResult["text"]
      put true into tResult["error"]
      put "Found no stack to read" into tResult["summary"]
      return tResult
   end if
   put the short name of tMain into tName
   -- A password-protected stack's scripts are not sent (as with the open
   -- script, xtaScriptContext)
   put "protected" into tPassword
   try
      put the password of tMain into tPassword
   catch tError
   end try
   if tPassword is not empty then
      put "The stack" && quote & tName & quote && "is password-protected, so it is not read." into tResult["text"]
      put true into tResult["error"]
      put "Did not read the stack" && quote & tName & quote & ": it is password-protected" into tResult["summary"]
      return tResult
   end if
   if not xtaReadAllowed(tMain, pProvider) then
      put "The user did not allow reading the stack" && quote & tName & quote & ". Go on without it, and say what you would need to know." into tResult["text"]
      put true into tResult["error"]
      put "Not allowed to read the stack" && quote & tName & quote into tResult["summary"]
      return tResult
   end if

   -- The stack asked for: the main stack, or one of its substacks
   put tMain into tStack
   if word 1 to -1 of pStackName is not empty and word 1 to -1 of pStackName is not tName then
      put empty into tStack
      repeat for each line tSub in the substacks of tMain
         if tSub is word 1 to -1 of pStackName then
            put the long id of stack tSub of tMain into tStack
            exit repeat
         end if
      end repeat
      if tStack is empty then
         put "The stack" && quote & tName & quote && "has no substack" && quote & pStackName & quote & ". Its substacks:" && \
               the substacks of tMain into tResult["text"]
         replace return with ", " in tResult["text"]
         put true into tResult["error"]
         put "Looked for a substack" && quote & pStackName & quote && "that is not there" into tResult["summary"]
         return tResult
      end if
   end if
   xtaStatus "Reading the stack" && quote & tName & quote & "..."
   if pId is empty then
      if word 1 to -1 of pStackName is empty then
         put xtaStackOutline(tMain) into tResult["text"]
         put "Read the outline of the stack" && quote & tName & quote into tResult["summary"]
      else
         put xtaObjectText(tStack) into tResult["text"]
         put "Read the stack" && quote & the short name of tStack & quote into tResult["summary"]
      end if
      put false into tResult["error"]
      return tResult
   end if
   if pId is not an integer then
      put "An id is a whole number, as the outline gives it." into tResult["text"]
      put true into tResult["error"]
      put "Asked for an object by a wrong id" into tResult["summary"]
      return tResult
   end if
   if there is a card id pId of tStack then
      put the long id of card id pId of tStack into tObject
   else if there is a control id pId of tStack then
      put the long id of control id pId of tStack into tObject
   end if
   if tObject is empty then
      put "The stack" && quote & the short name of tStack & quote && "has no card or control with the id" && pId & "." into tResult["text"]
      put true into tResult["error"]
      put "Looked for the id" && pId && "that is not in the stack" && quote & the short name of tStack & quote into tResult["summary"]
      return tResult
   end if
   put xtaObjectText(tObject) into tResult["text"]
   put false into tResult["error"]
   put "Read" && the name of tObject && "of the stack" && quote & the short name of tStack & quote into tResult["summary"]
   return tResult
end xtaToolReadStack

private function xtaToolLastError
   local tError, tResult
   put xtaLastError() into tError
   if tError is empty then
      put "The IDE has shown the user no error since the assistant was turned on." into tResult["text"]
      put "Read the last error: there is none" into tResult["summary"]
   else
      put tError["text"] into tResult["text"]
      put "Read the last error, in" && tError["name"] into tResult["summary"]
   end if
   put false into tResult["error"]
   return tResult
end xtaToolLastError

-- debug_state: where a script of the user's is paused. It reads their
-- scripts and what the paused handlers hold, so it is asked about as
-- reading the stack is. With an error the IDE showed (Script Debug Mode
-- pauses at an error), the error goes with it.
private function xtaToolDebugState pProvider
   local tState, tError, tResult
   xtaStatus "Reading the debugger..."
   put xtaDebugState() into tState
   if tState["paused"] is not true then
      put tState["text"] && "To pause a script, the user sets a breakpoint (a click left of a line in the Script Editor) and runs the script, " & \
            "or turns on Script Debug Mode (Development menu) and lets it stop at an error." into tResult["text"]
      put false into tResult["error"]
      put tState["summary"] into tResult["summary"]
      return tResult
   end if
   if not xtaReadAllowed(tState["stack"], pProvider) then
      put "The user did not allow reading the stack" && quote & the short name of tState["stack"] & quote & \
            ", where the script is paused. Go on without it, and say what you would need to know." into tResult["text"]
      put true into tResult["error"]
      put "Not allowed to read the stack" && quote & the short name of tState["stack"] & quote into tResult["summary"]
      return tResult
   end if
   put tState["text"] into tResult["text"]
   put xtaLastError() into tError
   if tError is not empty then
      put return & return & tError["text"] after tResult["text"]
   end if
   put false into tResult["error"]
   put tState["summary"] into tResult["summary"]
   return tResult
end xtaToolDebugState

-- make_changes: the batch is checked, shown in the window's bar, and
-- applied only when the user presses Apply. A batch with mistakes goes
-- back to the model without asking the user.
private function xtaToolMakeChanges pInput
   local tWork, tPlan, tWhat, tTitle, tAnswer, tApplied, tResult
   put xtaWorkStack() into tWork
   xtaStatus "Checking the changes the model asks for..."
   put xtaBuildPlan(pInput, tWork["stack"]) into tPlan
   if tPlan["ok"] is not true then
      put "Nothing was changed: the batch has mistakes. Correct them, then send the whole batch again." & return & tPlan["problems"] \
            into tResult["text"]
      put true into tResult["error"]
      put "Proposed changes that need correcting first" into tResult["summary"]
      return tResult
   end if
   if tPlan["newStack"] is true then
      put "a new stack" && quote & tPlan["name"] & quote into tWhat
   else
      put "the stack" && quote & tPlan["name"] & quote into tWhat
   end if
   if tPlan["count"] is 1 then
      put "Apply this change to" && tWhat & "?" into tTitle
   else
      put "Apply these" && tPlan["count"] && "changes to" && tWhat & "?" into tTitle
   end if
   put xtaAskUser("changes", tTitle, tPlan["lines"] & return & return & "Undo, in the conversation, takes them back.", "Apply", empty, "Don't Apply") \
         into tAnswer
   if tAnswer is "stop" then
      put "Nothing was changed: the user pressed Stop." into tResult["text"]
      put true into tResult["error"]
      put "Did not apply the changes: you pressed Stop" into tResult["summary"]
      return tResult
   end if
   if tAnswer is not "yes" then
      put "The user chose not to apply these changes, and nothing was changed. Ask them what they would like instead; do not send the same batch again." \
            into tResult["text"]
      put true into tResult["error"]
      put "You chose not to apply the changes to" && tWhat into tResult["summary"]
      return tResult
   end if
   xtaStatus "Applying the changes..."
   put xtaBuildApply(tPlan) into tApplied
   if tApplied["ok"] is not true then
      put tApplied["error"] into tResult["text"]
      put true into tResult["error"]
      put "Could not apply the changes:" && line 1 of tApplied["error"] into tResult["summary"]
      return tResult
   end if
   put tApplied["text"] into tResult["text"]
   put false into tResult["error"]
   put tApplied["summary"] into tResult["summary"]
   put tApplied["entry"] into tResult["entry"]
   put tPlan["lines"] into tResult["lines"]
   xtaRefreshMoreMenu
   return tResult
end xtaToolMakeChanges

-- run_code: the code is checked and shown in the window's bar, and runs
-- when the user presses Run, or at once where they allowed runs for the
-- session (the sandbox, or a stack); code that reaches what cannot be
-- undone (files, the network, other programs...) is asked about every
-- time. A run on a stack is saved as a checkpoint first, which Undo goes
-- back to.
private function xtaToolRunCode pInput
   local tWork, tRun, tPlace, tTitle, tDetail, tSession, tAnswer, tRan, tResult, tRisks
   put xtaWorkStack() into tWork
   xtaStatus "Checking the code the model asks to run..."
   put xtaRunPlan(pInput, tWork["stack"]) into tRun
   if tRun["ok"] is not true then
      put "Nothing ran:" && tRun["problems"] into tResult["text"]
      put true into tResult["error"]
      put "Proposed code to run that needs correcting first" into tResult["summary"]
      return tResult
   end if
   if tRun["where"] is "sandbox" then
      put "sandbox" into tPlace
   else
      put xtaMainStackOf(tRun["stack"]) into tPlace
   end if
   if sRunAllowed[tPlace] is not true or tRun["risks"] is not empty then
      if tRun["where"] is "sandbox" then
         put "Run this code in a sandbox?" into tTitle
         put "It runs in a hidden stack made for the run, and deleted after it." into tDetail
         put "Allow in the Sandbox" into tSession
      else
         put "Run this code on the stack" && quote & the short name of tPlace & quote & "?" into tTitle
         put tRun["label"] & ". A copy of the stack is saved first, and Undo, in the conversation, goes back to it." into tDetail
         put "Allow on This Stack" into tSession
      end if
      if tRun["risks"] is not empty then
         put tRun["risks"] into tRisks
         replace return with ", " in tRisks
         put "Careful: it uses" && tRisks & ", and what it does there cannot be undone." & return & tDetail into tDetail
         -- Asked about every time
         put empty into tSession
      end if
      put return & return & tRun["code"] after tDetail
      if tRun["handlers"] is not empty then
         put return & return & "-- With these handlers:" & return & tRun["handlers"] after tDetail
      end if
      put xtaAskUser("run", tTitle, tDetail, "Run", tSession, "Don't Run") into tAnswer
      if tAnswer is "stop" then
         put "Nothing ran: the user pressed Stop." into tResult["text"]
         put true into tResult["error"]
         put "Did not run the code: you pressed Stop" into tResult["summary"]
         return tResult
      end if
      if tAnswer is not "yes" and tAnswer is not "session" then
         put "The user chose not to run this code, and nothing ran. Ask them what they would like instead; do not send the same code again." \
               into tResult["text"]
         put true into tResult["error"]
         put "You chose not to run the code" into tResult["summary"]
         return tResult
      end if
      if tAnswer is "session" then
         put true into sRunAllowed[tPlace]
      end if
   end if
   xtaStatus "Running the code... (" & xtaInterruptKeys() && "stops it)"
   put xtaRunCode(tRun) into tRan
   put tRan["text"] into tResult["text"]
   put (tRan["ok"] is not true) into tResult["error"]
   put tRan["summary"] into tResult["summary"]
   put tRan["entry"] into tResult["entry"]
   if tRan["entry"] is not empty then
      xtaRefreshMoreMenu
   end if
   return tResult
end xtaToolRunCode

-- The keys that stop a running script: the engine's interrupt
private function xtaInterruptKeys
   if the platform is "MacOS" then
      return "Command-period"
   end if
   return "Control-period"
end xtaInterruptKeys

-- The long id of the main stack of pStack (a long id)
private function xtaMainStackOf pStack
   if the owner of pStack is empty then
      return the long id of pStack
   end if
   return the long id of the owner of pStack
end xtaMainStackOf

-- True when the user lets the model read the stack pMain (the long id of
-- a main stack): its scripts then go to the provider. Asked in the
-- window's bar the first time, then allowed until the assistant is turned
-- off; Don't Allow holds until the next question.
private function xtaReadAllowed pMain, pProvider
   local tName, tAnswer
   if sReadAllowed[pMain] is true then
      return true
   end if
   if sReadRefused[pMain] is true then
      return false
   end if
   put the short name of pMain into tName
   put xtaAskUser("read", "Let the assistant read your stack" && quote & tName & quote & "?", \
         "It reads the stack's cards and controls, their properties and their scripts, and what a paused script holds. What it reads goes to" && \
         xtaProviderName(pProvider) && "with this question and the ones after it, until you turn the assistant off.", "Allow", empty, "Don't Allow") \
         into tAnswer
   if tAnswer is "yes" then
      put true into sReadAllowed[pMain]
      return true
   end if
   if tAnswer is "no" then
      put true into sReadRefused[pMain]
   end if
   return false
end xtaReadAllowed

--------------------------------------------------------------------------------
-- The bar that asks the user
--
-- What the assistant asks while it answers (apply these changes, run this
-- code, read this stack) is asked in a bar in its window, above the
-- prompt, rather than in a dialog: the user can read the conversation
-- and scroll the details before answering, and Stop answers it too.

-- Shows the bar and waits for the answer, which a click on one of its
-- buttons gives (xtaAnswerAsk): "yes", "session" (yes, and do not ask
-- again this session) or "no"; or "stop" when the user pressed Stop,
-- closed the window or turned the assistant off. pKind is what is asked
-- ("changes", "run" or "read"); pSession is the label of the button that
-- allows it for the session, empty for none.
private function xtaAskUser pKind, pTitle, pDetail, pYes, pSession, pNo
   local tShutDowns, tAnswer
   if there is not a stack kWindow or sStopAsked is true then
      return "stop"
   end if
   put pKind into sAsk["kind"]
   put empty into sAsk["answer"]
   xtaShowAsk pTitle, pDetail, pYes, pSession, pNo
   put sShutDowns into tShutDowns
   repeat while sAsk["answer"] is empty
      if sShutDowns is not tShutDowns or there is not a stack kWindow or sStopAsked is true then
         put "stop" into sAsk["answer"]
         exit repeat
      end if
      wait 50 milliseconds with messages
   end repeat
   put sAsk["answer"] into tAnswer
   put empty into sAsk
   if sShutDowns is tShutDowns then
      xtaHideAsk
   end if
   return tAnswer
end xtaAskUser

private command xtaShowAsk pTitle, pDetail, pYes, pSession, pNo
   lock screen
   lock messages
   set the text of field "AskTitle" of stack kWindow to pTitle
   set the text of field "AskDetail" of stack kWindow to pDetail
   set the label of button "AskYes" of stack kWindow to pYes
   set the label of button "AskSession" of stack kWindow to pSession
   set the label of button "AskNo" of stack kWindow to pNo
   set the visible of graphic "AskPanel" of stack kWindow to true
   set the visible of field "AskTitle" of stack kWindow to true
   set the visible of field "AskDetail" of stack kWindow to true
   set the visible of button "AskYes" of stack kWindow to true
   set the visible of button "AskSession" of stack kWindow to (pSession is not empty)
   set the visible of button "AskNo" of stack kWindow to true
   unlock messages
   dispatch "xtawRelayout" to stack kWindow
   lock messages
   set the vScroll of field "AskDetail" of stack kWindow to 0
   unlock messages
   xtaPaintPill
   xtaStatus "Waiting for your answer, below the conversation.", "warn"
   unlock screen
end xtaShowAsk

private command xtaHideAsk
   local tName
   if there is not a stack kWindow then
      exit xtaHideAsk
   end if
   lock screen
   lock messages
   set the visible of graphic "AskPanel" of stack kWindow to false
   set the visible of field "AskTitle" of stack kWindow to false
   set the visible of field "AskDetail" of stack kWindow to false
   repeat for each item tName in "AskYes,AskSession,AskNo"
      set the visible of button tName of stack kWindow to false
   end repeat
   unlock messages
   dispatch "xtawRelayout" to stack kWindow
   xtaPaintPill
   unlock screen
end xtaHideAsk

-- A button of the bar: "yes", "session" or "no"
on xtaAnswerAsk pAnswer
   if sAsk["kind"] is empty or sAsk["answer"] is not empty then
      exit xtaAnswerAsk
   end if
   if pAnswer is among the items of "yes,session,no" then
      put pAnswer into sAsk["answer"]
   end if
end xtaAnswerAsk

--------------------------------------------------------------------------------
-- Undo
--
-- What the assistant changed, and the runs on a stack, are a journal (the
-- library's) until the assistant is turned off. Undo, after an entry in
-- the conversation, takes it back, and what was applied to the same stack
-- after it, newest first; More > Undo All Changes... takes back all of it.
-- The model is told with the next question.

-- A link of the conversation: Undo, Remember or Dismiss
on xtaConversationLink pLink
   switch item 1 of pLink
      case "undo"
         xtaUndoEntry item 2 of pLink
         break
      case "remember"
      case "dismiss"
         xtaNoteClicked pLink
         break
   end switch
end xtaConversationLink

-- True while the library that changes and runs is loaded (from when the
-- window is first opened until the assistant is turned off)
private function xtaBuildLoaded
   if there is not a stack kBuild then
      return false
   end if
   return the long id of stack kBuild is among the lines of xtaStacksInUse()
end xtaBuildLoaded

-- How many sets of changes, and runs on a stack, can be undone
private function xtaAppliedCount
   local tEntries, tIndex, tCount
   put 0 into tCount
   if not xtaBuildLoaded() then
      return tCount
   end if
   put xtaBuildEntries() into tEntries
   repeat with tIndex = 1 to the number of elements of tEntries
      if tEntries[tIndex]["state"] is "applied" then
         add 1 to tCount
      end if
   end repeat
   return tCount
end xtaAppliedCount

private command xtaRefreshMoreMenu
   if there is a stack kWindow then
      lock messages
      set the text of button "More" of stack kWindow to xtaMoreMenuText()
      unlock messages
   end if
end xtaRefreshMoreMenu

-- Undo, after an entry in the conversation. When the user changed some of
-- it since, they are asked first: it goes back as it was before the
-- assistant changed it, and what they changed goes too.
private command xtaUndoEntry pEntry
   local tResult
   if not xtaBuildLoaded() or pEntry is not an integer then
      exit xtaUndoEntry
   end if
   put xtaBuildUndo(pEntry, false) into tResult
   if tResult["changed"] is not empty then
      answer question "You have changed some of this since the assistant did it:" & return & tResult["changed"] & return & return & \
            "Undo puts it back as it was before, and what you changed goes too." with "Cancel" or "Undo Anyway" titled kTitle
      if it is not "Undo Anyway" then
         exit xtaUndoEntry
      end if
      put xtaBuildUndo(pEntry, true) into tResult
   end if
   xtaUndone tResult
end xtaUndoEntry

-- More > Undo All Changes...
private command xtaUndoAll
   local tCount, tResult
   put xtaAppliedCount() into tCount
   if tCount is 0 then
      xtaStatus "There is nothing to undo."
      exit xtaUndoAll
   end if
   if tCount is 1 then
      answer question "Undo what the assistant did to your stack? It goes back as it was before." with "Cancel" or "Undo All" titled kTitle
   else
      answer question "Undo all that the assistant did to your stacks:" && tCount && "sets of changes and runs, the newest first? They go back as they were before." \
            with "Cancel" or "Undo All" titled kTitle
   end if
   if it is not "Undo All" then
      exit xtaUndoAll
   end if
   put xtaBuildUndoAll(false) into tResult
   if tResult["changed"] is not empty then
      answer question "You have changed some of it since the assistant did it:" & return & tResult["changed"] & return & return & \
            "Undo puts it back as it was before, and what you changed goes too." with "Cancel" or "Undo Anyway" titled kTitle
      if it is not "Undo Anyway" then
         exit xtaUndoAll
      end if
      put xtaBuildUndoAll(true) into tResult
   end if
   xtaUndone tResult
end xtaUndoAll

-- After Undo: the window shows what is undone, and what was undone goes
-- to the model with the next question
private command xtaUndone pResult
   local tEntries, tIndex
   if pResult["undone"] is not empty then
      put xtaBuildEntries() into tEntries
      repeat for each line tIndex in pResult["undone"]
         put "- " & tEntries[tIndex]["summary"] & return after sUndone
      end repeat
   end if
   xtaShowConversation
   xtaRefreshMoreMenu
   if pResult["undone"] is empty then
      xtaStatus pResult["error"], "bad"
   else if pResult["error"] is not empty then
      xtaStatus "Undone, but not all of it.", "bad"
      answer warning "Some of it could not be undone:" & return & pResult["error"] titled kTitle
   else
      xtaStatus pResult["summary"] & ".", "ok"
   end if
end xtaUndone

-- The newest error the error hook noted that was in a script of the user's
-- (not one of the IDE's): an array with "text" (for the model: the engine's
-- messages, then the lines of the script around the error, when the script
-- can be read) and "name" (the object, for the user), or empty when there
-- is none
private function xtaLastError
   local tErrors, tIndex, tFound, tWhere, tObject, tStack, tName, tScript, tExcerpt, tPassword, tError, tResult
   if there is not a stack kErrorHook then
      return empty
   end if
   dispatch function "xtaErrorHookErrors" to stack kErrorHook
   put the result into tErrors
   put false into tFound
   repeat with tIndex = the number of elements of tErrors down to 1
      put xtaErrorWhere(tErrors[tIndex]["trace"]) into tWhere
      put tWhere["object"] into tObject
      if tObject is empty then
         put tErrors[tIndex]["target"] into tObject
      end if
      put empty into tStack
      try
         if tObject is not empty and there is a tObject then
            put xtaStackOfObject(the long id of tObject) into tStack
         end if
      catch tError
         put empty into tStack
      end try
      if tStack is not empty then
         if xtaIsIDEStack(tStack) then
            next repeat
         end if
      end if
      put true into tFound
      exit repeat
   end repeat
   if not tFound then
      return empty
   end if
   if tStack is empty then
      -- The object is gone: the error as it was reported
      put tObject into tName
   else
      put the name of tObject && "of stack" && quote & the short name of tStack & quote into tName
   end if
   put "The last error the IDE showed the user (" & the seconds - tErrors[tIndex]["seconds"] && "seconds ago), as the engine reported it:" & return & \
         xtaErrorText(tErrors[tIndex]["trace"]) into tResult["text"]
   if tStack is not empty and tWhere["line"] is not empty then
      put "protected" into tPassword
      try
         put the password of tStack into tPassword
         if tPassword is empty and the owner of tStack is not empty then
            put the password of the owner of tStack into tPassword
         end if
         if tPassword is empty then
            put the script of tObject into tScript
         end if
      catch tError
         put empty into tScript
      end try
      put xtaScriptExcerpt(tScript, tWhere["line"]) into tExcerpt
      if tExcerpt is not empty then
         put return & "The script of" && tName & ", around line" && tWhere["line"] & ":" & return & tExcerpt after tResult["text"]
      end if
   end if
   put tName into tResult["name"]
   return tResult
end xtaLastError

-- The stack an object is in, from its long id (which ends with the stack;
-- for a control of a substack, "... of stack "Sub" of stack "Main"")
private function xtaStackOfObject pObject
   local tAt
   if word 1 of pObject is "stack" then
      return pObject
   end if
   put offset(" of stack ", pObject) into tAt
   if tAt is 0 then
      return empty
   end if
   return char tAt + 4 to -1 of pObject
end xtaStackOfObject

--------------------------------------------------------------------------------
-- Asking

on xtaNewConversation
   if sBusy is true then
      exit xtaNewConversation
   end if
   put empty into sTurns
   put empty into sLastCode
   put empty into sUndone
   xtaRefreshWindow
end xtaNewConversation

-- More > Explain the Last Error: asks about the last error the IDE showed
-- the user, sent with the question (what the prompt holds, or else a
-- question of its own)
private command xtaExplainLastError
   local tError
   if sBusy is true or there is not a stack kWindow then
      exit xtaExplainLastError
   end if
   put xtaLastError() into tError
   if tError is empty then
      answer information "The IDE has shown no error in your scripts since the xTalk Assistant was turned on." titled kTitle
      exit xtaExplainLastError
   end if
   if word 1 to -1 of field "Prompt" of stack kWindow is empty then
      put "Explain the last error I hit, and how to fix it." into field "Prompt" of stack kWindow
   end if
   xtaSendPrompt tError["text"], tError["name"]
end xtaExplainLastError

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
-- the answer. pAttach, when given, goes with the question (the last error,
-- for Explain the Last Error), and the window says so with pAttachName.
-- The model may ask for tools as it answers (xtaRunTool), up to
-- kMaxToolCalls for the question; their results go back to it and it goes
-- on. Every xTalk block of an answer is compiled; one that does not compile
-- goes back to the model with the errors, as a turn of the conversation the
-- user sees ("Compile check"), until the code compiles, the fix rounds are
-- used up, the model sends the same code again or none, or the user presses
-- Stop.
on xtaSendPrompt pAttach, pAttachName
   local tPrompt, tProvider, tCount, tContext, tReply, tStatus, tShutDowns
   local tWork, tSystem, tDeclared, tRound, tRounds, tBlocks, tCheck, tLastCode
   local tIn, tOut, tCached, tAnswered, tError, tTools, tCalls, tCall, tResults
   local tToolCalls, tRefusals, tRefusedNow, tSpent, tKind
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
   put xtaProvider() into tProvider
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
   if pAttach is not empty then
      put pAttach into sTurns[tCount]["attach"]
      put pAttachName into sTurns[tCount]["attachName"]
   end if
   -- What the user undid since the last question: the model goes by what
   -- the tools told it, and the objects are gone
   if sUndone is not empty then
      put sUndone into sTurns[tCount]["undone"]
      put empty into sUndone
   end if
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
   -- A stack the user would not let the model read is asked about again
   -- with the next question
   put empty into sReadRefused
   xtaShowConversation
   xtaUpdateButtons

   put xtaFixRounds() into tRounds
   put xtaToolsToSend(tProvider) into tTools
   put 0 into tRound
   put 0 into tToolCalls
   put 0 into tRefusals
   put false into tSpent
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
      put xtaAsk(xtaSettings(), tSystem, xtaTurnsToSend(), tTools) into tReply
      if sShutDowns is not tShutDowns then
         exit xtaSendPrompt
      end if
      if tReply["ok"] is not true then
         -- A server of the user's own whose model cannot take tools: asked
         -- again without them, and so until the assistant is turned off
         if tTools is not empty and xtaToolsRefused(tProvider, tReply) then
            put true into sNoTools[tProvider & comma & xtaModel(tProvider)]
            put empty into tTools
            next repeat
         end if
         exit repeat
      end if
      add tReply["inputTokens"] to tIn
      add tReply["outputTokens"] to tOut
      add tReply["cachedTokens"] to tCached
      put empty into tCalls
      if tTools is not empty then
         put tReply["calls"] into tCalls
      end if
      put the number of elements of sTurns + 1 into tCount
      put "assistant" into sTurns[tCount]["role"]
      put tReply["text"] into sTurns[tCount]["text"]
      if the number of elements of tCalls > 0 then
         put tCalls into sTurns[tCount]["calls"]
      end if
      put xtaMemoryProposals(tReply["text"]) into sTurns[tCount]["notes"]
      put sTurns[tCount - 1]["stackPath"] into sTurns[tCount]["stackPath"]
      put sTurns[tCount - 1]["stackName"] into sTurns[tCount]["stackName"]
      -- Insert takes the code of the latest answer, or none when it has
      -- none; an answer that only asks for tools leaves it as the answers
      -- to this question had it
      put xtaXTalkBlocks(xtaCodeBlocks(tReply["text"])) into tBlocks
      if the number of elements of tCalls is 0 or the number of elements of tBlocks > 0 or not tAnswered then
         put tBlocks into sLastCode
      end if
      put true into tAnswered

      if the number of elements of tCalls > 0 then
         xtaShowConversation
         put empty into tResults
         put false into tRefusedNow
         repeat with tCall = 1 to the number of elements of tCalls
            if sStopAsked is true then
               put "Not run: the user pressed Stop." into tResults[tCall]["text"]
               put true into tResults[tCall]["error"]
               put "Did not use" && tCalls[tCall]["name"] & ": you pressed Stop" into tResults[tCall]["summary"]
            else if tToolCalls >= kMaxToolCalls then
               put "Not run: you have used the" && kMaxToolCalls && "tools you may use for one question. Answer with what you have." into tResults[tCall]["text"]
               put true into tResults[tCall]["error"]
               put "Did not use" && tCalls[tCall]["name"] & ": the" && kMaxToolCalls && "tool uses of a question are used up" into tResults[tCall]["summary"]
               put true into tRefusedNow
            else
               add 1 to tToolCalls
               put xtaRunTool(tCalls[tCall], tDeclared, tProvider) into tResults[tCall]
               -- A tool can ask the user, and the assistant can be turned
               -- off meanwhile
               if sShutDowns is not tShutDowns then
                  exit xtaSendPrompt
               end if
            end if
         end repeat
         put the number of elements of sTurns + 1 into tCount
         put "user" into sTurns[tCount]["role"]
         put "tools" into sTurns[tCount]["kind"]
         put tResults into sTurns[tCount]["results"]
         put sTurns[tCount - 1]["stackPath"] into sTurns[tCount]["stackPath"]
         put sTurns[tCount - 1]["stackName"] into sTurns[tCount]["stackName"]
         xtaShowConversation
         if sStopAsked is true or there is not a stack kWindow then
            exit repeat
         end if
         -- Told its tools are used up, the model has one answer more to
         -- answer without them
         if tRefusedNow then
            add 1 to tRefusals
            if tRefusals > 1 then
               put true into tSpent
               exit repeat
            end if
         end if
         next repeat
      end if

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
      -- answer before it stays. The results of tools stay, as their calls
      -- did: the next question sends them.
      put the number of elements of sTurns into tCount
      if sTurns[tCount]["kind"] is not "tools" then
         -- What the user undid goes with the next question instead
         if sTurns[tCount]["undone"] is not empty then
            put sTurns[tCount]["undone"] before sUndone
         end if
         delete variable sTurns[tCount]
      end if
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
      put empty into tKind
      put xtaProviderName(tProvider) && "-" && xtaModel(tProvider) into tStatus
      if tIn > 0 or tOut > 0 then
         put " -" && tIn && "tokens in," && tOut && "out" after tStatus
         if tCached > 0 then
            put " (" & tCached && "read from the cache)" after tStatus
         end if
      end if
      if tReply["stop"] is "max_tokens" or tReply["stop"] is "length" then
         put " - the answer was cut off at its length limit" after tStatus
         put "warn" into tKind
      end if
      if tSpent then
         put " - stopped: the model used up its tools for this question" after tStatus
         put "warn" into tKind
      end if
      if tCheck["summary"] is not empty and tCheck["ok"] is not true then
         put " - the code does not compile" after tStatus
         put "warn" into tKind
      end if
      xtaStatus tStatus, tKind
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
-- question; what else went with a question (the last error) stays with it.
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
      put sTurns[tIndex]["kind"] into tTurns[tIndex]["kind"]
      put sTurns[tIndex]["calls"] into tTurns[tIndex]["calls"]
      put sTurns[tIndex]["results"] into tTurns[tIndex]["results"]
      if sTurns[tIndex]["attach"] is not empty then
         put return & return & sTurns[tIndex]["attach"] after tTurns[tIndex]["text"]
      end if
      if sTurns[tIndex]["undone"] is not empty then
         put return & return & "(Since your last answer I undid what follows, so it is no longer in the stack. Read the stack again before you change it.)" & \
               return & sTurns[tIndex]["undone"] after tTurns[tIndex]["text"]
      end if
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
