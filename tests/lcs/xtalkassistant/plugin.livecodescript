script "TestXTalkAssistantPlugin"
-- OXT-Beyond: tests of the xTalk Assistant plugin's main stack
-- (ide/Extensions/org.openxtalk.plugin.xtalkassistant/xtalkassistant.livecodescript),
-- loaded as the IDE loads an extension, with a stand-in for the IDE
-- handlers it calls: that it stays off and loads nothing until it is turned
-- on, that the window it builds asks a server of this process (answering as
-- Anthropic does) and shows the answer, that the guide and the user's notes
-- go with every question, that code that does not compile goes back to the
-- model and stops when it compiles or the rounds run out, that only xTalk
-- can be inserted, that a note the answer proposes is kept only when the
-- user presses Remember, that the key never becomes a preference, and that
-- unloading it takes everything away again. The dialogs (turning it on,
-- typing a key, errors, the Memory window) and the Script Editor are not
-- reached here: they need the IDE.

constant kMain = "org.openxtalk.plugin.xtalkassistant"
constant kWindow = "revXTalkAssistant"
constant kCore = "org.openxtalk.plugin.xtalkassistant-core"

-- The test server's answers (keys 1 to N, one for each request, the last
-- for any after it), how many requests it has read, the latest request, and
-- every request by number
local sResponses, sServed, sRequest, sRequests
-- The preferences folder of the stand-in IDE
local sPrefsFolder

on TestSetup
   local tLibUrl, tStub
   put specialFolderPath("temporary") & "/xta-test-prefs-" & the milliseconds into sPrefsFolder
   create folder sPrefsFolder
   if not TestIsInStandalone() then
      put TestGetEngineRepositoryPath() & "/ide-support/revliburl.livecodescript" into tLibUrl
      send "extensionInitialize" to stack tLibUrl
   end if
   -- The IDE's handlers the plugin calls: the preferences, kept in memory
   -- here so that a test can read them all, and no Script Editor
   put "local sPrefs" & return & \
         "function revIDEGetPreference pName" & return & "return sPrefs[pName]" & return & "end revIDEGetPreference" & return & \
         "on revIDESetPreference pName, pValue" & return & "put pValue into sPrefs[pName]" & return & "end revIDESetPreference" & return & \
         "function xtaTestPrefs" & return & "return sPrefs" & return & "end xtaTestPrefs" & return & \
         "function revTopMostScriptEditor" & return & "return empty" & return & "end revTopMostScriptEditor" & return & \
         "function revEnvironmentUserPreferencesPath" & return & "return " & quote & sPrefsFolder & quote & return & \
         "end revEnvironmentUserPreferencesPath" into tStub
   create invisible stack "xtaTestIDE"
   set the script of stack "xtaTestIDE" to tStub
   start using stack "xtaTestIDE"
   put empty into $OXTBEYOND_XTALK_ASSISTANT
   put empty into $ANTHROPIC_API_KEY
   put empty into $OPENAI_API_KEY
   -- As revInternal__LoadLibrary loads an extension: the stack is loaded
   -- and sent extensionInitialize, and is not put in the message path
   get the short name of stack (TestGetIDERepositoryPath() & "/Extensions/org.openxtalk.plugin.xtalkassistant/xtalkassistant.livecodescript")
   send "extensionInitialize" to stack kMain
end TestSetup

on TestTeardown
   if there is a file (sPrefsFolder & "/xTalk Assistant Memory.txt") then
      delete file (sPrefsFolder & "/xTalk Assistant Memory.txt")
   end if
   if there is a folder sPrefsFolder then
      delete folder sPrefsFolder
   end if
end TestTeardown

private function TestIsEnabled
   dispatch function "xtaIsEnabled" to stack kMain
   return the result
end TestIsEnabled

