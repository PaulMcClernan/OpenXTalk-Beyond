script "WebProbe"
/*
Copyright (C) 2026 OXT-Beyond contributors.

This file is part of OXT-Beyond.

OXT-Beyond is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License v3 as published by the Free
Software Foundation.

OXT-Beyond is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
details.

You should have received a copy of the GNU General Public License
along with OXT-Beyond.  If not see <http://www.gnu.org/licenses/>.  */

-- The script of the probe stack that tools/ci/web_check.py opens in a
-- headless browser: tools/ci/web-deploy.livecodescript makes a web
-- standalone of it, with the controls it uses (a button, a field, a filled
-- graphic and a PNG image).
--
-- Each check writes one line to stdout, which the web engine sends to the
-- browser's console (the page's Module.print):
--
--    PROBE <check> PASS <detail>
--    PROBE <check> FAIL <detail>
--    PROBE info <name> <value>
--
-- The checks run from openStack on, with nobody acting but web_check.py,
-- which answers the page's dialogs as they come. Then the probe writes
-- "PROBE ready", and web_check.py does what a user and a page do: it
-- clicks the button (mouseUp writes "PROBE click PASS <count>"), types
-- into the field, holds Shift down, and calls the handlers that the
-- stack's cJavascriptHandlers name: probeFromJS and probeReport.
--
-- The checks run only in the web standalone: in the IDE, which opens the
-- stack while it builds the standalone, openStack does nothing more.

local sClicks, sKeys, sLoaded, sLoadedData, sInner, sOrder

private command probeLine pText
   write "PROBE " & pText & return to stdout
end probeLine

private command probeCheck pName, pPassed, pDetail
   if pPassed then
      probeLine pName && "PASS" && pDetail
   else
      probeLine pName && "FAIL" && pDetail
   end if
end probeCheck

private command probeInfo pName, pValue
   probeLine "info" && pName && pValue
end probeInfo

on openStack
   local tStart, tElapsed
   if the environment begins with "development" then
      pass openStack
   end if
   probeInfo "version", the version
   probeInfo "environment", the environment
   probeCheck "platform", the platform is "HTML5", the platform
   -- A wait in openStack, at startup: LiveCode's HTML5 engine refused
   -- every wait inside a handler
   put the milliseconds into tStart
   wait 200 milliseconds
   put the milliseconds - tStart into tElapsed
   probeCheck "wait-openstack", tElapsed >= 190, tElapsed & " ms"
   send "probeRun" to me in 10 milliseconds
end openStack

on probeRun
   local tCheck, tError
   repeat for each item tCheck in "probeWaits,probeSends,probeJavaScript,probeFiles,probeUrls,probeDialogs,probeSystem,probeObjects"
      try
         dispatch tCheck to me
      catch tError
         probeLine tCheck && "FAIL" && "script error" && line 1 of tError
      end try
   end repeat
   probeLine "ready"
end probeRun

command probeWaits
   local tStart, tElapsed, tDeadline
   -- A wait in a handler that a timer sent
   put the milliseconds into tStart
   wait 100 milliseconds
   put the milliseconds - tStart into tElapsed
   probeCheck "wait-handler", tElapsed >= 95, tElapsed & " ms"

   -- Messages are handled during a wait with messages, and a handler that
   -- one of them runs can wait too (a nested wait)
   put empty into sInner
   send "probeInner" to me in 20 milliseconds
   put the milliseconds into tStart
   wait 400 milliseconds with messages
   put the milliseconds - tStart into tElapsed
   probeCheck "wait-nested", sInner is "done" and tElapsed >= 395, "inner=" & sInner && tElapsed & " ms"

   -- A wait until a condition that a timer makes true
   put empty into sInner
   send "probeSetFlag" to me in 50 milliseconds
   put the milliseconds into tStart
   put tStart + 5000 into tDeadline
   wait until sInner is "flag" or the milliseconds > tDeadline with messages
   put the milliseconds - tStart into tElapsed
   probeCheck "wait-until", sInner is "flag" and tElapsed >= 45, tElapsed & " ms"
end probeWaits

on probeInner
   local tStart
   put the milliseconds into tStart
   wait 50 milliseconds
   if the milliseconds - tStart >= 45 then
      put "done" into sInner
   else
      put "short" into sInner
   end if
