script "HyperCardSweep"
-- One stack of a HyperCard corpus sweep (see README.md): import it with
-- File > Import Stack's importer, fix its scripts with
-- revHyperCardFixScripts, and log what happened, one tab-separated line
-- at a time, to the file $HC_OUT. Run headless by sweep.py, which sets:
--
--   HC_IN    the stack (MacBinary or a plain HyperCard stack file)
--   HC_OUT   the log file
--   HC_LIB   the folder of the HyperCard libraries to load
--            (ide/Toolset/libraries in a checkout)
--   HC_MODE  "fix" to stop after the scripts are fixed; "run" to go on
--            and open the stack, go to its first 40 cards and click up to
--            20 buttons on each of the first 20, the way a person would
--   HC_IMAGE and HC_IMAGEPATH  (or empty) the disk image the stack came
--            from and its path on that image, Volume:Folder:Stack
--
-- The log's lines: IMPORTED name cards; NOIMPORT error; FIX summary;
-- LEFT name error text (a handler left out, its text in base64); LINE
-- name line how error text (a line left out of a handler that was kept,
-- rule T39); ERR and THROW phase error source (an error while running,
-- base64); MODAL phase name (a window that waited for a person, closed
-- by the sweep, the name base64); OPENED; DONE. Text that may hold
-- returns is base64 so a line stays a line.

local sDone, sOut, sModal, sTour

on openStack
   if the short name of the owner of the target is not "HyperCardSweep" then pass openStack
   if sDone then pass openStack
   put true into sDone
   -- after openStack, so that the engine has finished starting
   send "sweepRun" to me in 0 milliseconds
end openStack

