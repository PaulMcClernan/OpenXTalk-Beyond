script "TestMcpBridgeTools"
-- OXT-Beyond: tests of the OXT side of the xTalk MCP Bridge
-- (ide/Extensions/org.openxtalk.plugin.mcpbridge/mcpbridge-tools.livecodescript),
-- loaded with the xTalk Assistant's core and build library as the plugin
-- loads them, with a stand-in for the IDE handlers they tell and for the
-- plugin's main stack, which asks the user: that the server listens on
-- 127.0.0.1, writes its port and token and deletes them when it stops,
-- that a request without the token is refused, that the tools read, build,
-- run and undo through the requests the MCP server sends, that code which
-- reaches what cannot be undone runs only when the user says yes, and that
-- a real socket gets its answer.

constant kTools = "org.openxtalk.plugin.mcpbridge-tools"
constant kUserStack = "mcbTestUserStack"

local sInfoFile, sReply

on TestSetup
   local tFolder, tStub, tName
   put TestGetIDERepositoryPath() & "/Extensions/org.openxtalk.plugin.mcpbridge" into tFolder
   start using stack (tFolder & "/mcpbridge-tools.livecodescript")
   -- The IDE's handlers the assistant's build library calls, and the
   -- plugin's two functions the bridge asks: mcbConfirm answers as
   -- mcbTestSetAnswer says, and records what it was asked
   put "local sAnswer, sAsked" & return & \
         "on ideMessageSend pMessage, pTarget" & return & "end ideMessageSend" & return & \
         "on revIDESetEdited pStack" & return & "end revIDESetEdited" & return & \
         "on mcbTestSetAnswer pAnswer" & return & "put pAnswer into sAnswer" & return & "end mcbTestSetAnswer" & return & \
         "function mcbConfirm pTitle, pDetail, pYes" & return & "put pTitle & return after sAsked" & return & \
         "return sAnswer" & return & "end mcbConfirm" & return & \
         "function mcbEditorStack" & return & "return empty" & return & "end mcbEditorStack" & return & \
         "function mcbTestAsked" & return & "return sAsked" & return & "end mcbTestAsked" & return into tStub
   create invisible stack "mcbTestIDE"
   set the script of stack "mcbTestIDE" to tStub
   start using stack "mcbTestIDE"
   -- The test runner's stacks and this stand-in are not the user's, as
   -- the IDE's own stacks are not
   repeat for each line tName in the mainStacks
      if there is a stack tName then
         set the _ideoverride of stack tName to true
      end if
   end repeat
   put specialFolderPath("temporary") & "/mcbtest-" & the milliseconds & "/mcp-bridge.json" into sInfoFile
end TestSetup

on TestTeardown
   if the long id of stack kTools is among the lines of TestStacksInUse() then
      mcbServerStop
   end if
end TestTeardown

private function TestStacksInUse
   local tList, tName
   repeat for each line tName in the stacksInUse
      if there is a stack tName then
         put the long id of stack tName & return after tList
      end if
   end repeat
   return tList
end TestStacksInUse

private command TestStart
   local tPort
   put mcbServerStart(TestGetIDERepositoryPath() & "/Extensions/org.openxtalk.plugin.xtalkassistant", \
         the long id of stack "mcbTestIDE", sInfoFile) into tPort
end TestStart

private function TestToken
   local tInfo
   put xtaJsonParse(textDecode(url ("binfile:" & sInfoFile), "UTF-8")) into tInfo
   return xtaJsonText(xtaJsonMember(tInfo, "token"))
end TestToken

-- A call as the MCP server sends it, answered: the parsed answer
private function TestCall pTool, pArgumentsJson
   local tLine
   if pArgumentsJson is empty then
      put "{}" into pArgumentsJson
   end if
   replace "`" with quote in pArgumentsJson
   put "{" & quote & "id" & quote & ":7," & quote & "token" & quote & ":" & quote & TestToken() & quote & "," & \
         quote & "method" & quote & ":" & quote & "call" & quote & "," & quote & "tool" & quote & ":" & quote & pTool & quote & "," & \
         quote & "arguments" & quote & ":" & pArgumentsJson & "}" into tLine
   return xtaJsonParse(mcbHandleLine(tLine))
