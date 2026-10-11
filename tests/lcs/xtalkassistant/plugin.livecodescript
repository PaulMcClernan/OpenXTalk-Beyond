script "TestXTalkAssistantPlugin"
-- OXT-Beyond: tests of the xTalk Assistant plugin's main stack
-- (ide/Extensions/org.openxtalk.plugin.xtalkassistant/xtalkassistant.livecodescript),
-- loaded as the IDE loads an extension, with a stand-in for the three IDE
-- handlers it calls: that it stays off and loads nothing until it is turned
-- on, that the window it builds asks a server of this process (answering as
-- Anthropic does) and shows the answer, that the key never becomes a
-- preference, and that unloading it takes everything away again. The
-- dialogs (turning it on, typing a key, errors) and the Script Editor are
-- not reached here: they need the IDE.

constant kMain = "org.openxtalk.plugin.xtalkassistant"
constant kWindow = "revXTalkAssistant"
constant kCore = "org.openxtalk.plugin.xtalkassistant-core"

-- The test server's answer, and the request it read
local sResponse, sRequest

on TestSetup
   local tLibUrl, tStub
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
         "function revTopMostScriptEditor" & return & "return empty" & return & "end revTopMostScriptEditor" into tStub
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

on TestUnloadTakesItAllAway
   TestOpenTheWindow "http://127.0.0.1:1"
   TestAssert "the window is open", there is a stack kWindow
   -- What the IDE sends when it unloads the extension
   send "extensionFinalize" to stack kMain
   TestAssert "the window is gone", there is not a stack kWindow
   TestAssert "the core is no longer in use", not (kCore is among the lines of the stacksInUse)
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
   local tBytes
   put textEncode(pBody, "UTF-8") into tBytes
   put "HTTP/1.1" && pStatus & crlf & "Content-Type: application/json" & crlf & \
         "Content-Length:" && the number of bytes of tBytes & crlf & "Connection: close" & crlf & crlf & tBytes into sResponse
   put empty into sRequest
   accept connections on port 0 with message "xtaTestServerAccept"
   return it
end TestStartServer

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
   put pData after sRequest
   write sResponse to socket pSocket
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
   local tAt
   put offset(crlf & crlf, sRequest) into tAt
   return textDecode(char tAt + 4 to -1 of sRequest, "UTF-8")
end TestRequestBody