on TestOffByDefault
   TestAssert "off until it is turned on", TestIsEnabled() is false
   TestAssert "not in the message path", not (kMain is among the lines of the stacksInUse)
   TestAssert "the core is not loaded", there is not a stack kCore
   TestAssert "no window", there is not a stack kWindow
   revIDESetPreference "cXTalkAssistant,enabled", true
   TestAssert "on once it is turned on", TestIsEnabled() is true
   put "off" into $OXTBEYOND_XTALK_ASSISTANT
   TestAssert "kept off by the environment", TestIsEnabled() is false
   put empty into $OXTBEYOND_XTALK_ASSISTANT
end TestOffByDefault

on TestOpenWindow
   TestOpenTheWindow "http://127.0.0.1:1"
   TestAssert "the window is built", there is a stack kWindow
   -- It is built invisible, so it must be shown when it opens (0.2.5-rc.2
   -- left it hidden, and turning the assistant on seemed to do nothing)
   TestAssert "the window is shown", the visible of stack kWindow
   TestAssert "the window is a palette", the mode of stack kWindow is 4
   TestDiagnostic the rect of stack kWindow && "/" && the screenRect
   TestAssert "the window is in the middle of the screen", the loc of stack kWindow is the screenLoc
   TestAssert "the core is in use", kCore is among the lines of the stacksInUse
   TestAssert "the provider is shown", the label of button "Provider" of stack kWindow is "Anthropic"
   TestAssert "the model is shown", the label of button "Model" of stack kWindow is "test-model"
   TestDiagnostic field "Status" of stack kWindow
   TestAssert "the key from the environment is used", field "Status" of stack kWindow contains "from the environment"
   TestAssert "nothing to insert yet", not the enabled of button "Insert" of stack kWindow
   TestDiagnostic the rect of field "Prompt" of stack kWindow && "/" && the rect of field "Status" of stack kWindow
   TestAssert "the prompt is laid out above the status line", \
         item 4 of the rect of field "Prompt" of stack kWindow <= item 2 of the rect of field "Status" of stack kWindow \
         and item 4 of the rect of field "Prompt" of stack kWindow > item 2 of the rect of field "Prompt" of stack kWindow
end TestOpenWindow

on TestAskThroughTheWindow
   local tPort, tAnswer, tPrefs, tValue, tFound
   put "Here it is:" & return & "```livecodescript" & return & "on mouseUp" & return & \
         "   beep" & return & "end mouseUp" & return & "```" into tAnswer
   put TestStartServer("200 OK", "{" & TestQ("content") & ":[{" & TestQ("type") & ":" & TestQ("text") & "," & \
         TestQ("text") & ":" & TestQ(tAnswer) & "}]," & TestQ("stop_reason") & ":" & TestQ("end_turn") & "," & \
         TestQ("usage") & ":{" & TestQ("input_tokens") & ":12," & TestQ("output_tokens") & ":34}}") into tPort
   TestOpenTheWindow "http://127.0.0.1:" & tPort
   put "Write a mouseUp handler that beeps" into field "Prompt" of stack kWindow
   dispatch "xtaSendPrompt" to stack kMain
   TestDiagnostic sRequest
   TestAssert "asked the provider", sRequest begins with "POST /v1/messages HTTP/1.1"
   TestAssert "with the key from the environment", TestRequestHeader("x-api-key") is "sk-from-env"
   TestAssert "the question was sent", TestRequestBody() contains "Write a mouseUp handler that beeps"
   TestAssert "no script was attached (no Script Editor is open)", not (TestRequestBody() contains "The script I am editing")
   TestDiagnostic field "Conversation" of stack kWindow
   TestAssert "the answer is shown", field "Conversation" of stack kWindow contains "end mouseUp"
   TestAssert "who asked, in bold", line 1 of field "Conversation" of stack kWindow is "You" \
         and the textStyle of line 1 of field "Conversation" of stack kWindow is "bold"
   TestAssert "who answered, in bold", line 4 of field "Conversation" of stack kWindow is "xTalk Assistant" \
         and the textStyle of line 4 of field "Conversation" of stack kWindow is "bold"
   TestAssert "a line of the answer is not bold", the textStyle of line 5 of field "Conversation" of stack kWindow is not "bold"
   TestAssert "the prompt is cleared", field "Prompt" of stack kWindow is empty
   TestAssert "the code can be inserted", the enabled of button "Insert" of stack kWindow
   TestDiagnostic field "Status" of stack kWindow
   TestAssert "the tokens are shown", field "Status" of stack kWindow contains "12 tokens in, 34 out"

   -- The key is never a preference
   put xtaTestPrefs() into tPrefs
   put false into tFound
   repeat for each element tValue in tPrefs
      if tValue contains "sk-from-env" then
         put true into tFound
      end if
   end repeat
   TestAssert "the key is not in the preferences", not tFound

   dispatch "xtaNewConversation" to stack kMain
   TestAssert "a new conversation", field "Conversation" of stack kWindow is empty
   TestAssert "nothing to insert", not the enabled of button "Insert" of stack kWindow
