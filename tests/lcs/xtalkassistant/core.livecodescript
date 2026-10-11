script "TestXTalkAssistantCore"
-- OXT-Beyond: tests of the xTalk Assistant plugin's core
-- (ide/Extensions/org.openxtalk.plugin.xtalkassistant/xtalkassistant-core.livecodescript):
-- its JSON reader and writer, the requests and answers of both providers,
-- and whole round trips through libURL to a server of this process that
-- answers as the providers do. No key and no internet are needed.

-- The test server's answer, and the request it read
local sResponse, sRequest

on TestSetup
   local tCore, tLibUrl
   put TestGetIDERepositoryPath() & "/Extensions/org.openxtalk.plugin.xtalkassistant/xtalkassistant-core.livecodescript" into tCore
   start using stack tCore
   if not TestIsInStandalone() then
      put TestGetEngineRepositoryPath() & "/ide-support/revliburl.livecodescript" into tLibUrl
      send "extensionInitialize" to stack tLibUrl
   end if
end TestSetup

--------------------------------------------------------------------------------
-- JSON

on TestJsonStringEscapes
   local tText, tJson
   TestAssert "plain text", xtaJsonString("abc") is (quote & "abc" & quote)
   put quote & numToChar(92) & numToChar(10) & numToChar(13) & numToChar(9) & numToChar(1) into tText
   put xtaJsonString(tText) into tJson
   TestDiagnostic tJson
   TestAssert "quote, backslash and control characters escaped", \
         tJson is (quote & numToChar(92) & quote & numToChar(92) & numToChar(92) & \
         numToChar(92) & "n" & numToChar(92) & "r" & numToChar(92) & "t" & \
         numToChar(92) & "u0001" & quote)
   -- A quote with a combining mark after it is still escaped
   put "a" & quote & numToCodepoint(769) & "b" into tText
   TestAssert "quote before a combining mark", xtaJsonText(xtaJsonParse(xtaJsonString(tText))) is tText
   put "caf" & numToCodepoint(233) & " " & numToCodepoint(128512) into tText
   TestAssert "non-ASCII text goes as it is", xtaJsonString(tText) is (quote & tText & quote)
   TestAssert "round trip", xtaJsonText(xtaJsonParse(xtaJsonString(tText))) is tText
end TestJsonStringEscapes

on TestJsonParseValues
   local tJson, tDoc, tList, tB
   put numToChar(92) into tB
   put "{ " & quote & "a" & quote & ": [1, -2.5e3, true, false, null, " & quote & "x" & tB & "n" & tB & quote & "y" & quote & "], " & \
         quote & "b" & quote & ":{" & quote & "c" & quote & ":" & quote & tB & "u00e9" & tB & "ud83d" & tB & "ude00" & quote & "}," & \
         quote & "z" & quote & ":" & quote & quote & "}" into tJson
   put xtaJsonParse(tJson) into tDoc
   TestAssert "an object", xtaJsonType(tDoc) is "object"
   TestAssert "three members", xtaJsonCount(tDoc) is 3
   TestAssert "member order", tDoc["names"][1] is "a" and tDoc["names"][2] is "b" and tDoc["names"][3] is "z"
   put xtaJsonMember(tDoc, "a") into tList
   TestAssert "an array of six", xtaJsonType(tList) is "array" and xtaJsonCount(tList) is 6
   TestAssert "integer", xtaJsonText(xtaJsonItem(tList, 1)) is "1"
   TestAssert "number as written", xtaJsonText(xtaJsonItem(tList, 2)) is "-2.5e3"
   TestAssert "true", xtaJsonType(xtaJsonItem(tList, 3)) is "boolean" and xtaJsonText(xtaJsonItem(tList, 3)) is "true"
   TestAssert "false", xtaJsonText(xtaJsonItem(tList, 4)) is "false"
   TestAssert "null", xtaJsonType(xtaJsonItem(tList, 5)) is "null"
   TestAssert "escapes", xtaJsonText(xtaJsonItem(tList, 6)) is ("x" & numToChar(10) & quote & "y")
   TestAssert "\u escapes and a surrogate pair", \
         xtaJsonText(xtaJsonGet(tDoc, "b/c")) is (numToCodepoint(233) & numToCodepoint(128512))
   TestAssert "empty string", xtaJsonType(xtaJsonMember(tDoc, "z")) is "string" and xtaJsonText(xtaJsonMember(tDoc, "z")) is empty
   TestAssert "path into an array", xtaJsonText(xtaJsonGet(tDoc, "a/6")) is ("x" & numToChar(10) & quote & "y")
   TestAssert "missing member", xtaJsonType(xtaJsonGet(tDoc, "b/nope")) is "missing"
   TestAssert "missing item", xtaJsonType(xtaJsonGet(tDoc, "a/7")) is "missing"
   TestAssert "raw text of a value", xtaJsonRaw(tJson, xtaJsonMember(tDoc, "b")) is \
         ("{" & quote & "c" & quote & ":" & quote & tB & "u00e9" & tB & "ud83d" & tB & "ude00" & quote & "}")
   TestAssert "a lone surrogate", xtaJsonText(xtaJsonParse(quote & tB & "ud83d" & quote)) is numToCodepoint(65533)
   TestAssert "text before and after a long run without escapes", \
         xtaJsonText(xtaJsonParse(quote & "abc" & tB & tB & "def" & quote)) is ("abc" & tB & "def")
