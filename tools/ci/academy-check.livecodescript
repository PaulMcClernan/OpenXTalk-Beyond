script "oxt_academy_check"
-- Headless check of the xTalk Academy's courses: every lesson of every
-- course file is run as a learner would run it, with the Academy's own
-- runner (revAcademyRun and revAcademyCheck of
-- Toolset/palettes/academy/revacademy.livecodescript).
--
-- Run it with an engine, without the IDE (tools/ci/academy_check.py does
-- this and decides whether the check passed):
--
--    oxt-beyond -ui tools/ci/academy-check.livecodescript
--
-- Environment variables:
--    OXT_ACADEMY_TOOLSET  the Toolset folder whose Academy is checked
--                         (required)
--
-- For each course it checks that the course has an id, a title and
-- lessons, that the ids of its lessons are unique, and that the icons of
-- the course and its units are ones revLearnKit draws. For each lesson:
--    - every <code> block runs to its end (one marked "error" must stop
--      with an error instead; "dialog" and "text" blocks are not run);
--    - every <quiz> has a question, two or more answers, exactly one of
--      them right, and a sentence on why;
--    - a <challenge> has text and checks, its solution passes every check
--      and its starter code does not.
--
-- Output on stdout: INFO lines, a PASS or FAIL line for each thing checked
-- and a SUMMARY line. The exit code is 0 when everything passed, 1 when
-- something failed and 2 when the check could not run.

local sPassed, sFailed

on startup
   local tToolset, tAcademy, tKit, tCourses, tError
   put 0 into sPassed
   put 0 into sFailed
   put $OXT_ACADEMY_TOOLSET into tToolset
   if tToolset is empty then
      write "ERROR OXT_ACADEMY_TOOLSET is not set" & return to stdout
      quit 2
   end if
   put tToolset & "/palettes/academy/revacademy.livecodescript" into tAcademy
   put tToolset & "/palettes/learn/revlearnkit.livecodescript" into tKit
   try
      get the short name of stack tAcademy
      get the short name of stack tKit
      dispatch function "revAcademyCourses" to stack "revAcademy"
      put the result into tCourses
   catch tError
      write "ERROR could not load the Academy:" && line 1 of tError & return to stdout
      quit 2
   end try
   write "INFO academy=" & tAcademy & return to stdout
   write "INFO courses=" & tCourses["count"] & return to stdout
   if tCourses["count"] is not an integer or tCourses["count"] < 1 then
      write "ERROR no courses found" & return to stdout
      quit 2
   end if
   repeat with tIndex = 1 to tCourses["count"]
      checkCourse tCourses[tIndex]
   end repeat
   write "SUMMARY passed=" & sPassed && "failed=" & sFailed & return to stdout
   if sFailed > 0 then
      quit 1
   end if
   quit 0
end startup

command checkCourse pCourse
   local tName, tIds, tLesson, tUnit
   set the itemDelimiter to slash
   put the last item of pCourse["file"] into tName
   set the itemDelimiter to comma
   write "INFO course" && tName && "(" & pCourse["lessons"] && "lessons)" & return to stdout
   expect pCourse["id"] is not empty and pCourse["title"] is not empty, tName, "has an id and a title"
   expect pCourse["lessons"] > 0, tName, "has lessons"
   expect isIcon(pCourse["icon"]), tName, "its icon" && pCourse["icon"] && "is one the kit draws"
   repeat with tUnit = 1 to pCourse["units"]
      expect isIcon(pCourse["unit"][tUnit]["icon"]), tName, "unit" && tUnit & "'s icon" && \
            pCourse["unit"][tUnit]["icon"] && "is one the kit draws"
   end repeat
   repeat with tLesson = 1 to pCourse["lessons"]
      expect pCourse["lesson"][tLesson]["id"] is not among the lines of tIds, tName, \
            "lesson" && tLesson & "'s id" && pCourse["lesson"][tLesson]["id"] && "is unique"
      put pCourse["lesson"][tLesson]["id"] & return after tIds
      checkLesson tName & "/" & pCourse["lesson"][tLesson]["id"], pCourse["lesson"][tLesson]
   end repeat
end checkCourse