end TestCall

private function TestText pReply
   return xtaJsonText(xtaJsonMember(pReply, "text"))
end TestText

private function TestIsError pReply
   return xtaJsonText(xtaJsonMember(pReply, "isError")) is "true"
end TestIsError

private function TestUserStack
   local tStack
   create stack kUserStack
   put the long id of stack kUserStack into tStack
   set the rect of tStack to "100,100,500,400"
   set the name of card 1 of tStack to "Main"
   create button "Go" in card 1 of tStack
   go stack kUserStack
   return tStack
end TestUserStack

--------------------------------------------------------------------------------

on TestServerWritesAndDeletesItsFile
   local tInfo, tPort
   TestStart
   put mcbServerPort() into tPort
   TestAssert "it listens on a port", tPort is an integer and tPort > 0
   TestAssert "it wrote its file", there is a file sInfoFile
   put xtaJsonParse(textDecode(url ("binfile:" & sInfoFile), "UTF-8")) into tInfo
   TestAssert "the file has the port", xtaJsonText(xtaJsonMember(tInfo, "port")) is tPort
   TestAssert "the file has a token of 32 hex digits", \
         matchText(xtaJsonText(xtaJsonMember(tInfo, "token")), "^[0-9a-f]{32}$")
   TestAssert "the file has the protocol", xtaJsonText(xtaJsonMember(tInfo, "protocol")) is 1
   mcbServerStop
   TestAssert "stopping deletes the file", there is not a file sInfoFile
   TestAssert "stopping forgets the port", mcbServerPort() is empty
end TestServerWritesAndDeletesItsFile

on TestRefusesARequestWithoutTheToken
   local tReply
   TestStart
   put xtaJsonParse(mcbHandleLine("{" & quote & "id" & quote & ":1," & quote & "method" & quote & ":" & quote & "hello" & quote & "}")) into tReply
   TestAssert "no token", xtaJsonText(xtaJsonMember(tReply, "ok")) is "false"
   put xtaJsonParse(mcbHandleLine("{" & quote & "id" & quote & ":2," & quote & "token" & quote & ":" & quote & "0123" & quote & "," & \
         quote & "method" & quote & ":" & quote & "call" & quote & "," & quote & "tool" & quote & ":" & quote & "list_stacks" & quote & "}")) into tReply
   TestAssert "a wrong token", xtaJsonText(xtaJsonMember(tReply, "ok")) is "false" and xtaJsonText(xtaJsonMember(tReply, "error")) contains "token"
   TestAssert "the id comes back", xtaJsonText(xtaJsonMember(tReply, "id")) is 2
   put xtaJsonParse(mcbHandleLine("not json")) into tReply
   TestAssert "not JSON", xtaJsonText(xtaJsonMember(tReply, "ok")) is "false"
   mcbServerStop
   -- The assistant's libraries, which this loaded, are gone with it: the
   -- refusal is read as text
   put mcbHandleLine("{" & quote & "id" & quote & ":3," & quote & "token" & quote & ":" & quote & quote & "," & \
         quote & "method" & quote & ":" & quote & "hello" & quote & "}") into tReply
   TestAssert "nothing is answered once stopped", tReply contains (quote & "ok" & quote & ":false") and tReply contains "turned off"
end TestRefusesARequestWithoutTheToken

on TestHello
   local tReply
   TestStart
   put xtaJsonParse(mcbHandleLine("{" & quote & "id" & quote & ":" & quote & "a" & quote & "," & quote & "token" & quote & ":" & quote & TestToken() & quote & "," & \
         quote & "method" & quote & ":" & quote & "hello" & quote & "}")) into tReply
   TestAssert "hello", xtaJsonText(xtaJsonMember(tReply, "ok")) is "true"
   TestAssert "a string id comes back", xtaJsonText(xtaJsonMember(tReply, "id")) is "a"
   TestAssert "the protocol", xtaJsonText(xtaJsonMember(tReply, "protocol")) is 1
   TestAssert "the tools", xtaJsonText(xtaJsonMember(tReply, "tools")) contains "make_changes"
