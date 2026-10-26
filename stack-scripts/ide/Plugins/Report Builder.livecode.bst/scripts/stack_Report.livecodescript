script "stack_Report"
-- Stack file: ide/Plugins/Report Builder.livecode
-- Object: stack "Report Builder" > substack "Report"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on resizeStack  --resize & position fld "Text"
   lock screen
   set the itemdelimiter to ","
   set the rect of fld "Text" to the left of this card, the top of this card, the right of this card, the bottom of this cd - the height of btn "resizer"   --resize fld when stack is resized
   --set the loc of fld "Text" to the loc of this cd  --position fld
   set the bottomRight of btn "resizer" to the width of this stack, the height of this stack
   unlock screen
end resizeStack


on preopenstack
   lock screen
   set the scaleFactor of stack "Report" to 1
   put the right of stack "Report Builder" into tRLoc
   put the top of stack "Report Builder" into tTLoc
   add 11 to tRLoc
   add 28 to tTLoc
   set the  thumbPosition of scrollbar "scalescroll" of stack "Report Builder" to 1.0
   set the top of stack "Report" to tTLoc
   set the left of stack "Report" to tRLoc
   unlock screen
end preopenstack

on tTPColours
   put the effective Backgroundcolor of this stack into tColourDecision
   put the itemDelimiter into tOldDelim
   set the itemDelimiter to ","
   put item 1 of tColourDecision + item 2 of tColourDecision + item 3 of tColourDecision into tMaxColValues
   if tMaxColValues >510 then
      -- I've decided to set text to dark
      set the ink of btn "Resizer" of this stack to "blendDst" -- going with dark theme
   else
      -- I've decided to set text to light
      set the ink of btn "Resizer" of this stack to "srcCopy" -- going with a light grey
   end if
   set the itemDelimiter to tOldDelim
end tTPColours
