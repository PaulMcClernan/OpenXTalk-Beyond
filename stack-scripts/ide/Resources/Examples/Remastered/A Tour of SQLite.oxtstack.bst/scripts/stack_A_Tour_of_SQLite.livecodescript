script "stack_A_Tour_of_SQLite"
-- Stack file: ide/Resources/Examples/Remastered/A Tour of SQLite.oxtstack
-- Object: stack "A Tour of SQLite"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

--A Tour of SQLite: LiveCode Ltd's SQLite Tour v1.0, remastered for OXT-Beyond in 2026
--SQLite Tour v1.0, (c) LiveCode Ltd, edited and debranded for open source as requested by LiveCode Ltd.

--Each chapter's program is in the scripts of its buttons (and, on a few, of its card): click
--a button, or open the Scripts drawer, to read them. Where the original tour answered in a
--dialog, they say what happened in the panel under the buttons, with showResult, below, and
--the tables, the schema and the drawings they fill are brought up to date here too.
--The tour's databases are files in the temporary folder, which a program can always write
--to. (The original kept them on the desktop: the remaster sits in the IDE's Resources
--folder, which may be read-only, and a browser has no desktop.)
--The original's openCard put each card's name into its title and its chapter slider: the
--window's sidebar and header do that now, in the script of the group "Frame".

global gConID  --the connection to the database, as the tour's scripts keep it

local sCodeFont  --the font code is shown in, found once

on preOpenCard
   codeFonts
   if there is a field "Status" then
      showResult "info", the cHint of this card  --each visit starts with the card's hint
   end if
   pass preOpenCard
end preOpenCard

################################################################################
# What the buttons did

-- In the panel under the buttons: pKind is "ok", "error" or "info", and pMessage what
-- happened, its first line in bold. Then the card is brought up to date with the database
command showResult pKind, pMessage
   local tHtml, tLine, tBack, tEdge, tMid, tHeight
   if there is no field "Status" then
      answer pMessage  --(a card without the panel)
      exit showResult
   end if
   lock screen
   repeat for each line tLine in pMessage
      if tHtml is empty then
         put "<p><b>" & htmlOf(tLine) & "</b></p>" after tHtml
      else
         put "<p>" & htmlOf(tLine) & "</p>" after tHtml
      end if
   end repeat
   hide image "StatusOk"
   hide image "StatusError"
   hide image "StatusInfo"
   switch pKind
      case "ok"
         show image "StatusOk"
         put the cOkBack of this stack into tBack
         put the cOkEdge of this stack into tEdge
         break
      case "error"
         show image "StatusError"
         put the cErrorBack of this stack into tBack
         put the cErrorEdge of this stack into tEdge
         break
      default
         show image "StatusInfo"
         put the cInfoBack of this stack into tBack
         put the cInfoEdge of this stack into tEdge
   end switch
   set the backgroundColor of graphic "StatusBg" to tBack
   set the foregroundColor of graphic "StatusBg" to tEdge
   set the htmlText of field "Status" to tHtml
   -- (a line or two, in the middle of the panel)
   put item 2 of the loc of graphic "StatusBg" into tMid
   put the formattedHeight of field "Status" into tHeight
   -- (taller than its words by a few pixels, so that no descender is cut)
   set the rect of field "Status" to item 1 of the rect of field "Status", tMid - tHeight div 2 - 2, \
         item 3 of the rect of field "Status", tMid - tHeight div 2 + tHeight + 6
   showCard
   unlock screen
end showResult

-- The card, as the database is now
command showCard
   showConnection
   showTables
   showLive
   showReport
   showSQL
   fitTables
   showEmpty
end showCard

################################################################################
# The connection

-- The database the tour is connected to, by the name of its file: in the badge at the top,
-- and in the Connect card's drawing
command showConnection
   local tFile, tName, tOn
   put connectedFile() into tFile
   put tFile is not empty into tOn
   set the itemDelimiter to slash
   put the last item of tFile into tName
   if there is a field "Badge" then
      if tOn then
         set the text of field "Badge" to tName & ", ID" && gConID
      else
         set the text of field "Badge" to "Not connected"
      end if
      lightBadge tOn
   end if
   if there is a graphic "LinkLine" then
      drawLink tOn, tFile
   end if
end showConnection

