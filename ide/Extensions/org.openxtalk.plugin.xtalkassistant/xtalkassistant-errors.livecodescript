script "org.openxtalk.plugin.xtalkassistant-errors"
-- OXT-Beyond: the xTalk Assistant's error hook.
--
-- While the assistant is on, the plugin's main stack inserts this script
-- into the front of the message path, so that it notes the errors the IDE
-- shows the user, for More > Explain the Last Error and the model's
-- last_error tool. An error reaches the IDE one of two ways: with Script
-- Debug Mode on (the IDE's default) the engine sends traceError and the
-- IDE's debugger (revdebuggerlibrary.livecodescript) opens the Script Editor
-- at the line; with it off, or where the debugger lets an error go, the
-- engine sends errorDialog and the IDE shows its error window
-- (revbackscriptlibrary.livecodescript). This script passes both on with
-- their parameters as they came, so the IDE does exactly what it does
-- without the assistant; turning the assistant off takes this script out of
-- the message path again. Its only other handler is the function the main
-- stack reads the errors with.

-- How many errors are kept
constant kKept = 5

-- How close in time (seconds) the same error must come to be the same one
-- noted twice (once on its way to the debugger, once to the error window)
constant kSameError = 2

-- The errors noted, the oldest first: keys 1 to N, each with "trace" (the
-- execution error, lines of "code,line,column,hint"), "target" (the long
-- id of the object the message was sent to) and "seconds" (when)
local sErrors

on traceError pHandler, pLine, pPosition, pError
   -- The engine sends it again with no error as it leaves each handler
   -- above the one that failed (the debugger stops on those); only the
   -- first, with the error, is the error
   if pError is not empty then
      xtaErrorHookNote pError, the long id of the target
   end if
   pass traceError
end traceError

on errorDialog pExecutionError
   -- With no execution error (a script that did not compile, whose parse
   -- error comes second) there is nothing to explain
   if pExecutionError is not empty then
      xtaErrorHookNote pExecutionError, the long id of the target
   end if
   pass errorDialog
end errorDialog

private command xtaErrorHookNote pTrace, pTarget
   local tCount, tIndex, tError
   try
      put the number of elements of sErrors into tCount
      if tCount > 0 then
         -- Compared as one text, never as numbers
         if (sErrors[tCount]["trace"] & return & sErrors[tCount]["target"]) is (pTrace & return & pTarget) \
               and the seconds - sErrors[tCount]["seconds"] <= kSameError then
            exit xtaErrorHookNote
         end if
      end if
      if tCount >= kKept then
         repeat with tIndex = 1 to kKept - 1
            put sErrors[tIndex + 1] into sErrors[tIndex]
         end repeat
         put kKept - 1 into tCount
      end if
      add 1 to tCount
      put pTrace into sErrors[tCount]["trace"]
      put pTarget into sErrors[tCount]["target"]
      put the seconds into sErrors[tCount]["seconds"]
   catch tError
   end try
end xtaErrorHookNote

function xtaErrorHookErrors
   return sErrors
end xtaErrorHookErrors
