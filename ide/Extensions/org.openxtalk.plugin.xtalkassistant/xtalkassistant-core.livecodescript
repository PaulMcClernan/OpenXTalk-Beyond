script "org.openxtalk.plugin.xtalkassistant-core"
-- OXT-Beyond: the core of the xTalk Assistant plugin.
--
-- Everything here works without the IDE: JSON in and out, the requests and
-- answers of the two kinds of provider, the one HTTP call, and the text the
-- assistant shows. The plugin's main stack (xtalkassistant.livecodescript)
-- holds the window, the settings and the IDE glue, and loads this stack with
-- "start using". The engine tests in tests/lcs/xtalkassistant load it the
-- same way and talk to a server of their own, so nothing here needs a key or
-- the internet to be tested.
--
-- Providers:
--    "anthropic"  the Anthropic Messages API (POST <base>/v1/messages, the
--                 key in an x-api-key header). Base: https://api.anthropic.com
--    "openai"     the OpenAI Chat Completions API (POST <base>/chat/completions,
--                 the key as a Bearer token). Base: https://api.openai.com/v1.
--                 Other services and local servers that speak the same API
--                 work with their own base URL; they may need no key.
--
-- No model name is built in: model names change faster than this IDE does.
-- The window asks the provider for its list (xtaModelsUrl, xtaParseModels).
--
-- A conversation is an array of turns, keys 1 to N, each with "role"
-- ("user" or "assistant") and "text".
--
-- Public handlers:
--    xtaJsonString(pText)                  pText as a JSON string
--    xtaJsonParse(pJSON)                   a parsed value (see "JSON in")
--    xtaJsonType, xtaJsonCount, xtaJsonItem, xtaJsonMember, xtaJsonText,
--    xtaJsonGet, xtaJsonRaw                read a parsed value
--    xtaProviders()                        "anthropic,openai"
--    xtaDefaultBaseUrl(pProvider)
--    xtaRequestUrl(pProvider, pBaseUrl), xtaModelsUrl(pProvider, pBaseUrl)
--    xtaRequestHeaders(pProvider, pKey)    header lines for the httpHeaders
--    xtaRequestBody(pProvider, pModel, pSystem, pTurns, pMaxTokens)
--    xtaParseReply(pProvider, pStatus, pBody)
--    xtaParseModels(pProvider, pStatus, pBody)
--    xtaHttpPost(pUrl, pHeaders, pBody), xtaHttpGet(pUrl, pHeaders)
--    xtaAsk(pSettings, pSystem, pTurns)    one round trip, as xtaParseReply
--    xtaCodeBlocks(pText)                  the fenced code blocks of a reply
--    xtaSystemPrompt()                     what the assistant is told first

-- Anthropic's API version header; the Messages API has used this one since
-- it was introduced.
constant kAnthropicVersion = "2023-06-01"
constant kAnthropicBaseUrl = "https://api.anthropic.com"
constant kOpenAIBaseUrl = "https://api.openai.com/v1"
-- Anthropic requires max_tokens; this is used when the settings give none.
constant kDefaultMaxTokens = 4096
-- How long a request may go without data. A model can think for a while
-- before the first byte of a (non-streamed) answer arrives, and libURL
-- gives up after the engine's socketTimeoutInterval (10 seconds by default).
constant kRequestTimeoutMilliseconds = 180000
-- How deeply JSON may nest before the reader refuses it.
constant kJsonMaxDepth = 64

-- The JSON reader's state while it reads one text: the text, where it is,
-- the length in code units, the nesting depth, and the position of the next
-- backslash at or after sJPos (0 when there is none left, -1 when it has not
-- been looked for yet).
local sJText, sJPos, sJLen, sJDepth, sJNextBackslash

--------------------------------------------------------------------------------
-- JSON out

-- pText as a JSON string, with its quotes. Backslash, quote and the control
-- characters are escaped; everything else goes as it is, and the caller
-- encodes the whole request as UTF-8. The engine's "replace" works on code
-- units, so a quote followed by a combining mark is still found and escaped.
function xtaJsonString pText
   local tOut, tCode
   put pText into tOut
   replace numToChar(92) with numToChar(92) & numToChar(92) in tOut
   replace quote with numToChar(92) & quote in tOut
   replace numToChar(10) with numToChar(92) & "n" in tOut
   replace numToChar(13) with numToChar(92) & "r" in tOut
   replace numToChar(9) with numToChar(92) & "t" in tOut
   repeat with tCode = 0 to 31
      if tCode is 9 or tCode is 10 or tCode is 13 then
         next repeat
      end if
      if numToChar(tCode) is in tOut then
         replace numToChar(tCode) with numToChar(92) & "u00" & xtaHexByte(tCode) in tOut
      end if
   end repeat
   return quote & tOut & quote