end TestHello

on TestReadingTools
   local tReply
   TestStart
   put TestCall("list_stacks") into tReply
   TestAssert "no stacks of the user's yet", not TestIsError(tReply) and TestText(tReply) contains "no stack of their own"
   get TestUserStack()
   put TestCall("list_stacks") into tReply
   TestDiagnostic TestText(tReply)
   TestAssert "the user's stack is listed", TestText(tReply) contains kUserStack
   TestAssert "the bridge's own stacks are not", not (TestText(tReply) contains "mcpbridge") and not (TestText(tReply) contains "mcbTestIDE")
   put TestCall("read_stack", "{`stack`:`" & kUserStack & "`}") into tReply
   TestDiagnostic TestText(tReply)
   TestAssert "an outline", not TestIsError(tReply) and TestText(tReply) contains "Go"
   put TestCall("read_stack", "{`stack`:`nowhere`}") into tReply
   TestAssert "a stack that is not open", TestIsError(tReply)
   put TestCall("check_code", "{`code`:`put 1 into x`}") into tReply
   TestAssert "code that compiles", not TestIsError(tReply) and TestText(tReply) contains "compiles"
   put TestCall("check_code", "{`code`:`put 1 intoo x`}") into tReply
   TestAssert "code that does not", TestText(tReply) contains "does not compile"
   put TestCall("xtalk_guide") into tReply
   TestAssert "the guide", not TestIsError(tReply) and TestText(tReply) contains "xTalk"
   put TestCall("look_at_card", "{`stack`:`" & kUserStack & "`}") into tReply
   TestAssert "a picture of the card", not TestIsError(tReply) and xtaJsonText(xtaJsonMember(tReply, "imageType")) is "image/png" \
         and xtaJsonText(xtaJsonMember(tReply, "image")) is not empty
   put TestCall("no_such_tool") into tReply
   TestAssert "a tool there is not", TestIsError(tReply) and TestText(tReply) contains "no tool"
end TestReadingTools

on TestChangesAndUndo
   local tReply, tStack
   TestStart
   put TestUserStack() into tStack
   put TestCall("make_changes", "{`stack`:`" & kUserStack & "`,`changes`:[{`action`:`create`,`kind`:`button`,`name`:`Added`," & \
         "`script`:`on mouseUp\n  beep\nend mouseUp`}]}") into tReply
   TestDiagnostic TestText(tReply)
   TestAssert "the change is made", not TestIsError(tReply) and there is a button "Added" of tStack
   TestAssert "it says how to undo it", TestText(tReply) contains "undo_changes"
   put TestCall("make_changes", "{`stack`:`" & kUserStack & "`,`changes`:[{`action`:`create`,`kind`:`button`,`properties`:{`lable`:`x`}}]}") into tReply
   TestAssert "a mistake changes nothing", TestIsError(tReply) and TestText(tReply) contains "Nothing was changed"
   put TestCall("make_changes", "{`stack`:`mcbTestIDE`,`changes`:[{`action`:`create`,`kind`:`button`}]}") into tReply
   TestAssert "the IDE's stacks are not changed", TestIsError(tReply)
   put TestCall("list_changes") into tReply
   TestAssert "the change is listed", TestText(tReply) contains "1:"
   put TestCall("undo_changes") into tReply
   TestDiagnostic TestText(tReply)
   TestAssert "undone", not TestIsError(tReply) and there is not a button "Added" of tStack
   put TestCall("undo_changes") into tReply
   TestAssert "nothing more to undo", TestIsError(tReply)
end TestChangesAndUndo