end TestAskThroughTheWindow

on TestGuideAndNotesAreSent
   local tPort, tDoc, tSystem, tBody
   put "# memory" & return & "[you]" & return & "- Builds for Linux only." & return into url ("file:" & sPrefsFolder & "/xTalk Assistant Memory.txt")
   put TestStartServer("200 OK", TestAnswer("Hello.")) into tPort
   TestOpenTheWindow "http://127.0.0.1:" & tPort
   put "Hi" into field "Prompt" of stack kWindow
   dispatch "xtaSendPrompt" to stack kMain
   put TestRequestBody() into tBody
   put xtaJsonParse(tBody) into tDoc
   put xtaJsonMember(tDoc, "system") into tSystem
   TestAssert "the guide goes first", xtaJsonText(xtaJsonGet(tSystem, "1/text")) begins with "# The xTalk Assistant's guide"
   TestAssert "marked for the cache", xtaJsonText(xtaJsonGet(tSystem, "1/cache_control/type")) is "ephemeral"
   TestAssert "then the user's notes", xtaJsonText(xtaJsonGet(tSystem, "2/text")) contains "- Builds for Linux only."
   TestDiagnostic field "Status" of stack kWindow
   TestAssert "what the cache saved is shown", field "Status" of stack kWindow contains "5000 read from the cache"

   -- The short guide, for a small model
   dispatch "xtaMoreMenuPick" to stack kMain with "Short Guide (for small local models)"
   TestAssert "is ticked in the menu", "!cShort Guide (for small local models)" is among the lines of the text of button "More" of stack kWindow
   put "Hi again" into field "Prompt" of stack kWindow
   dispatch "xtaSendPrompt" to stack kMain
   put xtaJsonParse(TestRequestBody()) into tDoc
   TestAssert "the short guide is sent instead", xtaJsonText(xtaJsonGet(tDoc, "system/1/text")) begins with "You are the xTalk Assistant"
end TestGuideAndNotesAreSent

on TestCodeThatDoesNotCompileGoesBack
   local tPort, tBad, tGood, tBody
   put "Here:" & return & TestBlock("livecodescript", "on mouseUp" & return & "   put 1 inot tX" & return & "end mouseUp") into tBad
   put "Fixed:" & return & TestBlock("livecodescript", "on mouseUp" & return & "   beep" & return & "end mouseUp") into tGood
   put TestStartServer("200 OK", TestAnswer(tBad)) into tPort
   TestQueueAnswer "200 OK", TestAnswer(tGood)
   TestOpenTheWindow "http://127.0.0.1:" & tPort
   put "Write a mouseUp handler" into field "Prompt" of stack kWindow
   dispatch "xtaSendPrompt" to stack kMain
   TestAssert "asked twice", sServed is 2
   put TestBodyOf(sRequests[2]) into tBody
   TestDiagnostic tBody
   TestAssert "the second time with the errors", tBody contains "Compile check:" and tBody contains "line 2, column 8"
   TestAssert "after the first answer", tBody contains "inot"
   TestDiagnostic field "Conversation" of stack kWindow
   TestAssert "the check is shown as a turn", "Compile check" is among the lines of field "Conversation" of stack kWindow
   TestAssert "the corrected answer is shown", field "Conversation" of stack kWindow contains "Fixed:"
   TestAssert "and that it compiles", "Compile check: the code compiles." is among the lines of field "Conversation" of stack kWindow
   TestAssert "the tokens of both rounds", field "Status" of stack kWindow contains "20 tokens in, 40 out"
   TestAssert "the corrected code can be inserted", the enabled of button "Insert" of stack kWindow
   TestAssert "Send is Send again", the label of button "Send" of stack kWindow is "Send"