end xtaJsonString

private function xtaHexByte pCode
   local tHex
   put toLower(baseConvert(pCode, 10, 16)) into tHex
   if the number of chars of tHex < 2 then
      put "0" before tHex
   end if
   return tHex
end xtaHexByte

private function xtaJsonPair pName, pJson
   return xtaJsonString(pName) & ":" & pJson
end xtaJsonPair

--------------------------------------------------------------------------------
-- JSON in
--
-- A parsed value is an array with "type" ("object", "array", "string",
-- "number", "boolean" or "null"), "from" and "to" (where it is in the text,
-- in code units, so xtaJsonRaw can give it back exactly as it was sent), and
-- by type:
--    object   "count", "names" (1 to count, in the order they came) and
--             "members" (the values, by name)
--    array    "count" and "items" (1 to count)
--    other    "value" ("true" or "false" for a boolean, empty for null, the
--             number as written)
-- The engine's array keys ignore case, so two member names that differ only
-- in case are one member here (the later one wins). The APIs read here use
-- lower-case names.

function xtaJsonParse pJSON
   local tNode
   put pJSON into sJText
   put 1 into sJPos
   put the number of codeunits of pJSON into sJLen
   put 0 into sJDepth
   put -1 into sJNextBackslash
   put xtaJValue() into tNode
   xtaJSkip
   if sJPos <= sJLen then
      xtaJFail "there is more text after the value"
   end if
   put empty into sJText
   return tNode
end xtaJsonParse

private command xtaJFail pWhat
   put empty into sJText
   throw "xTalk Assistant: the JSON is not valid:" && pWhat && "(at character" && sJPos & ")"
end xtaJFail

private command xtaJSkip
   local tC
   repeat while sJPos <= sJLen
      put codeunit sJPos of sJText into tC
      if tC is space or tC is tab or tC is numToChar(10) or tC is numToChar(13) then
         add 1 to sJPos
      else
         exit repeat
      end if
   end repeat
end xtaJSkip

private function xtaJValue
   local tC, tNode
   xtaJSkip
   if sJPos > sJLen then
      xtaJFail "a value is missing"
   end if
   put codeunit sJPos of sJText into tC
   if tC is "{" then
      return xtaJObject()
   end if
   if tC is "[" then
      return xtaJArray()
   end if
   put sJPos into tNode["from"]
   if tC is quote then
      put "string" into tNode["type"]
      put xtaJStringBody() into tNode["value"]
   else if codeunit sJPos to sJPos + 3 of sJText is "true" then
      put "boolean" into tNode["type"]
      put "true" into tNode["value"]
      add 4 to sJPos
   else if codeunit sJPos to sJPos + 4 of sJText is "false" then
      put "boolean" into tNode["type"]
      put "false" into tNode["value"]
      add 5 to sJPos
   else if codeunit sJPos to sJPos + 3 of sJText is "null" then
      put "null" into tNode["type"]
      put empty into tNode["value"]
      add 4 to sJPos
   else
      put "number" into tNode["type"]
      put xtaJNumber() into tNode["value"]
   end if
   put sJPos - 1 into tNode["to"]
   return tNode
end xtaJValue

private function xtaJObject
   local tNode, tName, tCount, tC, tChild
   put "object" into tNode["type"]
   put sJPos into tNode["from"]
   add 1 to sJDepth
   if sJDepth > kJsonMaxDepth then
      xtaJFail "it nests too deeply"
   end if
   add 1 to sJPos
   put 0 into tCount
   xtaJSkip
   if codeunit sJPos of sJText is "}" then
      add 1 to sJPos
   else
      repeat forever
         xtaJSkip
         if sJPos > sJLen or codeunit sJPos of sJText is not quote then
            xtaJFail "a member name must be a string"
         end if
         put xtaJStringBody() into tName
         xtaJSkip
         if sJPos > sJLen or codeunit sJPos of sJText is not ":" then
            xtaJFail "a colon is missing after a member name"
         end if
         add 1 to sJPos
         put xtaJValue() into tChild
         add 1 to tCount
         put tName into tNode["names"][tCount]
         put tChild into tNode["members"][tName]
         xtaJSkip
         if sJPos > sJLen then
            xtaJFail "an object is not closed"
         end if
         put codeunit sJPos of sJText into tC
         add 1 to sJPos
         if tC is "}" then
            exit repeat
         end if
         if tC is not comma then
            xtaJFail "a comma or a closing brace is missing"
         end if
      end repeat
   end if
   put tCount into tNode["count"]
   put sJPos - 1 into tNode["to"]
   subtract 1 from sJDepth
   return tNode