command sweepRun
   local tStack, tReport, tError, tLine, tLeft, i, tMace
   global gSweepPhase
   put $HC_OUT into sOut
   start using stack ($HC_LIB & "/revhypercardscriptlibrary.livecodescript")
   -- errors while running come here instead of a dialog
   create invisible stack "HyperCardSweepErrors"
   set the script of stack "HyperCardSweepErrors" to "on errorDialog pError" & return \
         & "global gSweepErrors" & return & "put pError & numToChar(1) after gSweepErrors" & return & "end errorDialog"
   lock messages
   try
      import stack from file $HC_IN
   catch tError
   end try
   put the result into tLine
   unlock messages
   repeat for each line tLine in the openStacks
      if tLine is not among the items of "HyperCardSweep,HyperCardSweepErrors,revHyperCardScriptLibrary,revHyperCardMACELibrary,revHyperCardDiskImageLibrary" \
            and not (tLine begins with "revHyperCardProbe") then
         put the long id of stack tLine into tStack
         exit repeat
      end if
   end repeat
   if tStack is empty then
      sweepLog "NOIMPORT" & tab & sweepBase64(tError & tLine)
      quit
   end if
   sweepLog "IMPORTED" & tab & the short name of tStack & tab & the number of cards of tStack

   -- From a disk image, as File > Import Stack does: where on the image the
   -- stack came from, so that a "go" or a "start using" finds a stack
   -- beside it there (the HyperCard Library's hcStackName). The stacks
   -- folder names its files by number, so beside a stack there, no stack
   -- is found by its name
   if $HC_IMAGE is not empty then
      if there is a file ($HC_LIB & "/revhypercarddiskimagelibrary.livecodescript") then
         start using stack ($HC_LIB & "/revhypercarddiskimagelibrary.livecodescript")
      end if
      set the uHyperCard["image"] of tStack to $HC_IMAGE
      set the uHyperCard["imagepath"] of tStack to $HC_IMAGEPATH
   end if
   -- as File > Import Stack does: HyperCard's message order (HC_ORDER=1,
   -- on an engine that has hyperTalkCompatible), the scripts, the MACE
   -- sounds and the classic look
   if $HC_ORDER is 1 then
      try
         set the hyperTalkCompatible of tStack to true
      catch tError
      end try
   end if
   put revHyperCardFixScripts(tStack) into tReport
   sweepLog "FIX" & tab & the last line of tReport
   put revHyperCardLeftOutHandlers() into tLeft
   repeat with i = 1 to the number of elements of tLeft
      sweepLog "LEFT" & tab & tLeft[i]["name"] & tab & tLeft[i]["error"] & tab & sweepBase64(tLeft[i]["text"])
   end repeat
   -- (a library from before rule T39 has no revHyperCardLeftOutLines)
   try
      put revHyperCardLeftOutLines() into tLeft
   catch tError
      put empty into tLeft
   end try
   repeat with i = 1 to the number of elements of tLeft
      sweepLog "LINE" & tab & tLeft[i]["name"] & tab & tLeft[i]["line"] & tab & tLeft[i]["how"] & tab & tLeft[i]["error"] & tab & sweepBase64(tLeft[i]["text"])
   end repeat
   if there is a file ($HC_LIB & "/revhypercardmacelibrary.livecodescript") then
      start using stack ($HC_LIB & "/revhypercardmacelibrary.livecodescript")
      put 0 into tMace
      repeat for each line tLine in the hcImportStat
         if tLine begins with "Not converting snd" and "MACE" is in tLine then add 1 to tMace
      end repeat
      try
         get revHyperCardConvertMACESounds(tStack, $HC_IN)
      catch tError
         put "error" into it
      end try
      if tMace > 0 or it > 0 then sweepLog "MACE" & tab & tMace & tab & it
   end if
   try
      revHyperCardClassicLook tStack
   catch tError
   end try
   if $HC_MODE is not "run" then
      sweepLog "DONE"
      quit
   end if

   insert the script of stack "HyperCardSweepErrors" into back
   send "sweepModalWatch" to me in 250 milliseconds
   put "open" into gSweepPhase
   -- The import opened the stack with messages locked, before its scripts
   -- were fixed, so its own openStack, openBackground and openCard have
   -- not run, and "go" to a stack already open sends none. Closed (with
   -- messages locked, kept in memory) and gone to again, it opens as a
   -- person opens it once it is saved: with those messages, where many
   -- stacks set themselves up and call their externals first
   try
      set the destroyStack of tStack to false
      lock messages
      do "close" && tStack
   catch tError
   end try
   unlock messages
   try
      -- (by "do": "go to card 1 of" a variable is read when the script
      -- loads, before the stack is there)
      do "go to card 1 of" && tStack
   catch tError
      sweepLog "THROW" & tab & "open" & tab & sweepBase64(tError) & tab & sweepBase64(sweepSource(tError))
   end try
   sweepFlush
   sweepLog "OPENED"
   sweepTour tStack
end sweepRun

-- Go to the stack's first 40 cards, and on each of the first 20 click up
-- to 20 buttons, back on the card before each click. One visit or one
-- click to a message, as a person does one thing at a time: the engine
-- starts each message afresh, as it starts each of a person's clicks,
-- with no screen or messages left locked and no dynamic path (after a
-- "go", a message of that handler goes on to the card it went to as well
-- as through its own stack), and the stack's own idle and timer messages
-- come between them. In one long handler, a button's "go home" that
-- opened another stack once left the stack's own handlers unanswered for
-- the rest of the tour, when the engine sent such a handler's messages to
-- the other stack in place of its own
command sweepTour pStack
   put pStack into sTour["stack"]
   put min(40, the number of cards of pStack) into sTour["cards"]
   put 0 into sTour["card"]
   put 0 into sTour["button"]
   put 0 into sTour["buttons"]
   send "sweepTourStep" to me in 0 milliseconds
end sweepTour