end TestCodeThatDoesNotCompileGoesBack

on TestFixRoundsRunOut
   local tPort, tBad
   put TestBlock("livecodescript", "on mouseUp" & return & "   put 1 inot tX" & return & "end mouseUp") into tBad
   put TestStartServer("200 OK", TestAnswer(tBad)) into tPort
   TestQueueAnswer "200 OK", TestAnswer(TestBlock("livecodescript", "on mouseUp" & return & "   put 2 inot tX" & return & "end mouseUp"))
   TestQueueAnswer "200 OK", TestAnswer(TestBlock("livecodescript", "on mouseUp" & return & "   put 3 inot tX" & return & "end mouseUp"))
   TestOpenTheWindow "http://127.0.0.1:" & tPort
   revIDESetPreference "cXTalkAssistant,fixRounds", 2
   put "Write a mouseUp handler" into field "Prompt" of stack kWindow
   dispatch "xtaSendPrompt" to stack kMain
   TestAssert "two rounds of corrections at most", sServed is 3
   TestDiagnostic field "Status" of stack kWindow
   TestAssert "the status says the code does not compile", field "Status" of stack kWindow contains "does not compile"

   -- The same code again ends it at once
   put TestStartServer("200 OK", TestAnswer(tBad)) into tPort
   revIDESetPreference "cXTalkAssistant,baseUrl,anthropic", "http://127.0.0.1:" & tPort
   revIDESetPreference "cXTalkAssistant,fixRounds", 5
   put "Again" into field "Prompt" of stack kWindow
   dispatch "xtaSendPrompt" to stack kMain
   TestAssert "the same code twice is not sent back again", sServed is 2

   -- No rounds: checked, and nothing sent back
   put TestStartServer("200 OK", TestAnswer(tBad)) into tPort
   revIDESetPreference "cXTalkAssistant,baseUrl,anthropic", "http://127.0.0.1:" & tPort
   revIDESetPreference "cXTalkAssistant,fixRounds", 0
   put "Once more" into field "Prompt" of stack kWindow
   dispatch "xtaSendPrompt" to stack kMain
   TestAssert "no rounds: asked once", sServed is 1
   TestAssert "and the check is shown", line -2 of field "Conversation" of stack kWindow begins with "Compile check: the code does not compile"
end TestFixRoundsRunOut

on TestOnlyXTalkIsInserted
   local tPort
   put TestStartServer("200 OK", TestAnswer(TestBlock("livecodescript", "on mouseUp" & return & "   beep" & return & "end mouseUp"))) into tPort
   TestQueueAnswer "200 OK", TestAnswer("In Python:" & return & TestBlock("python", "print(1)") & return & \
         TestBlock("livecodebuilder", "public handler f()" & return & "end handler"))
   TestOpenTheWindow "http://127.0.0.1:" & tPort
   put "Beep" into field "Prompt" of stack kWindow
   dispatch "xtaSendPrompt" to stack kMain
   TestAssert "code to insert", the enabled of button "Insert" of stack kWindow
   put "Print 1" into field "Prompt" of stack kWindow
   dispatch "xtaSendPrompt" to stack kMain
   TestAssert "asked once more (other languages are not compiled)", sServed is 2
   TestAssert "nothing to insert from the latest answer", not the enabled of button "Insert" of stack kWindow
   TestDiagnostic field "Conversation" of stack kWindow
   TestAssert "no compile check is shown for it", line -2 of field "Conversation" of stack kWindow is "```" and \
         not (line -2 to -1 of field "Conversation" of stack kWindow contains "Compile check")