end xtaJObject

private function xtaJArray
   local tNode, tCount, tC, tChild
   put "array" into tNode["type"]
   put sJPos into tNode["from"]
   add 1 to sJDepth
   if sJDepth > kJsonMaxDepth then
      xtaJFail "it nests too deeply"
   end if
   add 1 to sJPos
   put 0 into tCount
   xtaJSkip
   if codeunit sJPos of sJText is "]" then
      add 1 to sJPos
   else
      repeat forever
         put xtaJValue() into tChild
         add 1 to tCount
         put tChild into tNode["items"][tCount]
         xtaJSkip
         if sJPos > sJLen then
            xtaJFail "an array is not closed"
         end if
         put codeunit sJPos of sJText into tC
         add 1 to sJPos
         if tC is "]" then
            exit repeat
         end if
         if tC is not comma then
            xtaJFail "a comma or a closing bracket is missing"
         end if
      end repeat
   end if
   put tCount into tNode["count"]
   put sJPos - 1 into tNode["to"]
   subtract 1 from sJDepth
   return tNode
end xtaJArray

-- The text of the string that starts at sJPos (its opening quote), with its
-- escapes undone; sJPos ends after the closing quote.
private function xtaJStringBody
   local tOut, tQuote, tC, tCode, tLow
   add 1 to sJPos
   put empty into tOut
   repeat forever
      put xtaFindFrom(quote, sJText, sJPos) into tQuote
      if tQuote is 0 then
         xtaJFail "a string is not closed"
      end if
      if sJNextBackslash is not 0 and sJNextBackslash < sJPos then
         put xtaFindFrom(numToChar(92), sJText, sJPos) into sJNextBackslash
      end if
      if sJNextBackslash is 0 or sJNextBackslash > tQuote then
         if tQuote > sJPos then
            put codeunit sJPos to tQuote - 1 of sJText after tOut
         end if
         put tQuote + 1 into sJPos
         return tOut
      end if
      if sJNextBackslash > sJPos then
         put codeunit sJPos to sJNextBackslash - 1 of sJText after tOut
      end if
      put codeunit sJNextBackslash + 1 of sJText into tC
      put sJNextBackslash + 2 into sJPos
      switch tC
         case quote
         case "/"
            put tC after tOut
            break
         case numToChar(92)
            put numToChar(92) after tOut
            break
         case "n"
            put numToChar(10) after tOut
            break
         case "r"
            put numToChar(13) after tOut
            break
         case "t"
            put numToChar(9) after tOut
            break
         case "b"
            put numToChar(8) after tOut
            break
         case "f"
            put numToChar(12) after tOut
            break
         case "u"
            put xtaJHex4(sJPos) into tCode
            add 4 to sJPos
            if tCode >= 55296 and tCode <= 56319 then
               -- A high surrogate: with the low one after it, the two make
               -- one code point; alone, it stands for nothing printable.
               put empty into tLow
               if codeunit sJPos to sJPos + 1 of sJText is (numToChar(92) & "u") then
                  put xtaJHex4(sJPos + 2) into tLow
               end if
               if tLow is an integer and tLow >= 56320 and tLow <= 57343 then
                  put 65536 + (tCode - 55296) * 1024 + (tLow - 56320) into tCode
                  add 6 to sJPos
               else
                  put 65533 into tCode
               end if
            else if tCode >= 56320 and tCode <= 57343 then
               put 65533 into tCode
            end if
            put numToCodepoint(tCode) after tOut
            break
         default
            xtaJFail "a string has an unknown escape"
            break
      end switch
   end repeat
end xtaJStringBody

private function xtaJHex4 pAt
   local tHex
   put codeunit pAt to pAt + 3 of sJText into tHex
   if not matchText(tHex, "^[0-9A-Fa-f]{4}$") then
      xtaJFail "a \u escape needs four hexadecimal digits"
   end if
   return baseConvert(tHex, 16, 10)
end xtaJHex4

