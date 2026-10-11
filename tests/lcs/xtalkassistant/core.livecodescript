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

-- The guide is marked for Anthropic's cache, and the notes after it are not
private function TestSystemParts
   local tSystem
   put "The guide." into tSystem[1]["text"]
   put true into tSystem[1]["cache"]
   put "The notes." into tSystem[2]["text"]
   put false into tSystem[2]["cache"]
   put empty into tSystem[3]["text"]
   return tSystem
end TestSystemParts

on TestRequestBodySystemParts
   local tBody, tDoc, tSystem
   put xtaRequestBody("anthropic", "m", TestSystemParts(), TestTurns(), empty) into tBody
   TestDiagnostic tBody
   put xtaJsonParse(tBody) into tDoc
   put xtaJsonMember(tDoc, "system") into tSystem
   TestAssert "anthropic: the system is two blocks (the empty part is left out)", \
         xtaJsonType(tSystem) is "array" and xtaJsonCount(tSystem) is 2
   TestAssert "anthropic: the guide first, as text", xtaJsonText(xtaJsonGet(tSystem, "1/type")) is "text" \
         and xtaJsonText(xtaJsonGet(tSystem, "1/text")) is "The guide."
   TestAssert "anthropic: the guide is marked for the cache", xtaJsonText(xtaJsonGet(tSystem, "1/cache_control/type")) is "ephemeral"
   TestAssert "anthropic: the notes are not", xtaJsonText(xtaJsonGet(tSystem, "2/text")) is "The notes." \
         and xtaJsonType(xtaJsonGet(tSystem, "2/cache_control")) is "missing"

   put xtaRequestBody("openai", "m", TestSystemParts(), TestTurns(), empty) into tBody
   put xtaJsonParse(tBody) into tDoc
   TestAssert "openai: one system message, the parts joined in order", \
         xtaJsonText(xtaJsonGet(tDoc, "messages/1/content")) is ("The guide." & return & return & "The notes.")
   TestAssert "openai: no cache marks", not (tBody contains "cache_control")

   -- One part that is not to be cached goes as the plain string it always was
   put empty into tSystem
   put "Be brief." into tSystem[1]["text"]
   TestAssert "one part, not cached: as a text", \
         xtaRequestBody("anthropic", "m", tSystem, TestTurns(), empty) is xtaRequestBody("anthropic", "m", "Be brief.", TestTurns(), empty)
end TestRequestBodySystemParts

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

on TestParseReplyCachedTokens
   local tBody, tReply
   put "{" & TestQ("content") & ":[{" & TestQ("type") & ":" & TestQ("text") & "," & TestQ("text") & ":" & TestQ("x") & "}]," & \
         TestQ("usage") & ":{" & TestQ("input_tokens") & ":12," & TestQ("cache_read_input_tokens") & ":3000," & \
         TestQ("output_tokens") & ":34}}" into tBody
   put xtaParseReply("anthropic", 200, tBody) into tReply
   TestAssert "anthropic: read from the cache", tReply["cachedTokens"] is 3000 and tReply["inputTokens"] is 12
   put "{" & TestQ("choices") & ":[{" & TestQ("message") & ":{" & TestQ("content") & ":" & TestQ("x") & "}}]," & \
         TestQ("usage") & ":{" & TestQ("prompt_tokens") & ":2000," & TestQ("completion_tokens") & ":7," & \
         TestQ("prompt_tokens_details") & ":{" & TestQ("cached_tokens") & ":1024}}}" into tBody
   put xtaParseReply("openai", 200, tBody) into tReply
   TestAssert "openai: read from the cache", tReply["cachedTokens"] is 1024 and tReply["inputTokens"] is 2000
end TestParseReplyCachedTokens

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
   TestAssert "the default is the first listed, without a Sonnet", tResult["default"] is "model-a"
   put xtaParseModels("openai", 200, "{" & TestQ("data") & ":[]}") into tResult
   TestAssert "none", tResult["error"] is not empty
   -- OpenAI's list, in no order, with when each model was made
   put "{" & TestQ("data") & ":[" & TestModelEntry("text-embedding-3-small", 1705948997) & "," & \
         TestModelEntry("gpt-5.1", 1762000000) & "," & TestModelEntry("gpt-4o", 1715367049) & "," & \
         TestModelEntry("gpt-5.2-mini", 1765000000) & "," & TestModelEntry("tts-1", 1681940951) & "]}" into tBody
   put xtaParseModels("openai", 200, tBody) into tResult
   TestAssert "OpenAI: every model is listed", the number of lines of tResult["models"] is 5
   TestAssert "OpenAI: the newest that is just gpt- and a version", tResult["default"] is "gpt-5.1"