end probeInner

on probeSetFlag
   put "flag" into sInner
end probeSetFlag

command probeSends
   put empty into sOrder
   send "probeOrder 3" to me in 60 milliseconds
   send "probeOrder 1" to me in 20 milliseconds
   send "probeOrder 2" to me in 40 milliseconds
   wait 200 milliseconds with messages
   probeCheck "send-in-time", sOrder is "1,2,3", sOrder
end probeSends

on probeOrder pNumber
   if sOrder is empty then
      put pNumber into sOrder
   else
      put comma & pNumber after sOrder
   end if
end probeOrder

command probeJavaScript
   do "6 * 7" as "JavaScript"
   probeCheck "javascript", the result is 42, the result
   do "document.title" as "JavaScript"
   probeInfo "document-title", the result
end probeJavaScript

command probeFiles
   local tData
   put "hello web" into url "file:/tmp/probe.txt"
   put url "file:/tmp/probe.txt" into tData
   probeCheck "file-roundtrip", tData is "hello web", tData
   probeCheck "standalone-folder", there is a file "/boot/standalone/DroidSansCombined.ttf", the defaultFolder
end probeFiles

command probeUrls
   local tOrigin, tData, tResult, tDeadline, tLibUrl, tExpected
   do "window.location.origin" as "JavaScript"
   put the result into tOrigin
   probeInfo "origin", tOrigin

   -- The IDE's builder adds the Internet library (libURL), with its web
   -- driver, to a stack whose scripts use URLs: libURL then loads them,
   -- as on the desktop. Without it, the engine does, as on iOS and
   -- Android.
   put probeUsesLibUrl() into tLibUrl
   probeInfo "backscripts", probeBackScripts()
   if tLibUrl then
      probeInfo "url-path", "libURL"
   else
      probeInfo "url-path", "engine"
   end if

   put url (tOrigin & "/probe-data.txt") into tData
   put the result into tResult
   probeCheck "url-get", tData is "probe data 123" and tResult is empty, "data=" & tData && "result=" & tResult

   -- A post sends a form's data, as on the desktop
   post "a=1&b=2" to url (tOrigin & "/echo")
   put it into tData
   put the result into tResult
   probeCheck "url-post", tData is "POST application/x-www-form-urlencoded a=1&b=2" and tResult is empty, \
         "data=" & tData && "result=" & tResult

   put "stored text" into url (tOrigin & "/store")
   put the result into tResult
   put url (tOrigin & "/store") into tData
   probeCheck "url-put", tData is "stored text" and tResult is empty, "data=" & tData && "result=" & tResult

   -- A page that the server answers with an error status (here 404) is
   -- an error that comes with the page the server sent: libURL's result
   -- is "error 404 Not Found", as on the desktop, and the engine's
   -- "404 Not Found", as on iOS and Android
   put url (tOrigin & "/missing") into tData
   put the result into tResult
   if tLibUrl then
      put "error 404 Not Found" into tExpected
   else
      put "404 Not Found" into tExpected
   end if
   probeCheck "url-missing", tData is "not found" and tResult is tExpected, "data=" & tData && "result=" & tResult

   -- load url: libURL sends the message with the status "cached", and
   -- the page is then in its cache, as on the desktop; the engine sends
   -- "downloaded" and the page, as on iOS and Android
   put empty into sLoaded
   put empty into sLoadedData
   load url (tOrigin & "/probe-data.txt") with message "probeLoaded"
   put the milliseconds + 10000 into tDeadline
   wait until sLoaded is not empty or the milliseconds > tDeadline with messages
   if tLibUrl then
      put url (tOrigin & "/probe-data.txt") into sLoadedData
      probeCheck "url-load", sLoaded is "cached" and sLoadedData is "probe data 123", \
            "status=" & sLoaded && "cached=" & sLoadedData
   else
      probeCheck "url-load", sLoaded is "downloaded" and sLoadedData is "probe data 123", \
            "status=" & sLoaded && "data=" & sLoadedData
   end if
end probeUrls