-- The path of the file of the database gConID is connected to, or empty
function connectedFile
   local tList, tError
   if gConID is empty then
      return empty
   end if
   try
      put revDataFromQuery(tab, return, gConID, "PRAGMA database_list") into tList
   catch tError
      return empty  --(no such connection, or no revDB)
   end try
   if "revdberr" is in tList then
      return empty
   end if
   set the itemDelimiter to tab
   return item 3 of line 1 of tList
end connectedFile

-- The badge, green when connected, and as wide as its words, its right where it was
private command lightBadge pOn
   local tRight, tWidth
   if pOn then
      set the backgroundColor of graphic "BadgeDot" to the cOn of this stack
      set the backgroundColor of graphic "BadgeBg" to the cOnBack of this stack
      set the foregroundColor of graphic "BadgeBg" to the cOnEdge of this stack
   else
      set the backgroundColor of graphic "BadgeDot" to the cOff of this stack
      set the backgroundColor of graphic "BadgeBg" to the cOffBack of this stack
      set the foregroundColor of graphic "BadgeBg" to the cOffEdge of this stack
   end if
   put the right of graphic "BadgeBg" into tRight
   put measureText(the text of field "Badge", field "Badge") into tWidth
   set the rect of graphic "BadgeBg" to tRight - tWidth - 42, the top of graphic "BadgeBg", tRight, the bottom of graphic "BadgeBg"
   set the left of graphic "BadgeDot" to tRight - tWidth - 28
   set the rect of field "Badge" to tRight - tWidth - 14, the top of field "Badge", tRight - 6, the bottom of field "Badge"
end lightBadge

-- The Connect card's drawing: the line from your stack to the database, and its file
private command drawLink pOn, pFile
   local tPath
   if pOn then
      set the dashes of graphic "LinkLine" to empty
      set the foregroundColor of graphic "LinkLine" to the cOn of this stack
      set the text of field "LinkLabel" to "connected: gConID is" && gConID
      set the textColor of field "LinkLabel" to the cOn of this stack
      set the backgroundColor of graphic "LinkPill" to the cOnBack of this stack
      set the foregroundColor of graphic "LinkPill" to the cOnEdge of this stack
      put pFile into tPath
   else
      set the dashes of graphic "LinkLine" to "6,6"
      set the foregroundColor of graphic "LinkLine" to the cOff of this stack
      set the text of field "LinkLabel" to "not connected"
      set the textColor of field "LinkLabel" to the cOffInk of this stack
      set the backgroundColor of graphic "LinkPill" to the cOffBack of this stack
      set the foregroundColor of graphic "LinkPill" to the cOffEdge of this stack
      put specialFolderPath("temporary") & "/AppRegister.sqlite" into tPath  --where the buttons make it
   end if
   if there is a file tPath then
      set the text of field "LinkFile" to tPath
      set the blendLevel of graphic "LinkBaseBox" to 0
      set the blendLevel of image "LinkBaseIcon" to 0
   else
      set the text of field "LinkFile" to tPath && "(not made yet)"
      set the blendLevel of graphic "LinkBaseBox" to 50
      set the blendLevel of image "LinkBaseIcon" to 60
   end if
   set the itemDelimiter to slash
   set the text of field "LinkBaseName" to the last item of tPath
end drawLink

################################################################################
# Tables

-- The Create Tables card: each table it draws says whether the database has it yet
command showTables
   local tList, tTable
   if there is no field "usersState" then
      exit showTables
   end if
   put tablesNow() into tList
   repeat for each item tTable in "users,apps"
      if tTable is among the lines of tList then
         set the text of field (tTable & "State") to "created"
         set the textColor of field (tTable & "State") to the cOn of this stack
         set the backgroundColor of graphic (tTable & "StateBg") to the cOnBack of this stack
         set the foregroundColor of graphic (tTable & "StateBg") to the cOnEdge of this stack
         set the blendLevel of field (tTable & "Columns") to 0
      else
         set the text of field (tTable & "State") to "not created yet"
         set the textColor of field (tTable & "State") to the cOffInk of this stack
         set the backgroundColor of graphic (tTable & "StateBg") to the cOffBack of this stack
         set the foregroundColor of graphic (tTable & "StateBg") to the cOffEdge of this stack
         set the blendLevel of field (tTable & "Columns") to 50
      end if
   end repeat
end showTables

-- The names of the tables in the database, a line each
function tablesNow
   local tList, tError
   if gConID is empty then
      return empty
   end if
   try
      put revDataFromQuery(tab, return, gConID, "SELECT name FROM sqlite_master WHERE type='table'") into tList
   catch tError
      return empty
   end try
   if "revdberr" is in tList then
      return empty
   end if
   return tList
