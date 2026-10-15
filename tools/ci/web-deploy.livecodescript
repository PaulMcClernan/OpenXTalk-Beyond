script "OXTWebDeployTest"
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

-- Makes the startup data of a web standalone the way the IDE's web builder
-- does (storeDeployedStack in ide-support/
-- revsaveasemscriptenstandalone.livecodescript): a stack file is saved,
-- the startup script is made from the startup template, and
-- "_internal deploy emscripten" writes the data that the web engine reads
-- from /boot/__startup.data. tools/ci/web_check.py puts it into
-- standalone.zip with the template folder and opens the page in a browser.
--
-- The stack is the probe stack: the script of
-- tools/ci/web-probe.livecodescript (without its first line, the
-- script-only stack's header), with the controls that the probe uses, so
-- that the web engine reads them from a stack file: a button, a field, a
-- filled graphic and a PNG image.
--
-- Run with a development engine, without a user interface:
--    <engine> -ui tools/ci/web-deploy.livecodescript
-- Environment:
--    OXT_WEB_PROBE     the probe's script (tools/ci/web-probe.livecodescript)
--    OXT_WEB_TEMPLATE  the startup template
--                      (engine/rsrc/emscripten-startup-template.livecodescript)
--    OXT_WEB_VERSION   the web engine's version, which the startup script
--                      checks (the builder puts its own engine's there)
--    OXT_WEB_STACK     where to save the stack file
--    OXT_WEB_OUTPUT    the startup data to write
--
-- Writes "DEPLOY OK <output>" or "DEPLOY FAILED <reason>" and exits with 0
-- or 1.

-- A 24x24 PNG, all of it the colour 0,170,0
constant kGreenPNG = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAIAAABvFaqvAAAAHklEQVR42mNgWMVAHTRq0KhBowaNGjRq0KhBA28QADGLfpBqGLo1AAAAAElFTkSuQmCC"

private function fileText pPath
   local tText
   open file pPath for "UTF-8" text read
   if the result is not empty then
      throw "cannot open " & pPath & ": " & the result
   end if
   read from file pPath until end
   put it into tText
   close file pPath
   return tText
end fileText

-- The probe stack, with its script and controls (see the header)
private command makeProbeStack
   local tScript, tStack
   put fileText($OXT_WEB_PROBE) into tScript
   if line 1 of tScript begins with "script " then
      delete line 1 of tScript
   end if
   create stack "WebProbe"
   put the long id of stack "WebProbe" into tStack
   set the label of tStack to "Web Probe"
   set the rect of tStack to 100,100,580,460
   set the backgroundColor of tStack to "#3366CC"
   set the script of tStack to tScript
   -- The handlers that the page can call (document.liveCode.findStackWithName)
   set the cJavascriptHandlers of tStack to "probeFromJS" & return & "probeReport"
   set the defaultStack to "WebProbe"

   create button "Probe Button"
   set the rect of button "Probe Button" to 20,20,160,50
   set the label of button "Probe Button" to "Click me"
   set the script of button "Probe Button" to "on mouseUp" & return & "   probeClicked" & return & "end mouseUp"

   create field "Probe Field"
   set the rect of field "Probe Field" to 20,70,260,100
   set the backgroundColor of field "Probe Field" to "#FFFFFF"
   set the lockText of field "Probe Field" to false
   set the traversalOn of field "Probe Field" to true

   create graphic "Probe Graphic"
   set the style of graphic "Probe Graphic" to "rectangle"
   set the rect of graphic "Probe Graphic" to 300,40,400,140
   set the opaque of graphic "Probe Graphic" to true
   set the lineSize of graphic "Probe Graphic" to 0
   set the backgroundColor of graphic "Probe Graphic" to "#CC3300"

   create image "Probe Image"
   set the text of image "Probe Image" to base64Decode(kGreenPNG)
   set the rect of image "Probe Image" to 300,200,324,224
end makeProbeStack

-- The startup script, as getStartupScript in the builder makes it
private function startupScript
   local tScript
   put fileText($OXT_WEB_TEMPLATE) into tScript
   replace "@ENGINE_VERSION@" with $OXT_WEB_VERSION in tScript
   -- the script that the builder generates for the libraries and
   -- extensions of the standalone; the probe has none
   replace "@STARTUP_SCRIPT@" with empty in tScript
   return tScript
end startupScript

on startup
   local tParams, tResult, tError
   write "INFO engine version=" & the version & " platform=" & the platform & return to stdout
   try
      if $OXT_WEB_VERSION is empty then
         throw "OXT_WEB_VERSION is not set"
      end if
      makeProbeStack
      save stack "WebProbe" as $OXT_WEB_STACK
      if the result is not empty then
         throw "cannot save the stack as " & $OXT_WEB_STACK & ": " & the result
      end if
      put startupScript() into tParams["startup_script"]
      put $OXT_WEB_STACK into tParams["stackfile"]
      put $OXT_WEB_OUTPUT into tParams["output"]
      -- as the builder: the deploy command needs the key, and the web has
      -- no externals
      put empty into tParams["engine"]
      put empty into tParams["externals"]
      _internal deploy emscripten tParams
      put the result into tResult
   catch tError
      put "script error: " & tError into tResult
   end try
   if tResult is empty and there is a file $OXT_WEB_OUTPUT then
      write "DEPLOY OK " & $OXT_WEB_OUTPUT & return to stdout
      quit 0
   end if
   if tResult is empty then
      put "the deploy command wrote no file " & $OXT_WEB_OUTPUT into tResult
   end if
   replace return with " | " in tResult
   write "DEPLOY FAILED " & tResult & return to stdout
   quit 1
end startup