end TestOnlyXTalkIsInserted

on TestNotesToRemember
   local tPort, tMemory, tLine, tFound
   put TestStartServer("200 OK", TestAnswer("Noted." & return & TestBlock("memory", "you: Builds for Windows only." & return & "you: Likes short answers."))) into tPort
   TestOpenTheWindow "http://127.0.0.1:" & tPort
   put "I only build for Windows" into field "Prompt" of stack kWindow
   dispatch "xtaSendPrompt" to stack kMain
   TestDiagnostic field "Conversation" of stack kWindow
   TestAssert "the memory block is not shown", not (field "Conversation" of stack kWindow contains "```memory")
   put 0 into tFound
   repeat with tLine = 1 to the number of lines of field "Conversation" of stack kWindow
      if line tLine of field "Conversation" of stack kWindow begins with "Note to keep about you: Builds for Windows only." then
         put tLine into tFound
      end if
   end repeat
   TestAssert "the note is shown", tFound > 0
   TestAssert "with Remember and Dismiss as links", the textStyle of the last word of line tFound of field "Conversation" of stack kWindow is "link" \
         and the linkText of word -2 of line tFound of field "Conversation" of stack kWindow is "remember,2,1"
   TestAssert "nothing is kept yet", there is not a file (sPrefsFolder & "/xTalk Assistant Memory.txt")

   dispatch "xtaNoteClicked" to stack kMain with "remember,2,1"
   put xtaMemoryLoad(sPrefsFolder & "/xTalk Assistant Memory.txt") into tMemory
   TestAssert "Remember keeps it", tMemory["you"] is "Builds for Windows only."
   TestAssert "and says so", field "Conversation" of stack kWindow contains "Remembered about you: Builds for Windows only."
   dispatch "xtaNoteClicked" to stack kMain with "dismiss,2,2"
   TestAssert "Dismiss drops it", not (field "Conversation" of stack kWindow contains "Likes short answers")
   put xtaMemoryLoad(sPrefsFolder & "/xTalk Assistant Memory.txt") into tMemory
   TestAssert "and keeps nothing", tMemory["you"] is "Builds for Windows only."
   dispatch "xtaNoteClicked" to stack kMain with "remember,2,2"
   put xtaMemoryLoad(sPrefsFolder & "/xTalk Assistant Memory.txt") into tMemory
   TestAssert "a dismissed note cannot be kept after all", tMemory["you"] is "Builds for Windows only."
end TestNotesToRemember

-- Models fills the model menu and, with no model chosen yet, chooses the
-- one the provider's list suggests (0.2.5-rc.3 chose none, and Send only
-- said to choose one)
on TestModelsChoosesAModel
   local tPort, tPrefs
   put TestStartServer("200 OK", TestModelList()) into tPort
   TestOpenTheWindowWithoutAModel "http://127.0.0.1:" & tPort
   TestAssert "no model to begin with", the label of button "Model" of stack kWindow is empty
   TestDiagnostic field "Status" of stack kWindow
   TestAssert "the status line says Send chooses one", field "Status" of stack kWindow contains "Send chooses one"
   dispatch "xtaChooseModels" to stack kMain
   TestDiagnostic sRequest
   TestAssert "asked for the models", sRequest begins with "GET /v1/models"
   TestAssert "the menu lists them, sorted", the text of button "Model" of stack kWindow is \
         ("claude-haiku-9" & return & "claude-opus-9" & return & "claude-sonnet-9")
   TestAssert "the newest Sonnet is chosen", the label of button "Model" of stack kWindow is "claude-sonnet-9"
   put xtaTestPrefs() into tPrefs
   TestAssert "and kept", tPrefs["cXTalkAssistant,model,anthropic"] is "claude-sonnet-9"
   TestDiagnostic field "Status" of stack kWindow
   TestAssert "the status line says which", field "Status" of stack kWindow contains "Using claude-sonnet-9"
   TestAssert "Send is Send again", the label of button "Send" of stack kWindow is "Send" and the enabled of button "Models" of stack kWindow

   -- A model the user chose stays chosen
   revIDESetPreference "cXTalkAssistant,model,anthropic", "claude-opus-9"
   dispatch "xtaChooseModels" to stack kMain
   TestAssert "the user's model stays", the label of button "Model" of stack kWindow is "claude-opus-9"

   -- Another provider: its models are not those
   dispatch "xtaSetProviderByName" to stack kMain with "OpenAI (or compatible)"
   TestAssert "the other provider is shown", the label of button "Provider" of stack kWindow is "OpenAI (or compatible)"
   TestAssert "the model menu is emptied", the text of button "Model" of stack kWindow is empty
   dispatch "xtaSetProviderByName" to stack kMain with "Anthropic"
   TestAssert "back to Anthropic, with its model", the label of button "Model" of stack kWindow is "claude-opus-9"