end tablesNow

-- A field with a query of its own (its custom property cQuery) shows what the query finds now
command showLive
   local tIndex, tObj, tList, tError
   repeat with tIndex = 1 to the number of controls of this card
      put the long id of control tIndex of this card into tObj
      if word 1 of tObj is not "field" or the cQuery of tObj is empty then
         next repeat
      end if
      put empty into tList
      if gConID is not empty then
         try
            put revDataFromQuery(tab, return, gConID, the cQuery of tObj) into tList
         catch tError
            put empty into tList
         end try
         if "revdberr" is in tList then
            put empty into tList
         end if
      end if
      if tList is empty then
         put the cEmpty of tObj into tList  --(what a box says when it has nothing to show)
      end if
      set the text of tObj to tList
   end repeat
end showLive

-- Each table on the card (a field whose custom property cHead names its header): its header
-- from its table's columns, if it names a table (cTable), and each column as wide as what it
-- holds, sharing the table's width
command fitTables
   local tIndex, tObj
   repeat with tIndex = 1 to the number of controls of this card
      put the long id of control tIndex of this card into tObj
      if word 1 of tObj is "field" and the cHead of tObj is not empty then
         fitTable tObj, the long id of field (the cHead of tObj)
      end if
   end repeat
end fitTables

private command fitTable pField, pHead
   local tNames, tCount, tCol, tWidth, tLine, tTotal, tRoom, tStops, tX
   if the cTable of pField is not empty then
      put columnsOf(the cTable of pField) into tNames
      if tNames is not empty then
         set the text of pHead to tNames
      end if
   end if
   set the itemDelimiter to tab
   put the number of items of the text of pHead into tCount
   repeat for each line tLine in the text of pField
      put max(tCount, the number of items of tLine) into tCount
   end repeat
   if tCount < 2 then
      exit fitTable
   end if
   repeat with tCol = 1 to tCount
      put measureText(item tCol of the text of pHead, pHead) + 24 into tWidth[tCol]
   end repeat
   repeat for each line tLine in the text of pField
      repeat with tCol = 1 to tCount
         put max(tWidth[tCol], measureText(item tCol of tLine, pField) + 24) into tWidth[tCol]
      end repeat
   end repeat
   put 0 into tTotal
   repeat with tCol = 1 to tCount
      add tWidth[tCol] to tTotal
   end repeat
   put the width of pField - 16 into tRoom
   put 0 into tX
   repeat with tCol = 1 to tCount - 1
      add tWidth[tCol] * tRoom / tTotal to tX
      put round(tX) & comma after tStops
   end repeat
   delete the last char of tStops
   set the tabStops of pField to tStops
   set the tabStops of pHead to tStops
end fitTable

-- Each table with words for when it is empty (its custom property cEmptyHint names them):
-- they show while it has no rows
command showEmpty
   local tIndex, tObj
   repeat with tIndex = 1 to the number of controls of this card
      put the long id of control tIndex of this card into tObj
      if word 1 of tObj is "field" and the cEmptyHint of tObj is not empty then
         set the visible of field (the cEmptyHint of tObj) to (word 1 to -1 of the text of tObj is empty)
      end if
   end repeat
end showEmpty

-- The names of a table's columns, tab-delimited, from PRAGMA table_info
function columnsOf pTable
   local tList, tLine, tNames, tError
   if gConID is empty then
      return empty
   end if
   try
      put revDataFromQuery(tab, return, gConID, "PRAGMA table_info(" & pTable & ")") into tList
   catch tError
      return empty
   end try
   if "revdberr" is in tList then
      return empty
   end if
   set the itemDelimiter to tab
   repeat for each line tLine in tList
      put item 2 of tLine & tab after tNames
   end repeat
   delete the last char of tNames
   return tNames
end columnsOf

################################################################################
# Reports