end TestParseModels

-- The model the window begins with when the user has chosen none: a family,
-- never a name built in
on TestDefaultModel
   local tCreated
   TestAssert "Anthropic: the newest Sonnet (its list is newest first)", \
         xtaDefaultModel("anthropic", "claude-opus-9" & return & "claude-sonnet-9" & return & "claude-haiku-9" & return & "claude-sonnet-8", tCreated) is "claude-sonnet-9"
   TestAssert "Anthropic: else the first listed", \
         xtaDefaultModel("anthropic", "claude-opus-9" & return & "claude-haiku-9", tCreated) is "claude-opus-9"
   put 300 into tCreated["gpt-4o"]
   put 200 into tCreated["gpt-5"]
   put 400 into tCreated["gpt-5-mini"]
   put 100 into tCreated["o3"]
   TestAssert "OpenAI: the newest gpt- and a version, not a mini", \
         xtaDefaultModel("openai", "o3" & return & "gpt-5" & return & "gpt-5-mini" & return & "gpt-4o", tCreated) is "gpt-4o"
   TestAssert "a local server: the first listed", \
         xtaDefaultModel("openai", "llama3.2:latest" & return & "qwen2.5-coder:7b", tCreated) is "llama3.2:latest"
   TestAssert "OpenAI without the dates: the first gpt- and a version", \
         xtaDefaultModel("openai", "whisper-1" & return & "gpt-4.1" & return & "gpt-5", empty) is "gpt-4.1"
end TestDefaultModel

private function TestModelEntry pId, pCreated
   return "{" & TestQ("id") & ":" & TestQ(pId) & "," & TestQ("object") & ":" & TestQ("model") & "," & TestQ("created") & ":" & pCreated & "}"
end TestModelEntry

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

on TestXTalkBlocks
   local tBlocks, tXTalk
   put "livecodescript" into tBlocks[1]["lang"]
   put "on a" & return & "end a" into tBlocks[1]["code"]
   put "python" into tBlocks[2]["lang"]
   put "print(1)" into tBlocks[2]["code"]
   put empty into tBlocks[3]["lang"]
   put "put 1" into tBlocks[3]["code"]
   put "memory" into tBlocks[4]["lang"]
   put "you: x" into tBlocks[4]["code"]
   put "LiveCode" into tBlocks[5]["lang"]
   put "beep" into tBlocks[5]["code"]
   put "lcs" into tBlocks[6]["lang"]
   put "  " into tBlocks[6]["code"]
   put xtaXTalkBlocks(tBlocks) into tXTalk
   TestAssert "three xTalk blocks", the number of elements of tXTalk is 3
   TestAssert "in their order", tXTalk[1]["code"] is ("on a" & return & "end a") and tXTalk[2]["code"] is "put 1" \
         and tXTalk[3]["code"] is "beep"
   TestAssert "LiveCode Builder is not xTalk", not xtaIsXTalkLang("livecodebuilder")
   TestAssert "nor a shell", not xtaIsXTalkLang("sh")
   TestAssert "a block with no language is", xtaIsXTalkLang(empty)
end TestXTalkBlocks

--------------------------------------------------------------------------------
-- Checking code

on TestCheckScriptCompiles
   local tCheck
   put xtaCheckScript("local sCount" & return & "-- counts" & return & "on mouseUp pButton" & return & \
         "   local tName" & return & "   put pButton into tName" & return & "   add 1 to sCount" & return & \
         "   repeat with i = 1 to 3" & return & "   end repeat" & return & "end mouseUp", empty) into tCheck
   TestDiagnostic tCheck["issues"]
   TestAssert "whole handlers that compile", tCheck["ok"] is true and tCheck["issues"] is empty
   put xtaCheckScript("put 1 into tX" & return & "answer tX", empty) into tCheck
   TestAssert "statements for the Message Box", tCheck["ok"] is true
   put xtaCheckScript("script " & quote & "MyLib" & quote & return & "on a" & return & "end a", empty) into tCheck
   TestAssert "a script-only stack's first line", tCheck["ok"] is true
   put xtaCheckScript("on a" & return & "   local tX" & return & "   put " & quote & "-- # // not comments" & quote & " into tX" & return & "end a", empty) into tCheck
   TestDiagnostic tCheck["issues"]
   TestAssert "comment marks inside a string", tCheck["ok"] is true
end TestCheckScriptCompiles