-- The tour's next click on this card, or else its next card
command sweepTourStep
   local tStack, tCardId, tError
   global gSweepPhase
   put sTour["stack"] into tStack
   if there is not a tStack then
      sweepTourDone
   else if sTour["button"] < sTour["buttons"] then
      add 1 to sTour["button"]
      put "click" && sTour["card"] & "," & sTour["button"] into gSweepPhase
      put sTour["cardid"] into tCardId
      try
         if exists(tCardId) and the long id of this card of tStack is not tCardId then
            lock messages
            do "go to" && tCardId
            unlock messages
         end if
         if exists(tCardId) and the number of buttons of tCardId >= sTour["button"] then
            dispatch "mouseDown" to button sTour["button"] of tCardId
            dispatch "mouseUp" to button sTour["button"] of tCardId
         end if
      catch tError
         sweepLog "THROW" & tab & gSweepPhase & tab & sweepBase64(tError) & tab & sweepBase64(sweepSource(tError))
      end try
      sweepFlush
      send "sweepTourStep" to me in 0 milliseconds
   else if sTour["card"] < sTour["cards"] then
      add 1 to sTour["card"]
      put "card" && sTour["card"] into gSweepPhase
      try
         do "go to card" && sTour["card"] && "of" && tStack
      catch tError
         sweepLog "THROW" & tab & gSweepPhase & tab & sweepBase64(tError) & tab & sweepBase64(sweepSource(tError))
      end try
      sweepFlush
      -- its buttons, on the first 20 cards
      put 0 into sTour["button"]
      put 0 into sTour["buttons"]
      if there is a tStack and sTour["card"] <= 20 then
         put the long id of card sTour["card"] of tStack into sTour["cardid"]
         put min(20, the number of buttons of sTour["cardid"]) into sTour["buttons"]
      end if
      send "sweepTourStep" to me in 0 milliseconds
   else
      sweepTourDone
   end if
end sweepTourStep

command sweepTourDone
   sweepLog "DONE"
   quit
end sweepTourDone

-- A modal window (a list dialog of the HyperCard library, a stack's own
-- modal stack) waits until a person closes it, and nobody is there to:
-- one still open a quarter of a second after it was first seen is
-- closed, as its Cancel button or close box would close it, and logged.
-- Without this the tour stopped at the first one, and the stack timed out
command sweepModalWatch
   local tLine, tSeen, tError
   global gSweepPhase
   repeat for each line tLine in the openStacks
      if tLine is among the items of "HyperCardSweep,HyperCardSweepErrors" then next repeat
      try
         if the mode of stack tLine is among the items of "5,6" then
            if sModal[tLine] then
               sweepLog "MODAL" & tab & gSweepPhase & tab & sweepBase64(tLine)
               close stack tLine
            else
               put true into tSeen[tLine]
            end if
         end if
      catch tError
      end try
   end repeat
   put tSeen into sModal
   send "sweepModalWatch" to me in 250 milliseconds
end sweepModalWatch

-- The errors errorDialog collected since the last time, to the log
command sweepFlush
   global gSweepErrors, gSweepPhase
   local tError
   set the itemDelimiter to numToChar(1)
   repeat for each item tError in gSweepErrors
      if tError is not empty then
         sweepLog "ERR" & tab & gSweepPhase & tab & sweepBase64(tError) & tab & sweepBase64(sweepSource(tError))
      end if
   end repeat
   put empty into gSweepErrors
end sweepFlush

-- The line of script an error names, and its object
function sweepSource pError
   local tLine, tNumber, tObject
   put 0 into tNumber
   repeat for each line tLine in pError
      if item 1 of tLine is 353 then
         put item 4 to -1 of tLine into tObject
         try
            if tNumber > 0 and exists(tObject) then
               return word 1 to -1 of line tNumber of the script of tObject & " ||| " & tObject
            end if
         catch tLine
         end try
      else if item 2 of tLine is an integer and item 2 of tLine > 0 then
         put item 2 of tLine into tNumber
      end if
   end repeat
   return empty
end sweepSource

command sweepLog pLine
   open file sOut for append
   write pLine & return to file sOut
   close file sOut
end sweepLog

function sweepBase64 pText
   local tText
   put base64Encode(textEncode(pText, "UTF-8")) into tText
   replace return with empty in tText
   return tText
end sweepBase64