end TestJsonParseValues

on TestJsonParseRejects
   local tBad, tCount, tError, tItem
   put "{" & return & "{" & quote & "a" & quote & "}" & return & quote & "abc" & return & "[1,]" & return & \
         "[1 2]" & return & "{" & quote & "a" & quote & ":1,}" & return & "tru" & return & "01" & return & "1." & return & \
         "{" & quote & "a" & quote & ":1} x" & return & quote & numToChar(92) & "q" & quote & return & "[" & return & \
         "{1:2}" & return & quote & numToChar(92) & "u12" & quote into tBad
   put 0 into tCount
   repeat for each line tItem in tBad
      put empty into tError
      try
         get xtaJsonParse(tItem)
      catch tError
      end try
      if tError begins with "xTalk Assistant: the JSON is not valid" then
         add 1 to tCount
      else
         TestDiagnostic "accepted:" && tItem
      end if
   end repeat
   TestAssert "every malformed text refused", tCount is the number of lines of tBad
   put empty into tError
   try
      get xtaJsonParse(empty)
   catch tError
   end try
   TestAssert "empty text refused", tError begins with "xTalk Assistant: the JSON is not valid"
end TestJsonParseRejects

on TestJsonParseLongText
   local tText, tDoc
   repeat 20000
      put "line of text " & quote & "quoted" & quote & numToChar(10) after tText
   end repeat
   put xtaJsonParse("{" & quote & "t" & quote & ":" & xtaJsonString(tText) & "}") into tDoc
   TestAssert "a long string round trip", xtaJsonText(xtaJsonMember(tDoc, "t")) is tText
end TestJsonParseLongText

--------------------------------------------------------------------------------
-- Requests

private function TestTurns
   local tTurns
   put "user" into tTurns[1]["role"]
   put "Write a mouseUp handler" into tTurns[1]["text"]
   put "assistant" into tTurns[2]["role"]
   put empty into tTurns[2]["text"]
   put "assistant" into tTurns[3]["role"]
   put "on mouseUp" & return & "end mouseUp" into tTurns[3]["text"]
   put "user" into tTurns[4]["role"]
   put "Thanks" into tTurns[4]["text"]
   return tTurns
end TestTurns