on TestCheckScriptCompileErrors
   local tCheck
   put xtaCheckScript("on mouseUp" & return & "   put 1 inot tX" & return & "end mouseUp", empty) into tCheck
   TestDiagnostic tCheck["issues"]
   TestAssert "a compile error", tCheck["ok"] is false
   TestAssert "with its line and column", line 1 of tCheck["issues"] begins with "line 2, column 8:"
   TestAssert "and what is wrong (the message, or in a standalone its number)", line 1 of tCheck["issues"] contains "302"
   TestAssert "near what", line 1 of tCheck["issues"] contains (quote & "inot" & quote)
   put xtaCheckScript("beep" & return & "put 1 inot tX", empty) into tCheck
   TestDiagnostic tCheck["issues"]
   TestAssert "the line of a statement, counted in the block", line 1 of tCheck["issues"] begins with "line 2,"
   put xtaCheckScript("on a" & return & "   refreshList()" & return & "end a", empty) into tCheck
   TestAssert "a command called with brackets (engine note 3.3)", tCheck["ok"] is false
   put xtaCheckScript("function a" & return & "   return 1" & return & "end b", empty) into tCheck
   TestAssert "an end that does not match", tCheck["ok"] is false
end TestCheckScriptCompileErrors

on TestCheckScriptWhatTheEngineDoesNotSay
   local tCheck
   put xtaCheckScript("on a" & return & "end a" & return & "put 1 into tX" & return & "on b" & return & "end b", empty) into tCheck
   TestDiagnostic tCheck["issues"]
   TestAssert "a line outside any handler", tCheck["ok"] is false and tCheck["issues"] contains "line 3: this line is outside any handler"
   put xtaCheckScript("on a" & return & "end a" & return & "command a" & return & "end a" & return & "function a" & return & "end a", empty) into tCheck
   TestDiagnostic tCheck["issues"]
   TestAssert "a handler defined twice", tCheck["ok"] is false and tCheck["issues"] contains "line 3: the command handler a is defined twice (also at line 1)"
   TestAssert "a function of the same name is not a duplicate", the number of lines of tCheck["issues"] is 1
   put xtaCheckScript("on a" & return & "   answer " & numToCodepoint(8220) & "hi" & numToCodepoint(8221) & return & "end a", empty) into tCheck
   TestDiagnostic tCheck["issues"]
   TestAssert "curly quotes (engine note 1.4)", tCheck["ok"] is false and tCheck["issues"] contains "line 2: curly quotes"
   put xtaCheckScript("on a" & return & "/* on b" & return & "end b */" & return & "end a" & return & "on b" & return & "end b", empty) into tCheck
   TestAssert "a handler in a comment is not a handler", tCheck["ok"] is true
end TestCheckScriptWhatTheEngineDoesNotSay

on TestCheckScriptUndeclared
   local tCheck, tScript
   put "on a" & return & "   put sTotal + 1 into tSum" & return & "end a" into tScript
   put xtaCheckScript(tScript, empty) into tCheck
   TestDiagnostic tCheck["issues"]
   TestAssert "a name that is not declared (engine note 2.1)", tCheck["ok"] is false and tCheck["issues"] contains "explicitVariables"
   TestAssert "on its line", line 1 of tCheck["issues"] begins with "line 2"
   put xtaCheckScript("local tSum" & return & tScript, "sTotal") into tCheck
   TestDiagnostic tCheck["issues"]
   TestAssert "names the user's script declares count", tCheck["ok"] is true
   put xtaCheckScript("on a" & return & "   set the style of button 1 to checkbox" & return & "end a", empty) into tCheck
   TestAssert "a literal that is not quoted", tCheck["ok"] is false
   put xtaCheckScript("local sTotal" & return & "on a" & return & "   local tSum" & return & "   put sTotal into tSum" & return & "end a", "sTotal" & return & "tSum") into tCheck
   TestDiagnostic tCheck["issues"]
   TestAssert "a name both declare is not declared twice", tCheck["ok"] is true
   put xtaCheckScript("put tNever into tX", empty) into tCheck
   TestAssert "statements for the Message Box need no declarations", tCheck["ok"] is true
end TestCheckScriptUndeclared

