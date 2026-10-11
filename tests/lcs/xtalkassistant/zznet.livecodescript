script "TestXTalkAssistantNetDiagnostic"
-- TEMPORARY diagnostic, to be removed: the real Anthropic API over https
-- with a made-up key, to see what each platform's libURL answers. Each
-- result is put in a failing assertion's description, so that it shows in
-- the CI log.

on TestSetup
   local tLibUrl
   start using stack (TestGetIDERepositoryPath() & "/Extensions/org.openxtalk.plugin.xtalkassistant/xtalkassistant-core.livecodescript")
   if not TestIsInStandalone() then
      put TestGetEngineRepositoryPath() & "/ide-support/revliburl.livecodescript" into tLibUrl
      send "extensionInitialize" to stack tLibUrl
   end if
end TestSetup

private function diagSettings
   local tSettings
   put "anthropic" into tSettings["provider"]
   put "sk-ant-api03-not-a-real-key" into tSettings["key"]
   put "claude-sonnet-4-5" into tSettings["model"]
   put 100 into tSettings["maxTokens"]
   return tSettings
end diagSettings

on TestDiagModels
   local tStart, tResult, tMs
   put the milliseconds into tStart
   put xtaListModels(diagSettings()) into tResult
   put the milliseconds - tStart into tMs
   TestAssert diagLine("DIAG" && the platform && the processor && "models:" && tResult["error"] && "|" && line 1 of tResult["models"] && "| ms" && tMs), false
end TestDiagModels

on TestDiagAsk
   local tStart, tReply, tMs
   put the milliseconds into tStart
   put xtaAsk(diagSettings(), "Be brief.", xtaDiagTurns()) into tReply
   put the milliseconds - tStart into tMs
   TestAssert diagLine("DIAG" && the platform && "ask:" && tReply["ok"] && "|" && tReply["error"] && "| ms" && tMs), false
end TestDiagAsk

on TestDiagGetUrl
   local tStart, tData, tRes, tMs
   put the milliseconds into tStart
   set the httpHeaders to "User-Agent: OXT-Beyond-diag" & return & "Connection: close"
   get url "https://api.github.com/zen"
   put it into tData
   put the result into tRes
   set the httpHeaders to empty
   put the milliseconds - tStart into tMs
   TestAssert diagLine("DIAG" && the platform && "github get:" && tRes && "|" && char 1 to 60 of tData && "| ms" && tMs), false
end TestDiagGetUrl

on TestDiagLoadUrl
   local tStart, tUrl, tStatus, tMs, tData
   put "https://api.anthropic.com/v1/models?limit=5" into tUrl
   set the httpHeaders to "x-api-key: sk-ant-api03-not-a-real-key" & return & "anthropic-version: 2023-06-01" & return & "User-Agent: OXT-Beyond-diag"
   put the milliseconds into tStart
   load url tUrl
   wait until the urlStatus of tUrl is among the items of "cached,error,timeout" or the milliseconds - tStart > 60000 with messages
   put the urlStatus of tUrl into tStatus
   put the milliseconds - tStart into tMs
   put url tUrl into tData
   unload url tUrl
   set the httpHeaders to empty
   TestAssert diagLine("DIAG" && the platform && "load:" && tStatus && "|" && libUrlErrorData(tUrl) && "|" && char 1 to 80 of tData && "| ms" && tMs), false
end TestDiagLoadUrl

private function diagLine pText
   replace return with " / " in pText
   replace numToChar(13) with "" in pText
   return pText
end diagLine

private function xtaDiagTurns
   local tTurns
   put "user" into tTurns[1]["role"]
   put "Hi" into tTurns[1]["text"]
   return tTurns
end xtaDiagTurns