private function xtaJNumber
   local tStart, tC, tText
   put sJPos into tStart
   repeat while sJPos <= sJLen
      put codeunit sJPos of sJText into tC
      if tC is empty or tC is not in "0123456789+-.eE" then
         exit repeat
      end if
      add 1 to sJPos
   end repeat
   if sJPos > tStart then
      put codeunit tStart to sJPos - 1 of sJText into tText
   end if
   if not matchText(tText, "^-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-]?[0-9]+)?$") then
      xtaJFail "a value is not a string, number, object, array, true, false or null"
   end if
   return tText
end xtaJNumber

-- Where pNeedle first occurs in pText at or after code unit pStart, or 0.
-- On the 0.2.5-rc.1 engine (Linux), codeunitOffset() answers the position
-- from the start of the text even when it is given a number of code units to
-- skip, unlike offset(), which answers it from the skipped part. Both
-- readings are checked here so that the answer is right either way: a match
-- at a position at or after pStart is the first such match only if the
-- engine counts from the start.
private function xtaFindFrom pNeedle, pText, pStart
   local tFound
   put codeunitOffset(pNeedle, pText, pStart - 1) into tFound
   if tFound is 0 then
      return 0
   end if
   if tFound >= pStart and codeunit tFound to tFound + the number of codeunits of pNeedle - 1 of pText is pNeedle then
      return tFound
   end if
   return tFound + pStart - 1
end xtaFindFrom

-- "missing" for a value that is not there, else its type.
function xtaJsonType pNode
   if pNode is not an array then
      return "missing"
   end if
   if pNode["type"] is empty then
      return "missing"
   end if
   return pNode["type"]
end xtaJsonType

function xtaJsonCount pNode
   if pNode is not an array then
      return 0
   end if
   if pNode["type"] is "object" or pNode["type"] is "array" then
      return pNode["count"]
   end if
   return 0
end xtaJsonCount

-- Item pIndex (1 to count) of an array.
function xtaJsonItem pNode, pIndex
   local tEmpty
   if xtaJsonType(pNode) is not "array" then
      return tEmpty
   end if
   if pIndex is not an integer then
      return tEmpty
   end if
   return pNode["items"][pIndex]
end xtaJsonItem

function xtaJsonMember pNode, pName
   local tEmpty
   if xtaJsonType(pNode) is not "object" then
      return tEmpty
   end if
   return pNode["members"][pName]
end xtaJsonMember

-- A string or number as text, a boolean as "true" or "false"; empty for
-- null, an object, an array or a missing value.
function xtaJsonText pNode
   local tType
   put xtaJsonType(pNode) into tType
   if tType is "string" or tType is "number" or tType is "boolean" then
      return pNode["value"]
   end if
   return empty
end xtaJsonText

-- The value at a "/"-separated path of member names and item numbers, for
-- example "choices/1/message/content".
function xtaJsonGet pNode, pPath
   local tNode, tStep, tEmpty
   put pNode into tNode
   set the itemDelimiter to "/"
   repeat for each item tStep in pPath
      if tStep is empty then
         next repeat
      end if
      if xtaJsonType(tNode) is "array" then
         put xtaJsonItem(tNode, tStep) into tNode
      else if xtaJsonType(tNode) is "object" then
         put xtaJsonMember(tNode, tStep) into tNode
      else
         return tEmpty
      end if
   end repeat
   return tNode
end xtaJsonGet

-- The text a parsed value came from, exactly as it was in pJSON.
function xtaJsonRaw pJSON, pNode
   if xtaJsonType(pNode) is "missing" then
      return empty
   end if
   return codeunit pNode["from"] to pNode["to"] of pJSON
end xtaJsonRaw

--------------------------------------------------------------------------------
-- Providers

function xtaProviders
   return "anthropic,openai"
end xtaProviders

function xtaProviderName pProvider
   switch pProvider
      case "anthropic"
         return "Anthropic"
      case "openai"
         return "OpenAI (or compatible)"
   end switch
   return pProvider
end xtaProviderName

function xtaDefaultBaseUrl pProvider
   switch pProvider
      case "anthropic"
         return kAnthropicBaseUrl
      case "openai"
         return kOpenAIBaseUrl
   end switch
   return empty
end xtaDefaultBaseUrl

private function xtaBase pProvider, pBaseUrl
   local tBase
   put word 1 to -1 of pBaseUrl into tBase
   if tBase is empty then
      put xtaDefaultBaseUrl(pProvider) into tBase
   end if
   repeat while the last char of tBase is "/"
      delete the last char of tBase
   end repeat
   return tBase
