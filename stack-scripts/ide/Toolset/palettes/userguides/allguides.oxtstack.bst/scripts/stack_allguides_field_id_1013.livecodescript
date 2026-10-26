script "stack_allguides_field_id_1013"
-- Stack file: ide/Toolset/palettes/userguides/allguides.oxtstack
-- Object: stack "allguides" > card "Contents" (id 1002) > group "ttitle" (id 1006) > field "tLayout" (id 1013)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

constant kUGCodeBkgnd = "190,190,190" -- light grey
constant kUGCodeText = "31,31,40" -- dark grey

constant kUGTipBkgnd = "145,255,160" -- light pastel green
constant kUGTipText = "0,70,10" -- dark green

constant kUGImpBkgnd = "125,0,120" -- dark purple
constant kUGImpText = "255,255,255" -- white

constant kUGNoteBkgnd = "255,255,0" -- yellow
constant kUGNoteText = "0,0,0" -- black

constant kUGCauBkgnd = "255,0,0" -- red
constant kUGCauText = "255,255,255" -- white

constant tComGrn = "5,127,0" -- dark green for comments

constant tItalBlue = "89,90,180" -- blue for italics

on mouseleave
   if not (there is a fld "tActualContent") then exit mouseleave
   if not (there is a fld "tLayout") then exit mouseleave
   put the vscroll of fld "tActualContent" into tOldScroll
   lock screen
   put fld "tLayout" into field "tActualContent"
   set the textStyle of fld "tActualContent" to plain
   put 0 into tBDCount
   repeat the number of lines of fld "tActualContent"
      add 1 to tBDCount
      -- just bold
      if line tBDCount of fld "tActualContent" contains "<B>" then
         replace "<B>"  with "" in line tBDCount of fld "tActualContent"
         set the textStyle of line tBDCount of fld "tActualContent" to "bold"
      end if
      -- just underline
      if line tBDCount of fld "tActualContent" contains "<U>" then
         replace "<U>"  with "" in line tBDCount of fld "tActualContent"
         set the textStyle of line tBDCount of fld "tActualContent" to "underline"
      end if
      -- bold and underline
      if line tBDCount of fld "tActualContent" contains "<BU>" then
         replace "<BU>"  with "" in line tBDCount of fld "tActualContent"
         set the textStyle of line tBDCount of fld "tActualContent" to "bold,underline"
      end if
      -- just italicise
      if line tBDCount of fld "tActualContent" contains "<I>" then
         replace "<I>"  with "" in line tBDCount of fld "tActualContent"
         set the textStyle of line tBDCount of fld "tActualContent" to "italic"
         set the textColor of  line tBDCount of fld "tActualContent" to tItalBlue
      end if
   end repeat
   --------- inline images ---------
   put 0 into tIMCount
   repeat the number of lines of fld "tActualContent"
      add 1 to tIMCount
      if line tIMCount of fld "tActualContent" contains "<IMG" then
         put line tIMCount of fld "tActualContent" into tIMGf
         put offset("<IMG",tIMGf) into tStartChar
         put offset( QUOTE & ">",tIMGf) into tEndChar
         put char (tStartChar +6) to (tEndChar -1) of tIMGf into tImgSrc
         if not (there is a image tImgSrc) then exit mouseleave -- you can get an error while mouseleave is triggered if you are editing inside a group, or if the img does not exist
         put " " into char tStartChar to tEndChar+1 of line tIMCount of field "tActualContent"
         set the imagesource of char tStartChar of line tIMCount of field "tActualContent" to (the ID of img tImgSrc)
      end if
      if line tIMCount of fld "tActualContent" contains "<rIMG" then
         -- referencing images on other cards
         put line tIMCount of fld "tActualContent" into tIMGf
         replace ":" with return in tIMGf
         put tIMGf into tIMGCard
         delete line 2 of tIMGf
         replace return with "" in tIMGf
         put line 2 of tIMGCard into tIMGCard
         -- put QUOTE & tIMGCard & QUOTE into tIMGCard
         put offset("<rIMG",tIMGf) into tStartChar
         put offset( QUOTE & ">",tIMGf) into tEndChar
         put char (tStartChar +8) to (tEndChar -1) of tIMGf into tImgSrc
         --put tImgSrc & QUOTE into tImgSrc
         if not (there is an image tImgSrc of card tIMGCard) then
            put "can't find image: " & tImgSrc & return & "of card: " & tIMGCard & return & "(line: " & tIMCount & ")"
            exit mouseleave -- you can get an error while mouseleave is triggered if you are editing inside a group, or if the img does not exist
         end if
         put " " into char tStartChar to tEndChar+3 + (the number of chars in tIMGCard)of line tIMCount of field "tActualContent"
         set the imagesource of char tStartChar of line tIMCount of field "tActualContent" to (the ID of img tImgSrc of card tIMGCard)
      end if
      
   end repeat
   --- find how many instances we need to repeat for of this type ---
   put NumOfRpts ("<code>") into tRptNum
   --------- code section ---------
   repeat tRptNum
      put 0 into tIMCount
      add 1 to tCOcount
      put fld "tActualContent" into tCodeP
      put lineOffset("<CODE>",tCodeP) into tStartLine
      put lineOffset("</CODE>",tCodeP) into tEndLine
      -- put tStartLine & return & tEndLine
      if line tStartLine of tCodeP contains "<CODE>" then
         set the textColor of line tStartLine to tEndLine of fld "tActualContent" to kUGCodeText
         set the backgroundColor of line tStartLine to tEndLine of fld "tActualContent" to kUGCodeBkgnd
         
         ---------------- comments ------------
         put tEndLine - tStartLine into tRptCount
         put tStartLine into tCOMCount
         repeat tRptCount
            add 1 to tCOMCount
            if line tCOMCount of fld "tActualContent" contains "--" then
               put line tCOMCount of fld "tActualContent" into tCheckChunk
               put offset ("-",tCheckChunk) into tStartComChar
               put the number of chars of line tCOMCount of fld "tActualContent" into tEndComChar
               set the textColor of char tStartComChar to tEndComChar of line tCOMCount of fld "tActualContent" to tComGrn
            end if
            if tCOMCount > tEndLine then exit repeat
         end repeat
         
         --------- faux block comments -----------
         repeat 10
            put line tStartLine to tEndLine of fld "tActualContent" into tCommentC
            if tCommentC contains "--!DEL" then
               -- we have comments in code
               put offset ("--!DEL", fld "tActualContent") into tDelChar
               put tDelChar +6 into tDelEndChar
               delete char tDelChar to tDelEndChar of fld "tActualContent"
            end if
         end repeat
         
         delete line tEndLine of fld "tActualContent" 
         delete line tStartLine of fld "tActualContent" 
      end if
   end repeat
   
   
   --------- tip section ---------
   --- find how many instances we need to repeat for of this type ---
   put NumOfRpts ("<tip>") into tRptNum
   --
   repeat tRptNum
      put 0 into tIMCount
      add 1 to tCOcount
      put fld "tActualContent" into tCodeP
      put lineOffset("<TIP>",tCodeP) into tStartLine
      put lineOffset("</TIP>",tCodeP) into tEndLine
      if line tStartLine of tCodeP contains "<TIP>" then
         set the textColor of line tStartLine to tEndLine of fld "tActualContent" to kUGTipText
         set the backgroundColor of line tStartLine to tEndLine of fld "tActualContent" to kUGTipBkgnd
         delete line tEndLine of fld "tActualContent" 
         delete line tStartLine of fld "tActualContent" 
      end if
   end repeat
   
   --------- important section ---------
   --- find how many instances we need to repeat for of this type ---
   put fld "tActualContent" into tMatchesCode
   filter lines of tMatchesCode with "<important>"
   put the number of lines of tMatchesCode into tRptNum
   if not isNumber(tRptNum) then put "5" into tRptNum
   --
   repeat tRptNum
      put 0 into tIMCount
      add 1 to tCOcount
      put fld "tActualContent" into tCodeP
      put lineOffset("<IMPORTANT>",tCodeP) into tStartLine
      put lineOffset("</IMPORTANT>",tCodeP) into tEndLine
      if line tStartLine of tCodeP contains "<IMPORTANT>" then
         set the textColor of line tStartLine to tEndLine of fld "tActualContent" to kUGImpText
         set the backgroundColor of line tStartLine to tEndLine of fld "tActualContent" to kUGImpBkgnd
         delete line tEndLine of fld "tActualContent" 
         delete line tStartLine of fld "tActualContent" 
      end if
   end repeat
   
   --------- note section ---------
   --- find how many instances we need to repeat for of this type ---
   put NumOfRpts ("<note>") into tRptNum
   --
   repeat tRptNum
      put 0 into tIMCount
      add 1 to tCOcount
      put fld "tActualContent" into tCodeP
      put lineOffset("<NOTE>",tCodeP) into tStartLine
      put lineOffset("</NOTE>",tCodeP) into tEndLine
      if line tStartLine of tCodeP contains "<NOTE>" then
         set the textColor of line tStartLine to tEndLine of fld "tActualContent" to kUGNoteText
         set the backgroundColor of line tStartLine to tEndLine of fld "tActualContent" to kUGNoteBkgnd
         delete line tEndLine of fld "tActualContent" 
         delete line tStartLine of fld "tActualContent" 
      end if
   end repeat
   
   --------- caution section ---------
   --- find how many instances we need to repeat for of this type ---
   put NumOfRpts ("<caution>") into tRptNum
   --
   repeat tRptNum
      put 0 into tIMCount
      add 1 to tCOcount
      put fld "tActualContent" into tCodeP
      put lineOffset("<CAUTION>",tCodeP) into tStartLine
      put lineOffset("</CAUTION>",tCodeP) into tEndLine
      if line tStartLine of tCodeP contains "<CAUTION>" then
         set the textColor of line tStartLine to tEndLine of fld "tActualContent" to kUGCauText
         set the backgroundColor of line tStartLine to tEndLine of fld "tActualContent" to kUGCauBkgnd
         delete line tEndLine of fld "tActualContent" 
         delete line tStartLine of fld "tActualContent" 
      end if
   end repeat
   ---------------- links --------------------
   put 0 into tIMCount
   repeat the number of lines of fld "tActualContent"
      add 1 to tLNCount
      put 0 into tPrefixspaces
      put "" into tCustomLink
      if line tLNCount of fld "tActualContent" contains "<ln>" then
         put line tLNCount of fld "tActualContent" into tLNline
         if char 1 of tLNline is " " then
            repeat until char 1 of tLNline is not " "
               delete char 1 of tLNline
               add 1 to tPrefixspaces
            end repeat
         end if
         if the last char of tLNline is " " then
            repeat until the last char of tLNline is not " "
               delete last char of tLNline
            end repeat
         end if
         --
         -- set the link
         -- put tLNCount & return & tLNline -- debug
         replace "<ln>" with "" in line tLNCount of field "tActualContent"
         replace "<ln>" with "" in tLNline
         put the number of chars in tLNline + tPrefixspaces into tToChars
         -- variable links
         if tLNline contains "(next)" then
            replace "(next)" with "" in tLNline
            put "go next card" into tCustomLink
            replace "(next)" with "" in line tLNCount of field "tActualContent"
         end if
         if tLNline contains "(prev)" then
            replace "(prev)" with "" in tLNline
            put "go prev card" into tCustomLink
            replace "(prev)" with "" in line tLNCount of field "tActualContent"
         end if
         if tLNline contains "tDocPath" then
            put the tDocPath of this stack into tDocPath
            replace "tDocPath" with "" in tLNline
            replace "tDocPath" & "/" with "" in line tLNCount of field "tActualContent"
            put " launch document (" & QUOTE & tDocPath & tLNline & QUOTE & ")"  into tCustomLink
         end if
         -- end variable links
         if char 1 of line tLNCount of field "tActualContent" is " " then -- trim out prefix spaces
            repeat until char 1 of line tLNCount of field "tActualContent" is not " "
               delete char 1 of line tLNCount of field "tActualContent"
            end repeat
         end if
         if tCustomLink is "" then
            set the linkText of line tLNCount of field "tActualContent" to tLNline
            set the TextStyle of char tPrefixspaces to tToChars of line tLNCount of field "tActualContent" to "link"
         else
            set the linkText of line tLNCount of field "tActualContent" to tCustomLink
            set the TextStyle of char tPrefixspaces to tToChars of line tLNCount of field "tActualContent" to "link"
         end if
      end if
   end repeat
   
   --- find how many instances we need to repeat for of this type ---
   put NumOfRpts ("*[&TAB]*") into tRptNum
   repeat tRptNum
      put fld "tActualContent" into tTabCheck
      if not (fld "tActualContent" contains "&TAB") then 
         exit repeat
      end if
      put lineOffset("&TAB",tTabCheck) into tCurLine
      --put tCurLine
      replace "&TAB" with TAB in line tCurLine of fld "tActualContent"
   end repeat
   
   set the vscroll of fld "tActualContent" to tOldScroll
   unlock screen
end mouseleave

function NumOfRpts thePhrase
   put fld "tActualContent" into tMatchesCode
   filter lines of tMatchesCode with thePhrase
   put the number of lines of tMatchesCode into tRptNum
   if not isNumber(tRptNum) then put "5" into tRptNum
   return tRptNum
end NumOfRpts