on TestUndoAsksWhenTheUserChangedIt
   local tReply, tStack
   TestStart
   put TestUserStack() into tStack
   put TestCall("make_changes", "{`stack`:`" & kUserStack & "`,`changes`:[{`action`:`set`,`object`:`stack`,`properties`:{`title`:`Before`}}]}") into tReply
   TestAssert "the change is made", not TestIsError(tReply)
   set the title of tStack to "The user's"
   dispatch "mcbTestSetAnswer" to stack "mcbTestIDE" with false
   put TestCall("undo_changes") into tReply
   TestAssert "the user is asked, says no, and nothing is undone", TestIsError(tReply) and the title of tStack is "The user's" \
         and mcbTestAsked() contains "Undo"
   dispatch "mcbTestSetAnswer" to stack "mcbTestIDE" with true
   put TestCall("undo_changes") into tReply
   TestAssert "says yes, and it is undone", not TestIsError(tReply) and the title of tStack is empty
end TestUndoAsksWhenTheUserChangedIt

on TestRunsAndWhatTheUserIsAsked
   local tReply, tFile
   TestStart
   put TestCall("run_code", "{`code`:`put 6 * 7`}") into tReply
   TestDiagnostic TestText(tReply)
   TestAssert "a run in the sandbox", not TestIsError(tReply) and TestText(tReply) contains "42"
   TestAssert "it was not asked about", mcbTestAsked() is empty
   put specialFolderPath("temporary") & "/mcbtest-nothing-" & the milliseconds into tFile
   dispatch "mcbTestSetAnswer" to stack "mcbTestIDE" with false
   put TestCall("run_code", "{`code`:`put \`x\` into url (\`file:" & tFile & "\`)`}") into tReply
   TestDiagnostic TestText(tReply)
   TestAssert "code that writes a file is asked about, and refused, does not run", TestIsError(tReply) \
         and mcbTestAsked() contains "run code" and there is not a file tFile
   dispatch "mcbTestSetAnswer" to stack "mcbTestIDE" with true
   put TestCall("run_code", "{`code`:`put \`x\` into url (\`file:" & tFile & "\`)`}") into tReply
   TestAssert "allowed, it runs", not TestIsError(tReply) and there is a file tFile
   delete file tFile
end TestRunsAndWhatTheUserIsAsked

on TestSaveIsAskedAbout
   local tReply, tStack, tFile
   TestStart
   put TestUserStack() into tStack
   put specialFolderPath("temporary") & "/mcbtest-" & the milliseconds & ".livecode" into tFile
   set the fileName of tStack to tFile
   dispatch "mcbTestSetAnswer" to stack "mcbTestIDE" with false
   put TestCall("save_stack", "{`stack`:`" & kUserStack & "`}") into tReply
   TestAssert "refused, nothing is saved", TestIsError(tReply) and there is not a file tFile
   dispatch "mcbTestSetAnswer" to stack "mcbTestIDE" with true
   put TestCall("save_stack", "{`stack`:`" & kUserStack & "`}") into tReply
   TestDiagnostic TestText(tReply)
   TestAssert "allowed, it is saved", not TestIsError(tReply) and there is a file tFile
   if there is a file tFile then
      delete file tFile
   end if
end TestSaveIsAskedAbout

-- A real socket from this engine to the bridge in it: the request goes
-- out, the answer comes back as one line
on TestOverASocket
   local tSocket, tStart
   TestStart
   put "127.0.0.1:" & mcbServerPort() into tSocket
   open socket to tSocket
   write textEncode("{" & quote & "id" & quote & ":5," & quote & "token" & quote & ":" & quote & TestToken() & quote & "," & \
         quote & "method" & quote & ":" & quote & "hello" & quote & "}" & numToChar(10), "UTF-8") to socket tSocket
   put empty into sReply
   read from socket tSocket until numToChar(10) with message "TestReplyRead"
   put the milliseconds into tStart
   repeat while sReply is empty and the milliseconds - tStart < 10000
      wait 20 milliseconds with messages
   end repeat
   TestDiagnostic sReply
   TestAssert "one line comes back", the last char of sReply is numToChar(10)
   TestAssert "it is the answer", xtaJsonText(xtaJsonMember(xtaJsonParse(line 1 of textDecode(sReply, "UTF-8")), "ok")) is "true"
   TestAssert "one client", mcbServerClients() is 1
   close socket tSocket
end TestOverASocket

on TestReplyRead pSocket, pData
   put pData into sReply
end TestReplyRead