end TestModelsChoosesAModel

-- Send with no model chosen asks for the models first and uses the one the
-- list suggests
on TestSendChoosesAModel
   local tPort
   put TestStartServer("200 OK", TestModelList()) into tPort
   TestQueueAnswer "200 OK", TestAnswer("Hello.")
   TestOpenTheWindowWithoutAModel "http://127.0.0.1:" & tPort
   put "Say hello" into field "Prompt" of stack kWindow
   dispatch "xtaSendPrompt" to stack kMain
   TestDiagnostic sRequests[1] & return & "---" & return & sRequests[2]
   TestAssert "two requests", sServed is 2
   TestAssert "first the models", sRequests[1] begins with "GET /v1/models"
   TestAssert "then the question", sRequests[2] begins with "POST /v1/messages"
   TestAssert "with the model the list suggests", TestBodyOf(sRequests[2]) contains (TestQ("model") & ":" & TestQ("claude-sonnet-9"))
   TestAssert "the answer is shown", field "Conversation" of stack kWindow contains "Hello."
   TestAssert "the model is shown", the label of button "Model" of stack kWindow is "claude-sonnet-9"
end TestSendChoosesAModel

on TestMoreMenu
   TestOpenTheWindow "http://127.0.0.1:1"
   TestDiagnostic the text of button "More" of stack kWindow
   TestAssert "Memory", "Memory..." is among the lines of the text of button "More" of stack kWindow
   TestAssert "Fix Rounds", "Fix Rounds..." is among the lines of the text of button "More" of stack kWindow
   TestAssert "the short guide, not ticked", "!nShort Guide (for small local models)" is among the lines of the text of button "More" of stack kWindow
end TestMoreMenu

on TestUnloadTakesItAllAway
   TestOpenTheWindow "http://127.0.0.1:1"
   TestAssert "the window is open", there is a stack kWindow
   -- What the IDE sends when it unloads the extension
   send "extensionFinalize" to stack kMain
   TestAssert "the window is gone", there is not a stack kWindow
   TestAssert "the core is no longer in use", not (kCore is among the lines of the stacksInUse)
   TestAssert "the compile check's stack is gone", there is not a stack "revXTalkAssistantCheck"
end TestUnloadTakesItAllAway

-- Turns the assistant on, as the user would, for Anthropic with a model and
-- a key from the environment, and opens its window.
private command TestOpenTheWindow pBaseUrl
   revIDESetPreference "cXTalkAssistant,enabled", true
   revIDESetPreference "cXTalkAssistant,provider", "anthropic"
   revIDESetPreference "cXTalkAssistant,model,anthropic", "test-model"
   revIDESetPreference "cXTalkAssistant,baseUrl,anthropic", pBaseUrl
   put "sk-from-env" into $ANTHROPIC_API_KEY
   dispatch "xtalkAssistantMenuPick" to stack kMain
end TestOpenTheWindow

-- As TestOpenTheWindow, with no model chosen yet
private command TestOpenTheWindowWithoutAModel pBaseUrl
   TestOpenTheWindow pBaseUrl
   revIDESetPreference "cXTalkAssistant,model,anthropic", empty
   dispatch "xtalkAssistantMenuPick" to stack kMain