on TestCheckLeavesNothingBehind
   local tOld, tTop, tDefault
   put the explicitVariables into tOld
   put the long id of the topStack into tTop
   put the defaultStack into tDefault
   get xtaCheckScript("on a" & return & "   put x into y" & return & "end a", empty)
   TestAssert "the explicitVariables are put back", the explicitVariables is tOld
   TestAssert "the scratch button keeps no script", the script of button "Check" of stack "revXTalkAssistantCheck" is empty
   TestAssert "its stack is hidden", not the visible of stack "revXTalkAssistantCheck"
   -- Open, even hidden, it became the topStack, which the IDE takes for
   -- the user's stack
   TestAssert "and not open", "revXTalkAssistantCheck" is not among the lines of the openStacks
   TestAssert "the topStack is the same", the long id of the topStack is tTop
   TestAssert "and the defaultStack", the defaultStack is tDefault
   xtaCheckCleanup
   TestAssert "and deleted when the assistant is done", there is not a stack "revXTalkAssistantCheck"
   get xtaCheckScript("on a" & return & "end a", empty)
   TestAssert "made again when needed", there is a stack "revXTalkAssistantCheck"
   xtaCheckCleanup
end TestCheckLeavesNothingBehind

on TestCheckBlocks
   local tBlocks, tCheck
   put "on a" & return & "end a" into tBlocks[1]["code"]
   put "on b" & return & "   put 1 inot x" & return & "end b" into tBlocks[2]["code"]
   put xtaCheckBlocks(tBlocks, empty) into tCheck
   TestDiagnostic tCheck["report"]
   TestAssert "one of two fails", tCheck["ok"] is false and tCheck["blocks"] is 2 and tCheck["failed"] is 1
   TestAssert "the report names the block and the line", line 1 of tCheck["report"] begins with "Compile check:" \
         and line 2 of tCheck["report"] is "In livecodescript block 2:" and line 3 of tCheck["report"] begins with "- line 2,"
   TestAssert "and asks for every block again", the last line of tCheck["report"] contains "every block again"
   TestAssert "the summary says which", tCheck["summary"] contains "block 2"
   TestAssert "the code, to tell a correction from a repeat", tCheck["code"] contains "inot"
   delete variable tBlocks[2]
   put xtaCheckBlocks(tBlocks, empty) into tCheck
   TestAssert "one block that compiles", tCheck["ok"] is true and tCheck["summary"] is "Compile check: the code compiles." \
         and tCheck["report"] is empty
end TestCheckBlocks

on TestDeclaredNames
   local tNames
   put xtaDeclaredNames("local sA, sB = 5" & return & "global gPrefs" & return & "constant kMax = " & quote & "a,b" & quote & ", kMin = 1" & return & \
         "on a pX" & return & "   local tInside" & return & "end a" & return & "local sAfter") into tNames
   TestDiagnostic tNames
   TestAssert "the script's declarations", tNames is ("sA" & return & "sB" & return & "gPrefs" & return & "kMax" & return & "kMin" & return & "sAfter" & return)
end TestDeclaredNames

--------------------------------------------------------------------------------
-- Memory

private function TestMemoryText
   return "# a comment" & return & "[you]" & return & "- Builds for Windows and Linux only." & return & "- Names globals with g." & return & \
         "not a note" & return & "[stack /home/ann/My Stack [1].livecode]" & return & "- The log is in field " & quote & "Log" & quote & "." & return & \
         "[something else]" & return & "- ignored"
end TestMemoryText

on TestMemoryParseAndFormat
   local tMemory, tAgain
   put xtaMemoryParse(TestMemoryText()) into tMemory
   TestAssert "notes about the user", tMemory["you"] is ("Builds for Windows and Linux only." & return & "Names globals with g.")
   TestAssert "notes about a stack, by its path", tMemory["stacks"]["/home/ann/My Stack [1].livecode"] is ("The log is in field " & quote & "Log" & quote & ".")
   TestAssert "nothing else", the number of elements of tMemory["stacks"] is 1
   put xtaMemoryParse(xtaMemoryFormat(tMemory)) into tAgain
   TestAssert "a round trip", tAgain["you"] is tMemory["you"] and tAgain["stacks"]["/home/ann/My Stack [1].livecode"] is tMemory["stacks"]["/home/ann/My Stack [1].livecode"]
   TestAssert "notes about one stack", xtaMemoryNotes(tMemory, "stack", "/home/ann/My Stack [1].livecode") contains "Log"
   TestAssert "no path, no stack notes", xtaMemoryNotes(tMemory, "stack", empty) is empty
end TestMemoryParseAndFormat

on TestMemoryFile
   local tPath, tMemory, tAgain
   put specialFolderPath("temporary") & "/xta-test-memory.txt" into tPath
   if there is a file tPath then
      delete file tPath
   end if
   TestAssert "no file, no notes", xtaMemoryLoad(tPath) is empty
   put xtaMemoryParse(TestMemoryText()) into tMemory
   put "caf" & numToCodepoint(233) into line 3 of tMemory["you"]
   xtaMemorySave tPath, tMemory
   TestAssert "saved", the result is empty and there is a file tPath
   put xtaMemoryLoad(tPath) into tAgain
   TestAssert "read back, in UTF-8", tAgain["you"] is tMemory["you"]
   put empty into tMemory
   xtaMemorySave tPath, tMemory
   TestAssert "no notes, no file", there is not a file tPath