-- The Reports card: the circles show the join the report's SQL makes, and the table's header
-- names what it selects
command showReport
   local tSQL, tKind
   if there is no field "ReportSQL" then
      exit showReport
   end if
   put the text of field "ReportSQL" into tSQL
   replace return with space in tSQL
   if word 1 of tSQL is not "SELECT" then
      put "none" into tKind
   else if " LEFT JOIN " is in tSQL then
      put "outer" into tKind
   else
      put "inner" into tKind
   end if
   set the textColor of field "VennUsers" to the cVennInk of this stack
   switch tKind
      case "inner"
         set the backgroundColor of graphic "VennLeft" to the cVennOff of this stack
         set the backgroundColor of graphic "VennLens" to the cVennOn of this stack
         set the text of field "VennCaption" to "Inner join: only the rows that match in both."
         break
      case "outer"
         set the backgroundColor of graphic "VennLeft" to the cVennOn of this stack
         set the backgroundColor of graphic "VennLens" to the cVennOn of this stack
         set the textColor of field "VennUsers" to "255,255,255"  --(on the filled circle)
         set the text of field "VennCaption" to "Left outer join: every user, with apps or not."
         break
      default
         set the backgroundColor of graphic "VennLeft" to the cVennOff of this stack
         set the backgroundColor of graphic "VennLens" to the cVennMid of this stack
         set the text of field "VennCaption" to "Two tables, and the rows where they meet."
   end switch
   if tKind is not "none" then
      set the text of field "ReportHead" to selectList(tSQL)
   end if
end showReport

-- What a SELECT returns, for a header: the columns between SELECT and FROM, tab-delimited
private function selectList pSQL
   local tList, tItem, tHead
   put char 8 to offset(" FROM ", pSQL) - 1 of pSQL into tList
   repeat for each item tItem in tList
      put word 1 to -1 of tItem & tab after tHead
   end repeat
   delete the last char of tHead
   return tHead
end selectList

################################################################################
# SQL and code in colour

-- A box of SQL a script fills (custom property cSQL), in colour, a clause a line
command showSQL
   local tIndex, tObj
   repeat with tIndex = 1 to the number of controls of this card
      put the long id of control tIndex of this card into tObj
      if word 1 of tObj is "field" and the cSQL of tObj is true then
         set the htmlText of tObj to sqlHtml(the text of tObj)
      end if
   end repeat
end showSQL

-- SQL in colour; a SELECT on one line is broken before each of its clauses
function sqlHtml pSQL
   local tHtml, tLine, tPart
   repeat for each line tLine in pSQL
      if word 1 of tLine is "SELECT" and " FROM " is in tLine then
         repeat for each item tPart in "FROM,LEFT JOIN,WHERE,ON,GROUP BY,ORDER BY"
            replace (space & tPart & space) with (return & tPart & space) in tLine
         end repeat
         replace " AND " with (return & "  AND ") in tLine
      end if
      repeat for each line tPart in tLine
         put "<p>" & sqlLineHtml(tPart) & "</p>" after tHtml
      end repeat
   end repeat
   return tHtml
end sqlHtml

-- A line of SQL in colour: its words, the types of its columns, its numbers, its quoted
-- strings and a comment each in their own colour
function sqlLineHtml pLine
   local tOut, tPos, tLen, tChar, tStart, tWord
   if word 1 of pLine begins with "--" then
      return spanOf(pLine, the cSqlComment of this stack)
   end if
   put the number of chars of pLine into tLen
   put 1 into tPos
   repeat while tPos <= tLen
      put char tPos of pLine into tChar
      if tChar is "'" then
         put tPos into tStart
         add 1 to tPos
         repeat while tPos <= tLen and char tPos of pLine is not "'"
            add 1 to tPos
         end repeat
         put spanOf(char tStart to tPos of pLine, the cSqlString of this stack) after tOut
         add 1 to tPos
      else if tChar is not empty and tChar is in "abcdefghijklmnopqrstuvwxyz0123456789_." then
         put tPos into tStart
         repeat while tPos <= tLen and char tPos of pLine is in "abcdefghijklmnopqrstuvwxyz0123456789_."
            add 1 to tPos
         end repeat
         put char tStart to tPos - 1 of pLine into tWord
         put spanOf(tWord, sqlColor(tWord)) after tOut
      else
         put htmlOf(tChar) after tOut
         add 1 to tPos
      end if
   end repeat
   return tOut
end sqlLineHtml

private function sqlColor pWord
   if pWord is a number then
      return the cSqlNumber of this stack
   end if
   if pWord is among the items of "SELECT,FROM,WHERE,AND,OR,NOT,INSERT,INTO,VALUES,UPDATE,SET,DELETE,CREATE," & \
         "TABLE,DROP,LEFT,RIGHT,INNER,OUTER,JOIN,ON,GROUP,BY,ORDER,COUNT,BEGIN,TRANSACTION,COMMIT,ROLLBACK," & \
         "TEMPORARY,PRIMARY,KEY,AUTOINCREMENT,NULL,IF,EXISTS,AS,LIKE,ALTER,ADD,COLUMN,PRAGMA" then
      return the cSqlWord of this stack
   end if
   if pWord is among the items of "integer,text,boolean,blob,real,float,date,time,char,double,long,varchar" then
      return the cSqlType of this stack
   end if
   return the cSqlName of this stack