on TestRequestBodyAnthropic
   local tBody, tDoc, tMessages
   put xtaRequestBody("anthropic", " some-model ", "Be brief.", TestTurns(), empty) into tBody
   TestDiagnostic tBody
   put xtaJsonParse(tBody) into tDoc
   TestAssert "model, trimmed", xtaJsonText(xtaJsonMember(tDoc, "model")) is "some-model"
   TestAssert "max_tokens is a number", xtaJsonType(xtaJsonMember(tDoc, "max_tokens")) is "number"
   TestAssert "max_tokens default", xtaJsonText(xtaJsonMember(tDoc, "max_tokens")) is 4096
   TestAssert "system", xtaJsonText(xtaJsonMember(tDoc, "system")) is "Be brief."
   put xtaJsonMember(tDoc, "messages") into tMessages
   TestAssert "the empty turn is left out", xtaJsonCount(tMessages) is 3
   TestAssert "roles", xtaJsonText(xtaJsonGet(tMessages, "1/role")) is "user" \
         and xtaJsonText(xtaJsonGet(tMessages, "2/role")) is "assistant" \
         and xtaJsonText(xtaJsonGet(tMessages, "3/role")) is "user"
   TestAssert "text with a return", xtaJsonText(xtaJsonGet(tMessages, "2/content")) is ("on mouseUp" & return & "end mouseUp")
   put xtaRequestBody("anthropic", "m", empty, TestTurns(), 1000) into tBody
   put xtaJsonParse(tBody) into tDoc
   TestAssert "max_tokens given", xtaJsonText(xtaJsonMember(tDoc, "max_tokens")) is 1000
   TestAssert "no system when there is none", xtaJsonType(xtaJsonMember(tDoc, "system")) is "missing"
end TestRequestBodyAnthropic

on TestRequestBodyOpenAI
   local tBody, tDoc, tMessages
   put xtaRequestBody("openai", "some-model", "Be brief.", TestTurns(), 1000) into tBody
   TestDiagnostic tBody
   put xtaJsonParse(tBody) into tDoc
   put xtaJsonMember(tDoc, "messages") into tMessages
   TestAssert "the system prompt is the first message", xtaJsonText(xtaJsonGet(tMessages, "1/role")) is "system" \
         and xtaJsonText(xtaJsonGet(tMessages, "1/content")) is "Be brief."
   TestAssert "then the three turns", xtaJsonCount(tMessages) is 4
   TestAssert "no max_tokens", xtaJsonType(xtaJsonMember(tDoc, "max_tokens")) is "missing"
   TestAssert "no system member", xtaJsonType(xtaJsonMember(tDoc, "system")) is "missing"
end TestRequestBodyOpenAI

on TestRequestBodyNeedsModel
   local tError
   try
      get xtaRequestBody("anthropic", "  ", empty, TestTurns(), empty)
   catch tError
   end try
   TestAssert "no model is refused", tError contains "no model"
end TestRequestBodyNeedsModel

on TestRequestHeaders
   local tHeaders, tError
   put xtaRequestHeaders("anthropic", " sk-test ") into tHeaders
   TestDiagnostic tHeaders
   TestAssert "anthropic key", "x-api-key: sk-test" is among the lines of tHeaders
   TestAssert "anthropic version", "anthropic-version: 2023-06-01" is among the lines of tHeaders
   TestAssert "JSON", "Content-Type: application/json" is among the lines of tHeaders
   put xtaRequestHeaders("openai", "sk-test") into tHeaders
   TestAssert "openai bearer", "Authorization: Bearer sk-test" is among the lines of tHeaders
   TestAssert "no anthropic header for openai", not (tHeaders contains "x-api-key")
   put xtaRequestHeaders("openai", empty) into tHeaders
   TestAssert "no key, no Authorization line", not (tHeaders contains "Authorization")
   try
      get xtaRequestHeaders("openai", "sk" & numToChar(10) & "X-Evil: 1")
   catch tError
   end try
   TestAssert "a key with a line break is refused", tError contains "line break"
end TestRequestHeaders

on TestUrls
   TestAssert "anthropic default", xtaRequestUrl("anthropic", empty) is "https://api.anthropic.com/v1/messages"
   TestAssert "openai default", xtaRequestUrl("openai", empty) is "https://api.openai.com/v1/chat/completions"
   TestAssert "a base URL with a slash", xtaRequestUrl("openai", "http://localhost:11434/v1/") is "http://localhost:11434/v1/chat/completions"
   TestAssert "anthropic models", xtaModelsUrl("anthropic", empty) is "https://api.anthropic.com/v1/models?limit=100"
   TestAssert "openai models", xtaModelsUrl("openai", "https://example.org/v1") is "https://example.org/v1/models"
   TestAssert "unknown provider", xtaRequestUrl("nope", empty) is empty