end xtaBase

function xtaRequestUrl pProvider, pBaseUrl
   switch pProvider
      case "anthropic"
         return xtaBase(pProvider, pBaseUrl) & "/v1/messages"
      case "openai"
         return xtaBase(pProvider, pBaseUrl) & "/chat/completions"
   end switch
   return empty
end xtaRequestUrl

function xtaModelsUrl pProvider, pBaseUrl
   switch pProvider
      case "anthropic"
         return xtaBase(pProvider, pBaseUrl) & "/v1/models?limit=100"
      case "openai"
         return xtaBase(pProvider, pBaseUrl) & "/models"
   end switch
   return empty
end xtaModelsUrl

-- The header lines of a request, for the httpHeaders. A key with a line
-- break in it is refused: it would add header lines of its own.
function xtaRequestHeaders pProvider, pKey
   local tKey, tHeaders
   put word 1 to -1 of pKey into tKey
   if tKey contains numToChar(10) or tKey contains numToChar(13) then
      throw "xTalk Assistant: the API key has a line break in it."
   end if
   put "Content-Type: application/json" & return & "Accept: application/json" into tHeaders
   -- libURL can stall on a kept-alive connection (oxtbeyondupdater.livecodescript)
   put return & "Connection: close" after tHeaders
   switch pProvider
      case "anthropic"
         put return & "anthropic-version:" && kAnthropicVersion after tHeaders
         if tKey is not empty then
            put return & "x-api-key:" && tKey after tHeaders
         end if
         break
      case "openai"
         if tKey is not empty then
            put return & "Authorization: Bearer" && tKey after tHeaders
         end if
         break
   end switch
   return tHeaders
end xtaRequestHeaders

-- The JSON of a request. pTurns is the conversation (keys 1 to N, "role" and
-- "text"); turns with no text are left out, as both APIs refuse them.
function xtaRequestBody pProvider, pModel, pSystem, pTurns, pMaxTokens
   local tMessages, tIndex, tRole, tMax, tBody
   if word 1 to -1 of pModel is empty then
      throw "xTalk Assistant: no model is chosen."
   end if
   put empty into tMessages
   if pProvider is "openai" and pSystem is not empty then
      put "{" & xtaJsonPair("role", xtaJsonString("system")) & comma & \
            xtaJsonPair("content", xtaJsonString(pSystem)) & "}" into tMessages
   end if
   repeat with tIndex = 1 to the number of elements of pTurns
      if pTurns[tIndex]["text"] is empty then
         next repeat
      end if
      put pTurns[tIndex]["role"] into tRole
      if tRole is not "assistant" then
         put "user" into tRole
      end if
      if tMessages is not empty then
         put comma after tMessages
      end if
      put "{" & xtaJsonPair("role", xtaJsonString(tRole)) & comma & \
            xtaJsonPair("content", xtaJsonString(pTurns[tIndex]["text"])) & "}" after tMessages
   end repeat

   put "{" & xtaJsonPair("model", xtaJsonString(word 1 to -1 of pModel)) into tBody
   if pProvider is "anthropic" then
      put pMaxTokens into tMax
      if tMax is not an integer or tMax < 1 then
         put kDefaultMaxTokens into tMax
      end if
      put comma & xtaJsonPair("max_tokens", tMax + 0) after tBody
      if pSystem is not empty then
         put comma & xtaJsonPair("system", xtaJsonString(pSystem)) after tBody
      end if
   end if
   put comma & xtaJsonPair("messages", "[" & tMessages & "]") & "}" after tBody
   return tBody
end xtaRequestBody