-- True when libURL loads URLs: its stack is in the back scripts
private function probeUsesLibUrl
   local tObject
   repeat for each line tObject in the backScripts
      if the short name of tObject is "revLibUrl" then
         return true
      end if
   end repeat
   return false
end probeUsesLibUrl

private function probeBackScripts
   local tObject, tNames
   repeat for each line tObject in the backScripts
      if tNames is not empty then
         put comma after tNames
      end if
      put the short name of tObject after tNames
   end repeat
   return tNames
end probeBackScripts

on probeLoaded pUrl, pStatus, pData
   put pStatus into sLoaded
   put pData into sLoadedData
end probeLoaded

command probeDialogs
   -- The page's dialogs, which stand in for the desktop's: web_check.py
   -- clicks each one's default button (the last), typing "Ada" into the
   -- ask dialog's field. As on the desktop, it is the button clicked, and
   -- "OK" for an answer dialog without buttons.
   answer "Hello from the probe"
   probeCheck "answer", it is "OK", it
   answer "Go on?" with "Cancel" or "OK"
   probeCheck "answer-confirm", it is "OK", it
   ask "What is your name?" with "nobody"
   probeCheck "ask", it is "Ada" and the result is empty, it && "result=" & the result
end probeDialogs

command probeSystem
   local tFolder, tMissing, tHost, tCursor
   -- The standard folders, which the engine makes in its file system
   repeat for each item tFolder in "home,documents,desktop,preferences,support"
      if there is not a folder specialFolderPath(tFolder) then
         put tFolder & "=" & specialFolderPath(tFolder) & space after tMissing
      end if
   end repeat
   probeCheck "folders", tMissing is empty and specialFolderPath("downloads") is "/downloads", \
         "missing=" & tMissing && "downloads=" & specialFolderPath("downloads")

   -- A file written to /downloads goes to the user as a download, which
   -- web_check.py checks
   put "download me" into url "file:/downloads/probe-download.txt"
   probeCheck "download-written", the result is empty, the result

   -- The address is the page's host and the program's name
   do "window.location.hostname" as "JavaScript"
   put the result into tHost
   probeCheck "address", the address begins with (tHost & ":"), the address
   probeCheck "random-bytes", the length of randomBytes(16) is 16, the length of randomBytes(16)

   -- No key is down yet; web_check.py holds Shift down later
   probeCheck "modifiers", the shiftKey is "up" and the keysDown is empty, \
         "shiftKey=" & the shiftKey && "keysDown=" & the keysDown

   -- The cursor is the canvas's CSS cursor
   set the lockCursor to true
   set the cursor to hand
   do "document.getElementById('canvas').style.cursor" as "JavaScript"
   put the result into tCursor
   set the lockCursor to false
   probeCheck "cursor", tCursor is "pointer", tCursor
end probeSystem

command probeObjects
   probeCheck "objects", there is a button "Probe Button" and there is a field "Probe Field" \
         and there is a graphic "Probe Graphic" and there is an image "Probe Image", the number of controls
   probeInfo "stack-rect", the rect of this stack
   probeInfo "button-rect", the rect of button "Probe Button"
   probeInfo "field-rect", the rect of field "Probe Field"
   probeInfo "graphic-rect", the rect of graphic "Probe Graphic"
   probeInfo "image-rect", the rect of image "Probe Image"
end probeObjects

command probeClicked
   add 1 to sClicks
   probeLine "click PASS" && sClicks
end probeClicked

on keyDown pKey
   put pKey after sKeys
   pass keyDown
end keyDown

-- Called from the page. A handler that the page calls runs while the
-- engine is paused, so it cannot wait: the wait fails with an error (as
-- in LiveCode's HTML5 engine), and the handler goes on.
function probeFromJS pValue
   local tWaited, tError
   try
      wait 10 milliseconds
      put "waited" into tWaited
   catch tError
      put "refused" into tWaited
   end try
   probeLine "info js-call value=" & pValue && "wait=" & tWaited
   return pValue * 2
end probeFromJS

-- Called from the page: what the user did, or with "keys", the keys that
-- are down
function probeReport pWhat
   if pWhat is "keys" then
      return the shiftKey & "|" & the keysDown
   end if
   return the text of field "Probe Field" & "|" & sKeys & "|" & sClicks
end probeReport