end TestUrls

--------------------------------------------------------------------------------
-- Answers

private function TestQ pText
   return quote & pText & quote
end TestQ

on TestParseReplyAnthropic
   local tBody, tReply
   put "{" & TestQ("id") & ":" & TestQ("msg_1") & "," & TestQ("type") & ":" & TestQ("message") & "," & \
         TestQ("content") & ":[{" & TestQ("type") & ":" & TestQ("text") & "," & TestQ("text") & ":" & TestQ("Here it is:") & "}," & \
         "{" & TestQ("type") & ":" & TestQ("tool_use") & "," & TestQ("id") & ":" & TestQ("t1") & "," & TestQ("name") & ":" & TestQ("x") & "," & TestQ("input") & ":{}}," & \
         "{" & TestQ("type") & ":" & TestQ("text") & "," & TestQ("text") & ":" & TestQ(" done") & "}]," & \
         TestQ("stop_reason") & ":" & TestQ("end_turn") & "," & \
         TestQ("usage") & ":{" & TestQ("input_tokens") & ":12," & TestQ("output_tokens") & ":34}}" into tBody
   put xtaParseReply("anthropic", 200, tBody) into tReply
   TestAssert "ok", tReply["ok"] is true
   TestAssert "the text parts, in order", tReply["text"] is "Here it is: done"
   TestAssert "stop reason", tReply["stop"] is "end_turn"
   TestAssert "tokens", tReply["inputTokens"] is 12 and tReply["outputTokens"] is 34

   put "{" & TestQ("type") & ":" & TestQ("error") & "," & TestQ("error") & ":{" & TestQ("type") & ":" & TestQ("authentication_error") & "," & TestQ("message") & ":" & TestQ("invalid x-api-key") & "}}" into tBody
   put xtaParseReply("anthropic", 401, tBody) into tReply
   TestAssert "an error is not ok", tReply["ok"] is false
   TestAssert "the key was refused", line 1 of tReply["error"] contains "API key"
   TestAssert "the provider's message", line 2 of tReply["error"] is "invalid x-api-key"

   put xtaParseReply("anthropic", 200, "<html>proxy</html>") into tReply
   TestAssert "an answer that is not JSON", tReply["ok"] is false and tReply["error"] contains "not JSON"
   put xtaParseReply("anthropic", 502, "Bad Gateway") into tReply
   TestAssert "an error status without JSON", tReply["ok"] is false and tReply["error"] contains "502" and tReply["error"] contains "Bad Gateway"
   put xtaParseReply("anthropic", empty, empty) into tReply
   TestAssert "no answer", tReply["ok"] is false and tReply["error"] is not empty
end TestParseReplyAnthropic

on TestParseReplyOpenAI
   local tBody, tReply
   put "{" & TestQ("choices") & ":[{" & TestQ("index") & ":0," & TestQ("message") & ":{" & TestQ("role") & ":" & TestQ("assistant") & "," & \
         TestQ("content") & ":" & TestQ("Hello") & "}," & TestQ("finish_reason") & ":" & TestQ("stop") & "}]," & \
         TestQ("usage") & ":{" & TestQ("prompt_tokens") & ":5," & TestQ("completion_tokens") & ":7}}" into tBody
   put xtaParseReply("openai", 200, tBody) into tReply
   TestAssert "ok", tReply["ok"] is true
   TestAssert "text", tReply["text"] is "Hello"
   TestAssert "finish reason", tReply["stop"] is "stop"
   TestAssert "tokens", tReply["inputTokens"] is 5 and tReply["outputTokens"] is 7

   put "{" & TestQ("error") & ":{" & TestQ("message") & ":" & TestQ("Incorrect API key provided") & "," & TestQ("type") & ":" & TestQ("invalid_request_error") & "}}" into tBody
   put xtaParseReply("openai", 401, tBody) into tReply
   TestAssert "error message", tReply["ok"] is false and line 2 of tReply["error"] is "Incorrect API key provided"
   put "{" & TestQ("error") & ":" & TestQ("model not found") & "}" into tBody
   put xtaParseReply("openai", 404, tBody) into tReply
   TestAssert "an error as a plain string", tReply["ok"] is false and line 2 of tReply["error"] is "model not found"
   put xtaParseReply("openai", 200, "{" & TestQ("choices") & ":[]}") into tReply
   TestAssert "no message", tReply["ok"] is false