end TestMemoryFile

on TestMemoryNotes
   local tMemory, tLong
   xtaMemorySetNotes tMemory, "you", empty, "  first  " & return & return & "second" & tab & "note"
   TestAssert "notes set, trimmed, without empty lines", the result is empty and tMemory["you"] is ("first" & return & "second note")
   xtaMemoryAdd tMemory, "you", empty, "first"
   TestAssert "a note that is there already is not added again", tMemory["you"] is ("first" & return & "second note")
   xtaMemoryAdd tMemory, "stack", "/a/b.livecode", "about b"
   TestAssert "a note about a stack", tMemory["stacks"]["/a/b.livecode"] is "about b"
   xtaMemoryAdd tMemory, "stack", empty, "about nothing"
   TestAssert "a stack never saved has no notes", the result is not empty
   xtaMemoryAdd tMemory, "you", empty, "My key is sk-ant-api03-abcdefghijklmnop"
   TestAssert "a key is refused", the result contains "key" and not (tMemory["you"] contains "sk-ant")
   TestAssert "a password too", xtaMemoryNoteProblem("password: hunter2") is not empty
   TestAssert "a long run of letters and digits too", xtaMemoryNoteProblem("token 3f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e") is not empty
   TestAssert "a long name is not a key", xtaMemoryNoteProblem("Calls inventoryRefreshEverythingOnTheMainCard first") is empty
   TestAssert "a path is not a key", xtaMemoryNoteProblem("Data is in /Users/ann/Documents/Inventory2024/items.csv") is empty
   repeat 31
      put "0123456789" after tLong
   end repeat
   TestAssert "a long note is refused", xtaMemoryNoteProblem("a " & tLong) is not empty
   repeat 12
      xtaMemoryAdd tMemory, "you", empty, "note" && the number of lines of tMemory["you"] && char 1 to 250 of ("x x " & tLong)
   end repeat
   TestAssert "the notes about the user are kept short", the number of chars of tMemory["you"] <= 3000
end TestMemoryNotes

on TestMemoryPrompt
   local tMemory, tPrompt
   TestAssert "no notes, nothing to say", xtaMemoryPrompt(tMemory, empty, empty) is empty
   put xtaMemoryParse(TestMemoryText()) into tMemory
   put xtaMemoryPrompt(tMemory, "/home/ann/My Stack [1].livecode", "My Stack") into tPrompt
   TestDiagnostic tPrompt
   TestAssert "a heading the guide names", line 1 of tPrompt is "## Notes to keep in mind"
   TestAssert "about the user", tPrompt contains ("About the user:" & return & "- Builds for Windows and Linux only.")
   TestAssert "about the stack, by its name", tPrompt contains ("About the stack " & quote & "My Stack" & quote)
   TestAssert "not its path", not (tPrompt contains "/home/ann")
   put xtaMemoryPrompt(tMemory, "/other.livecode", "Other") into tPrompt
   TestAssert "another stack's notes are not sent", not (tPrompt contains "Log")
end TestMemoryPrompt

on TestMemoryProposals
   local tText, tNotes, tShown
   put "Done." & return & "```livecodescript" & return & "on a" & return & "end a" & return & "```" & return & \
         "```memory" & return & "you: Builds for Windows only." & return & "- stack: Log goes to field " & quote & "Log" & quote & "." & return & \
         return & "Prefers short answers." & return & "```" into tText
   put xtaMemoryProposals(tText) into tNotes
   TestAssert "three notes proposed", the number of elements of tNotes is 3
   TestAssert "about the user", tNotes[1]["scope"] is "you" and tNotes[1]["note"] is "Builds for Windows only."
   TestAssert "about the stack", tNotes[2]["scope"] is "stack" and tNotes[2]["note"] is ("Log goes to field " & quote & "Log" & quote & ".")
   TestAssert "no scope, about the user", tNotes[3]["scope"] is "you" and tNotes[3]["note"] is "Prefers short answers."
   put xtaWithoutMemoryBlocks(tText) into tShown
   TestDiagnostic tShown
   TestAssert "the memory block is not shown", not (tShown contains "Builds for") and not (tShown contains "```memory")
   TestAssert "the rest is", tShown is ("Done." & return & "```livecodescript" & return & "on a" & return & "end a" & return & "```")
end TestMemoryProposals

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