-- What an answer says. pStatus is the HTTP status (200 for success), or
-- empty when no answer came; pBody is the answer's text. Returns an array:
--    ok            true when the model answered
--    text          what it said (all its text parts, in order)
--    stop          why it stopped (the provider's word, such as "end_turn",
--                  "stop", "max_tokens" or "length")
--    inputTokens, outputTokens   what the request cost, when the answer says
--    error         why there is no answer, in words for the user
function xtaParseReply pProvider, pStatus, pBody
   local tReply, tDoc, tError, tParts, tIndex, tPart, tText
   put false into tReply["ok"]
   try
      put xtaJsonParse(pBody) into tDoc
   catch tError
      put empty into tDoc
   end try

   put xtaApiError(pProvider, pStatus, pBody, tDoc) into tError
   if tError is not empty then
      put tError into tReply["error"]
      return tReply
   end if

   switch pProvider
      case "anthropic"
         put xtaJsonMember(tDoc, "content") into tParts
         repeat with tIndex = 1 to xtaJsonCount(tParts)
            put xtaJsonItem(tParts, tIndex) into tPart
            if xtaJsonText(xtaJsonMember(tPart, "type")) is "text" then
               put xtaJsonText(xtaJsonMember(tPart, "text")) after tText
            end if
         end repeat
         put xtaJsonText(xtaJsonMember(tDoc, "stop_reason")) into tReply["stop"]
         put xtaJsonText(xtaJsonGet(tDoc, "usage/input_tokens")) into tReply["inputTokens"]
         put xtaJsonText(xtaJsonGet(tDoc, "usage/output_tokens")) into tReply["outputTokens"]
         if xtaJsonType(tParts) is not "array" then
            put "The answer had no content." into tReply["error"]
            return tReply
         end if
         break
      case "openai"
         put xtaJsonGet(tDoc, "choices/1/message/content") into tPart
         if xtaJsonType(xtaJsonGet(tDoc, "choices/1/message")) is not "object" then
            put "The answer had no message." into tReply["error"]
            return tReply
         end if
         put xtaJsonText(tPart) into tText
         put xtaJsonText(xtaJsonGet(tDoc, "choices/1/finish_reason")) into tReply["stop"]
         put xtaJsonText(xtaJsonGet(tDoc, "usage/prompt_tokens")) into tReply["inputTokens"]
         put xtaJsonText(xtaJsonGet(tDoc, "usage/completion_tokens")) into tReply["outputTokens"]
         break
      default
         put "Unknown provider" && quote & pProvider & quote & "." into tReply["error"]
         return tReply
   end switch

   put tText into tReply["text"]
   put true into tReply["ok"]
   return tReply
end xtaParseReply

-- Why an answer is not a success, in words for the user, or empty when it
-- is one. The providers put their reason in error/message.
private function xtaApiError pProvider, pStatus, pBody, pDoc
   local tMessage, tError
   if pStatus is empty then
      return "No answer came from the server."
   end if
   put xtaJsonText(xtaJsonGet(pDoc, "error/message")) into tMessage
   if tMessage is empty then
      -- Some OpenAI-compatible servers send the error as a plain string.
      put xtaJsonText(xtaJsonMember(pDoc, "error")) into tMessage
   end if
   if pStatus is 200 and tMessage is empty and xtaJsonType(pDoc) is "object" then
      return empty
   end if
   if pStatus is 200 and tMessage is empty then
      return "The answer was not JSON:" && xtaFirstLine(pBody)
   end if

   switch pStatus
      case 401
         put "The provider did not accept the API key." into tError
         break
      case 403
         put "The provider refused the request (403)." into tError
         break
      case 404
         put "The provider has no such address or model (404). Check the base URL and the model." into tError
         break
      case 429
         put "The provider says there were too many requests, or the account has run out of credit (429)." into tError
         break
      case 529
         put "The provider is overloaded (529). Try again in a moment." into tError
         break
      default
         if pStatus is 200 then
            put "The provider answered with an error." into tError
         else
            put "The provider answered with an error (" & pStatus & ")." into tError
         end if
         break
   end switch
   if tMessage is not empty then
      put return & tMessage after tError
   else if pBody is not empty then
      put return & xtaFirstLine(pBody) after tError
   end if
   return tError
end xtaApiError

private function xtaFirstLine pText
   local tLine
   put line 1 of pText into tLine
   if the number of chars of tLine > 200 then
      put char 1 to 200 of tLine & "..." into tLine
   end if
   return tLine
end xtaFirstLine

-- The model names in an answer to xtaModelsUrl, one per line, or an array
-- with "error" when there are none.
function xtaParseModels pProvider, pStatus, pBody
   local tDoc, tError, tData, tIndex, tIds, tResult
   try
      put xtaJsonParse(pBody) into tDoc
   catch tError
      put empty into tDoc
   end try
   put xtaApiError(pProvider, pStatus, pBody, tDoc) into tError
   if tError is not empty then
      put tError into tResult["error"]
      return tResult
   end if
   put xtaJsonMember(tDoc, "data") into tData
   repeat with tIndex = 1 to xtaJsonCount(tData)
      if tIds is not empty then
         put return after tIds
      end if
      put xtaJsonText(xtaJsonGet(tData, tIndex & "/id")) after tIds
   end repeat
   filter lines of tIds without empty
   if tIds is empty then
      put "The provider listed no models." into tResult["error"]
      return tResult
   end if
   put tIds into tResult["models"]
   return tResult