end TestParseReplyOpenAI

on TestParseModels
   local tBody, tResult
   put "{" & TestQ("data") & ":[{" & TestQ("id") & ":" & TestQ("model-a") & "},{" & TestQ("id") & ":" & TestQ("model-b") & "}]," & TestQ("has_more") & ":false}" into tBody
   put xtaParseModels("anthropic", 200, tBody) into tResult
   TestAssert "two models", tResult["models"] is ("model-a" & return & "model-b")
   put xtaParseModels("openai", 200, "{" & TestQ("data") & ":[]}") into tResult
   TestAssert "none", tResult["error"] is not empty
end TestParseModels

on TestCodeBlocks
   local tText, tBlocks
   put "Put this in the button:" & return & "```livecodescript" & return & "on mouseUp" & return & return & "   beep" & return & "end mouseUp" & return & "```" & return & \
         "and then" & return & "  ``` " & return & "put 1" & return & "```" & return & "```lcs" & return & "unclosed" into tText
   put xtaCodeBlocks(tText) into tBlocks
   TestAssert "three blocks", the number of elements of tBlocks is 3
   TestAssert "language", tBlocks[1]["lang"] is "livecodescript"
   TestAssert "code with an empty line", tBlocks[1]["code"] is ("on mouseUp" & return & return & "   beep" & return & "end mouseUp")
   TestAssert "no language", tBlocks[2]["lang"] is empty and tBlocks[2]["code"] is "put 1"
   TestAssert "an unclosed block", tBlocks[3]["lang"] is "lcs" and tBlocks[3]["code"] is "unclosed"
end TestCodeBlocks

on TestSystemPrompt
   local tPrompt
   put xtaSystemPrompt() into tPrompt
   TestAssert "names the language", tPrompt contains "LiveCode Script"
   TestAssert "plain ASCII", not matchText(tPrompt, "[^\x09\x0A\x20-\x7E]")
end TestSystemPrompt

--------------------------------------------------------------------------------
-- Round trips through libURL to a server of this process

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
   local tLength
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

on TestAskAnthropic
   local tPort, tSettings, tReply, tDoc, tOldHeaders, tOldTimeout
   put TestStartServer("200 OK", "{" & TestQ("content") & ":[{" & TestQ("type") & ":" & TestQ("text") & "," & \
         TestQ("text") & ":" & TestQ("Hi " & numToCodepoint(233)) & "}]," & TestQ("stop_reason") & ":" & TestQ("end_turn") & "}") into tPort
   put "anthropic" into tSettings["provider"]
   put "http://127.0.0.1:" & tPort into tSettings["baseUrl"]
   put "sk-local" into tSettings["key"]
   put "test-model" into tSettings["model"]
   set the httpHeaders to "X-Before: 1"
   put the socketTimeoutInterval into tOldTimeout
   put xtaAsk(tSettings, "System text", TestTurns()) into tReply
   TestDiagnostic sRequest
   TestAssert "the request went to /v1/messages", sRequest begins with "POST /v1/messages HTTP/1.1"
   TestAssert "the key", TestRequestHeader("x-api-key") is "sk-local"
   TestAssert "the version", TestRequestHeader("anthropic-version") is "2023-06-01"
   TestAssert "JSON", TestRequestHeader("Content-Type") is "application/json"
   put xtaJsonParse(TestRequestBody()) into tDoc
   TestAssert "the body", xtaJsonText(xtaJsonMember(tDoc, "model")) is "test-model" \
         and xtaJsonText(xtaJsonMember(tDoc, "system")) is "System text" \
         and xtaJsonCount(xtaJsonMember(tDoc, "messages")) is 3
   TestAssert "the answer", tReply["ok"] is true and tReply["text"] is ("Hi " & numToCodepoint(233))
   TestAssert "the httpHeaders are put back", the httpHeaders is "X-Before: 1"
   TestAssert "the timeout is put back", the socketTimeoutInterval is tOldTimeout
   set the httpHeaders to empty