end sqlColor

private function spanOf pText, pColor
   return "<font color=" & quote & pColor & quote & ">" & htmlOf(pText) & "</font>"
end spanOf

function htmlOf pText
   replace "&" with "&amp;" in pText
   replace "<" with "&lt;" in pText
   replace ">" with "&gt;" in pText
   return pText
end htmlOf

-- Code in the code font (the fields whose custom property cCode is true): Source Code Pro,
-- which the IDE carries for its Script Editor, else Droid Sans Mono, which its Dictionary
-- carries (the web engine can load that one), else a monospaced font the computer has, as
-- the window's scripts panel chooses
command codeFonts
   local tIndex, tObj
   if sCodeFont is empty then
      put codeFont() into sCodeFont
   end if
   if sCodeFont is "-" then
      exit codeFonts
   end if
   repeat with tIndex = 1 to the number of controls of this card
      put the long id of control tIndex of this card into tObj
      if word 1 of tObj is "field" and the cCode of tObj is true then
         set the textFont of tObj to sCodeFont
      end if
   end repeat
end codeFonts

private function codeFont
   local tError, tFont
   if the environment is "development" then
      try
         if "Source Code Pro" is not among the lines of the fontNames then
            start using font file (revIDESpecialFolderPath("fonts") & "/SourceCodePro-Regular.ttf")
         end if
      catch tError
      end try
      try
         if "Source Code Pro" is not among the lines of the fontNames and \
               "Droid Sans Mono" is not among the lines of the fontNames then
            start using font file (revIDESpecialFolderPath("IDE") & \
                  "/Documentation/html_viewer/resources/data/api/DroidSansMono.ttf")
         end if
      catch tError
      end try
   end if
   repeat for each item tFont in "Source Code Pro,Droid Sans Mono,Menlo,Consolas,DejaVu Sans Mono,Courier New"
      if tFont is among the lines of the fontNames then
         return tFont
      end if
   end repeat
   return "-"
end codeFont

################################################################################
# Clicks and the wheel

-- A click on a button: until what it does is done, and if its dialog is cancelled, the panel
-- gives the card's hint, not what the last button did. (The window itself shows the button's
-- script in the Scripts drawer, as it does any control's.) These buttons are groups (the
-- kit's), whose parts have no scripts of their own
on mouseDown pButton
   local tOwner
   put the long owner of the target into tOwner
   if pButton is 1 and word 1 of tOwner is "group" and the script of tOwner is not empty \
         and the cLit of tOwner is not empty and not isOwn(tOwner) then
      if there is a field "Status" then
         showResult "info", the cHint of this card
      end if
   end if
   pass mouseDown
end mouseDown

-- True for the window's own controls: the groups Frame, Workbench and Scripts, and theirs
private function isOwn pObj
   local tObj
   put pObj into tObj
   repeat while word 1 of tObj is not "card" and word 1 of tObj is not "stack" and tObj is not empty
      if word 1 of tObj is "group" and the short name of tObj is among the items of "Frame,Workbench,Scripts" then
         return true
      end if
      put the long owner of tObj into tObj
   end repeat
   return false
end isOwn

-- The wheel scrolls a table or a box of code under the pointer (custom property cWheel), as
-- the window's own scripts panel scrolls
on rawKeyDown pKey
   local tObj
   if pKey is not 65308 and pKey is not 65309 then
      pass rawKeyDown
   end if
   put wheelField() into tObj
   if tObj is empty then
      pass rawKeyDown
   end if
   if pKey is 65308 then
      set the vScroll of tObj to the vScroll of tObj + 48
   else
      set the vScroll of tObj to max(0, the vScroll of tObj - 48)
   end if
end rawKeyDown

private function wheelField
   local tIndex, tObj
   if there is a group "Scripts" and the visible of group "Scripts" and the mouseLoc is within the rect of group "Scripts" then
      return empty  --(the drawer is open over it)
   end if
   repeat with tIndex = 1 to the number of controls of this card
      put the long id of control tIndex of this card into tObj
      if word 1 of tObj is "field" and the cWheel of tObj is true and the visible of tObj \
            and the mouseLoc is within the rect of tObj then
         return tObj
      end if
   end repeat
   return empty
end wheelField