end xtaParseModels

--------------------------------------------------------------------------------
-- HTTP
--
-- One request at a time, through libURL (the engine's "post" and "get"),
-- which waits for the answer while the IDE keeps handling events. The
-- httpHeaders and the socketTimeoutInterval are global, so both are set
-- only for the request and put back afterwards, the key never staying in
-- the httpHeaders. Returns an array: status (the HTTP status, or empty when
-- no answer came), body (the answer as text) and error (why there was no
-- answer).

function xtaHttpPost pUrl, pHeaders, pBody
   return xtaHttp("post", pUrl, pHeaders, pBody)
end xtaHttpPost

function xtaHttpGet pUrl, pHeaders
   return xtaHttp("get", pUrl, pHeaders, empty)
end xtaHttpGet

private function xtaHttp pMethod, pUrl, pHeaders, pBody
   local tOldHeaders, tOldTimeout, tData, tResult, tError, tAnswer
   put the httpHeaders into tOldHeaders
   put the socketTimeoutInterval into tOldTimeout
   set the httpHeaders to pHeaders
   set the socketTimeoutInterval to kRequestTimeoutMilliseconds
   try
      if pMethod is "post" then
         post textEncode(pBody, "UTF-8") to url pUrl
      else
         get url pUrl
      end if
      put it into tData
      put the result into tResult
   catch tError
      put "error" && tError into tResult
   end try
   set the httpHeaders to tOldHeaders
   set the socketTimeoutInterval to tOldTimeout

   -- libURL leaves the result empty for a success; an HTTP error answer
   -- gives "error <status> <reason>" with the answer's body in "it".
   -- Anything else means no answer came.
   if tResult is empty then
      put 200 into tAnswer["status"]
   else if word 1 of tResult is "error" and word 2 of tResult is an integer \
         and the number of chars of word 2 of tResult is 3 then
      put word 2 of tResult into tAnswer["status"]
   else
      put empty into tAnswer["status"]
      if tResult contains "timeout" then
         put "The server did not answer in time." into tAnswer["error"]
      else
         put "The server could not be reached:" && line 1 of tResult into tAnswer["error"]
      end if
      return tAnswer
   end if
   try
      put textDecode(tData, "UTF-8") into tAnswer["body"]
   catch tError
      put tData into tAnswer["body"]
   end try
   return tAnswer
end xtaHttp

-- One round trip: sends the conversation and returns what xtaParseReply
-- does. pSettings has "provider", "baseUrl", "key", "model" and "maxTokens".
function xtaAsk pSettings, pSystem, pTurns
   local tProvider, tHeaders, tBody, tAnswer, tReply, tError
   put pSettings["provider"] into tProvider
   try
      put xtaRequestHeaders(tProvider, pSettings["key"]) into tHeaders
      put xtaRequestBody(tProvider, pSettings["model"], pSystem, pTurns, pSettings["maxTokens"]) into tBody
   catch tError
      put false into tReply["ok"]
      put xtaPlainError(tError) into tReply["error"]
      return tReply
   end try
   put xtaHttpPost(xtaRequestUrl(tProvider, pSettings["baseUrl"]), tHeaders, tBody) into tAnswer
   put empty into tHeaders
   if tAnswer["status"] is empty then
      put false into tReply["ok"]
      put tAnswer["error"] into tReply["error"]
      return tReply
   end if
   return xtaParseReply(tProvider, tAnswer["status"], tAnswer["body"])
end xtaAsk

-- The model names the provider offers, as xtaParseModels returns them.
function xtaListModels pSettings
   local tProvider, tHeaders, tAnswer, tResult, tError
   put pSettings["provider"] into tProvider
   try
      put xtaRequestHeaders(tProvider, pSettings["key"]) into tHeaders
   catch tError
      put xtaPlainError(tError) into tResult["error"]
      return tResult
   end try
   -- Anthropic's model list wants the version header too; neither list
   -- needs a body, so the Content-Type line does no harm.
   put xtaHttpGet(xtaModelsUrl(tProvider, pSettings["baseUrl"]), tHeaders) into tAnswer
   put empty into tHeaders
   if tAnswer["status"] is empty then
      put tAnswer["error"] into tResult["error"]
      return tResult
   end if
   return xtaParseModels(tProvider, tAnswer["status"], tAnswer["body"])
end xtaListModels

-- A thrown error as the words after "xTalk Assistant: ", for the user.
function xtaPlainError pError
   local tText
   put line 1 of pError into tText
   if tText begins with "xTalk Assistant: " then
      delete char 1 to the number of chars of "xTalk Assistant: " of tText
   end if
   return tText
end xtaPlainError

--------------------------------------------------------------------------------
-- Replies

-- The fenced code blocks of a reply (``` lines), keys 1 to N, each with
-- "lang" (the word after the opening fence, possibly empty) and "code".
-- A block that is never closed runs to the end of the reply.
function xtaCodeBlocks pText
   local tBlocks, tCount, tInside, tLine, tCode, tLang
   put 0 into tCount
   put false into tInside
   repeat for each line tLine in pText
      if word 1 to -1 of tLine begins with "```" then
         if tInside then
            xtaAddBlock tBlocks, tCount, tLang, tCode
            put false into tInside
         else
            put true into tInside
            put word 1 to -1 of tLine into tLang
            delete char 1 to 3 of tLang
            put word 1 of tLang into tLang
            put empty into tCode
         end if
         next repeat
      end if
      if tInside then
         put tLine & return after tCode
      end if
   end repeat
   if tInside then
      xtaAddBlock tBlocks, tCount, tLang, tCode
   end if
   return tBlocks
end xtaCodeBlocks

-- Adds a block to xBlocks, without the return after its last line.
private command xtaAddBlock @xBlocks, @xCount, pLang, pCode
   if pCode is not empty then
      delete the last char of pCode
   end if
   add 1 to xCount
   put pLang into xBlocks[xCount]["lang"]
   put pCode into xBlocks[xCount]["code"]
end xtaAddBlock

-- What the assistant is told before the conversation. It names the language
-- and the engine, and the behaviours of this engine that code written for
-- other xTalks (or by habit) gets wrong; the numbers in brackets are those of
-- xtalk-suite's docs/OXT-ENGINE-NOTES.md, where each one is recorded.
function xtaSystemPrompt
   local tPrompt
   put "You are the xTalk Assistant inside OXT-Beyond, a free development environment" && \
         "that continues OpenXTalk Lite and LiveCode Community 9.x. Its users build" && \
         "programs from stacks, cards and controls (buttons, fields, graphics, images," && \
         "groups, widgets) and script them in LiveCode Script, the English-like xTalk" && \
         "language of the HyperCard tradition." & return & return into tPrompt
   put "When you write code:" & return after tPrompt
   put "- Write LiveCode Script for this engine, not HyperTalk, AppleScript or JavaScript." && \
         "Put each script in a fenced block marked livecodescript, holding whole handlers" && \
         "(on ... end, command ... end, function ... end), so the user can insert it into" && \
         "the Script Editor as it is." & return after tPrompt
   put "- Say which object each script belongs to (the button, the card, the stack)." & return after tPrompt
   put "- Declare every variable with local, and every script-level local or constant" && \
         "above the first handler that uses it: an undeclared name is not an error, it" && \
         "evaluates to its own name (1.2, 2.1). Constants must be literal values (1.3)." & return after tPrompt
   put "- Use only straight ASCII quotes; curly quotes stop a script from compiling," && \
         "even in a comment (1.4)." & return after tPrompt
   put "- and and or evaluate both operands; there is no short-circuit. Put a guard in" && \
         "its own if before the expression it protects (2.5)." & return after tPrompt
   put "- Write a call to a command with no parameters without brackets: myCommand," && \
         "not myCommand() (3.3)." & return after tPrompt
   put "- A throw inside a catch block does not reach the caller: keep the error in a" && \
         "variable and throw after end try (3.2)." & return after tPrompt
   put "- Handlers reached by send, dispatch or a callback message must not be private (3.5)." & return after tPrompt
   put "- Array keys ignore case: tA[" & quote & "A" & quote & "] and tA[" & quote & "a" & quote & "] are one element (2.7)." & return after tPrompt
   put "- In a handler reached by send ... in, a socket or URL callback, name controls" && \
         "with their stack, or set the defaultStack first (5.3)." & return after tPrompt
   put "- If you are not sure a command, function or property exists in LiveCode 9," && \
         "say so rather than inventing one." & return & return after tPrompt
   put "Keep explanations short and plain. When the user shares a script, refer to" && \
         "its handlers by name." after tPrompt
   return tPrompt
end xtaSystemPrompt