end TestOpenTheWindowWithoutAModel

-- Anthropic's model list: newest first
private function TestModelList
   return "{" & TestQ("data") & ":[{" & TestQ("id") & ":" & TestQ("claude-opus-9") & "},{" & \
         TestQ("id") & ":" & TestQ("claude-sonnet-9") & "},{" & TestQ("id") & ":" & TestQ("claude-haiku-9") & "}]," & \
         TestQ("has_more") & ":false}"
end TestModelList

-- A JSON string (the core's writer is not loaded before the window is)
private function TestQ pText
   replace numToChar(92) with numToChar(92) & numToChar(92) in pText
   replace quote with numToChar(92) & quote in pText
   replace return with numToChar(92) & "n" in pText
   return quote & pText & quote
end TestQ

--------------------------------------------------------------------------------
-- A server of this process that answers as the provider does

private function TestStartServer pStatus, pBody
   put empty into sResponses
   TestQueueAnswer pStatus, pBody
   put 0 into sServed
   put empty into sRequest
   put empty into sRequests
   accept connections on port 0 with message "xtaTestServerAccept"
   return it
end TestStartServer

-- Another answer, for the request after those already queued
private command TestQueueAnswer pStatus, pBody
   local tBytes
   put textEncode(pBody, "UTF-8") into tBytes
   put "HTTP/1.1" && pStatus & crlf & "Content-Type: application/json" & crlf & \
         "Content-Length:" && the number of bytes of tBytes & crlf & "Connection: close" & crlf & crlf & tBytes \
         into sResponses[the number of elements of sResponses + 1]
end TestQueueAnswer

on xtaTestServerAccept pSocket
   read from socket pSocket until crlf & crlf with message "xtaTestServerHeaders"
end xtaTestServerAccept

on xtaTestServerHeaders pSocket, pData
   local tLength, tLine
   put pData into sRequest
   repeat for each line tLine in pData
      if tLine begins with "Content-Length:" then
         put word 2 of tLine into tLength
      end if
   end repeat
   if tLength is an integer and tLength > 0 then
      read from socket pSocket for tLength bytes with message "xtaTestServerBody"
   else
      xtaTestServerBody pSocket, empty
   end if
end xtaTestServerHeaders

on xtaTestServerBody pSocket, pData
   local tAnswer
   put pData after sRequest
   add 1 to sServed
   put sRequest into sRequests[sServed]
   if sServed <= the number of elements of sResponses then
      put sResponses[sServed] into tAnswer
   else
      put sResponses[the number of elements of sResponses] into tAnswer
   end if
   write tAnswer to socket pSocket
   close socket pSocket
end xtaTestServerBody

private function TestRequestHeader pName
   local tLine
   repeat for each line tLine in sRequest
      replace numToChar(13) with empty in tLine
      if tLine is empty then
         exit repeat
      end if
      if tLine begins with (pName & ":") then
         return word 2 to -1 of tLine
      end if
   end repeat
   return empty
end TestRequestHeader

private function TestRequestBody
   return TestBodyOf(sRequest)
end TestRequestBody

private function TestBodyOf pRequest
   local tAt
   put offset(crlf & crlf, pRequest) into tAt
   return textDecode(char tAt + 4 to -1 of pRequest, "UTF-8")
end TestBodyOf

-- An answer as Anthropic gives it, with pText as what the model said
private function TestAnswer pText
   return "{" & TestQ("content") & ":[{" & TestQ("type") & ":" & TestQ("text") & "," & \
         TestQ("text") & ":" & TestQ(pText) & "}]," & TestQ("stop_reason") & ":" & TestQ("end_turn") & "," & \
         TestQ("usage") & ":{" & TestQ("input_tokens") & ":10," & TestQ("output_tokens") & ":20," & \
         TestQ("cache_read_input_tokens") & ":5000}}"
end TestAnswer

-- pCode in a fenced block marked pLang
private function TestBlock pLang, pCode
   return "```" & pLang & return & pCode & return & "```"
end TestBlock