command checkLesson pWhere, pLesson
   local tBlocks, tIndex, tBlock, tRun, tCheck, tStage
   dispatch function "acBlocks" to stack "revAcademy" with pLesson["body"]
   put the result into tBlocks
   put pLesson["stage"] is "yes" into tStage
   expect tBlocks["count"] > 0, pWhere, "has a body"
   repeat with tIndex = 1 to tBlocks["count"]
      put tBlocks[tIndex] into tBlock
      switch tBlock["kind"]
         case "code"
            if tBlock["flags"] contains "dialog" or tBlock["flags"] contains "text" then
               break
            end if
            put academyRun(tBlock["lines"], tStage) into tRun
            if tBlock["flags"] contains "error" then
               expect not tRun["ok"], pWhere, "code block" && tIndex && "stops with an error, as it says"
            else
               expect tRun["ok"], pWhere, "code block" && tIndex && "runs" & \
                     reason(tRun)
            end if
            break
         case "quiz"
            expect tBlock["question"] is not empty, pWhere, "quiz" && tIndex && "has a question"
            expect tBlock["optionCount"] >= 2, pWhere, "quiz" && tIndex && "has two or more answers"
            expect tBlock["right"] is an integer, pWhere, "quiz" && tIndex && "has a right answer"
            expect tBlock["explain"] is not empty, pWhere, "quiz" && tIndex && "says why"
            break
         case "challenge"
            expect tBlock["text"] is not empty, pWhere, "challenge has text"
            expect tBlock["checks"] is not empty, pWhere, "challenge has checks"
            expect tBlock["solution"] is not empty, pWhere, "challenge has a solution"
            put academyCheck(tBlock["solution"], tBlock["checks"], tStage) into tCheck
            expect tCheck["passed"], pWhere, "the challenge's solution passes its checks" & failures(tCheck)
            put academyCheck(tBlock["starter"], tBlock["checks"], tStage) into tCheck
            expect not tCheck["passed"], pWhere, "the challenge's starter does not pass"
            break
      end switch
   end repeat
   expect rightCount(pLesson["body"]), pWhere, "each quiz marks exactly one answer right"
end checkLesson

-- Whether every quiz in pBody marks one answer, and only one, with "* "
function rightCount pBody
   local tIn, tCount, tLine
   put false into tIn
   repeat for each line tLine in pBody
      if word 1 to -1 of tLine is "<quiz>" then
         put true into tIn
         put 0 into tCount
      else if word 1 to -1 of tLine is "</quiz>" then
         put false into tIn
         if tCount is not 1 then
            return false
         end if
      else if tIn and char 1 to 2 of tLine is "* " then
         add 1 to tCount
      end if
   end repeat
   return true
end rightCount

function academyRun pCode, pStage
   dispatch function "revAcademyRun" to stack "revAcademy" with pCode, pStage
   return the result
end academyRun

function academyCheck pCode, pChecks, pStage
   dispatch function "revAcademyCheck" to stack "revAcademy" with pCode, pChecks, pStage
   return the result
end academyCheck

function isIcon pName
   if pName is empty then
      return false
   end if
   dispatch function "lkIconPaths" to stack "revLearnKit" with pName
   return the result is not empty
end isIcon

-- Why a run stopped, for a FAIL line
function reason pRun
   if pRun["ok"] then
      return empty
   end if
   return " (line" && pRun["line"] & ":" && pRun["error"] & ")"
end reason

-- The checks that failed, for a FAIL line
function failures pCheck
   local tText, tIndex
   if not pCheck["run"]["ok"] then
      return reason(pCheck["run"])
   end if
   repeat with tIndex = 1 to pCheck["count"]
      if not pCheck[tIndex]["ok"] then
         put "; failed:" && pCheck[tIndex]["text"] after tText
         if pCheck[tIndex]["why"] is not empty then
            put " (" & pCheck[tIndex]["why"] & ")" after tText
         end if
      end if
   end repeat
   return tText
end failures

command expect pOk, pWhere, pWhat
   if pOk is true then
      add 1 to sPassed
      write "PASS" && pWhere & ":" && pWhat & return to stdout
   else
      add 1 to sFailed
      write "FAIL" && pWhere & ":" && pWhat & return to stdout
   end if
end expect