end TestAskAnthropic

on TestAskOpenAI
   local tPort, tSettings, tReply, tDoc
   put TestStartServer("200 OK", "{" & TestQ("choices") & ":[{" & TestQ("message") & ":{" & TestQ("role") & ":" & TestQ("assistant") & "," & \
         TestQ("content") & ":" & TestQ("Hello") & "}," & TestQ("finish_reason") & ":" & TestQ("stop") & "}]}") into tPort
   put "openai" into tSettings["provider"]
   put "http://127.0.0.1:" & tPort & "/v1/" into tSettings["baseUrl"]
   put "sk-local" into tSettings["key"]
   put "test-model" into tSettings["model"]
   put xtaAsk(tSettings, "System text", TestTurns()) into tReply
   TestDiagnostic sRequest
   TestAssert "the request went to /v1/chat/completions", sRequest begins with "POST /v1/chat/completions HTTP/1.1"
   TestAssert "the bearer token", TestRequestHeader("Authorization") is "Bearer sk-local"
   put xtaJsonParse(TestRequestBody()) into tDoc
   TestAssert "the system prompt is the first message", xtaJsonText(xtaJsonGet(tDoc, "messages/1/content")) is "System text"
   TestAssert "the answer", tReply["ok"] is true and tReply["text"] is "Hello"
end TestAskOpenAI

on TestAskRefusedKey
   local tPort, tSettings, tReply
   put TestStartServer("401 Unauthorized", "{" & TestQ("type") & ":" & TestQ("error") & "," & TestQ("error") & ":{" & TestQ("type") & ":" & \
         TestQ("authentication_error") & "," & TestQ("message") & ":" & TestQ("invalid x-api-key") & "}}") into tPort
   put "anthropic" into tSettings["provider"]
   put "http://127.0.0.1:" & tPort into tSettings["baseUrl"]
   put "wrong" into tSettings["key"]
   put "test-model" into tSettings["model"]
   put xtaAsk(tSettings, empty, TestTurns()) into tReply
   TestDiagnostic tReply["error"]
   TestAssert "not ok", tReply["ok"] is false
   TestAssert "says the key was refused", tReply["error"] contains "API key" and tReply["error"] contains "invalid x-api-key"
end TestAskRefusedKey

on TestAskNoServer
   local tPort, tSettings, tReply
   -- A port that was open a moment ago and is closed now
   accept connections on port 0 with message "xtaTestServerAccept"
   put it into tPort
   close socket tPort
   put "openai" into tSettings["provider"]
   put "http://127.0.0.1:" & tPort into tSettings["baseUrl"]
   put "test-model" into tSettings["model"]
   put xtaAsk(tSettings, empty, TestTurns()) into tReply
   TestDiagnostic tReply["error"]
   TestAssert "not ok", tReply["ok"] is false
   TestAssert "says why", tReply["error"] is not empty
end TestAskNoServer

on TestListModels
   local tPort, tSettings, tResult
   put TestStartServer("200 OK", "{" & TestQ("data") & ":[{" & TestQ("id") & ":" & TestQ("model-a") & "}]}") into tPort
   put "anthropic" into tSettings["provider"]
   put "http://127.0.0.1:" & tPort into tSettings["baseUrl"]
   put "sk-local" into tSettings["key"]
   put xtaListModels(tSettings) into tResult
   TestDiagnostic sRequest
   TestAssert "asked for the models", sRequest begins with "GET /v1/models?limit=100 HTTP/1.1"
   TestAssert "with the key", TestRequestHeader("x-api-key") is "sk-local"
   TestAssert "the list", tResult["models"] is "model-a"
end TestListModels
