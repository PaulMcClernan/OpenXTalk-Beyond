script "stack_revReplicate_button_id_1041"
-- Stack file: ide/Toolset/palettes/replicate.oxtstack
-- Object: stack "revReplicate" > card (id 1002) > button "OK" (id 1041)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local lAngle, lControl

on mouseUp
   ## EJB 14-07-20414
   ## [[ Bug 11240 ]] lock screen removed so duplicated controls reveive messages
   --lock messages
   
   lock screen
   set the cursor to watch
   put true into tPolygon
   repeat for each line l in the selObj
      if word 1 of l is not "graphic" then put false into tPolygon
      else if the style of l is not "polygon" then put false into tPolygon
   end repeat
   if tPolygon then
      put the label of btn "rotate" of stack "revReplicate" into tOrigAngle
      put the label of btn "Rotate" of stack "revReplicate" into lAngle
      if lAngle is not a number or abs(lAngle) > 360 then
         beep
         select text of btn "Rotate" of stack "revReplicate"
         exit to top
      end if
   end if
   put the text of fld "Replicate" into tReplicate
   put 0 into tRepeatCounter
   put the milliseconds into tMillisecs
   set the defaultStack to the topStack
   repeat tReplicate
      add 1 to tRepeatCounter
      add tOrigAngle to lAngle
      repeat for each line l in the selObj
         if word 1 of the name of l is "group" then
            put the number of controls in l into tNumber
         else
            put 0 into tNumber
         end if
         clone l
         if tPolygon is not false then revRotatePoly
         put the width of l + (fld "hScale" of stack "revReplicate"*tRepeatCounter) into tNewWidth
         set the width of control (the number of controls - tNumber) to tNewWidth
         put the height of l + (fld "vScale" of stack "revReplicate"*tRepeatCounter) into tNewHeight
         set the height of control (the number of controls - tNumber) to tNewHeight
         set the topLeft of control (the number of controls - tNumber) to  item 1 of the topLeft of l + (fld "hOffset" of stack "revReplicate"*tRepeatCounter),item 2 of the topLeft of l + (fld "vOffset" of stack "revReplicate"*tRepeatCounter)
         put the short name of control (the number of controls - tNumber) && "1" into tNewName
         repeat
            if there is a control tNewName then add 1 to last word of tNewName
            else exit repeat
         end repeat
         set the name of control (the number of controls - tNumber) to tNewName
         set the cREVGeneral["revUniqueID"] of last control to tMillisecs
         add 1 to tMillisecs
      end repeat
   end repeat
   --unlock messages
   close stack "revReplicate"
   send "selectedObjectChanged" to btn "revBackScript" of stack "revLibrary"
   revUpdateAOControls (line 1 of the selObj)
   unlock screen
end mouseUp

on revRotatePoly
  put the long id of last control into lControl
  put revPoints() into tPoints
  put the loc of lControl into tLoc
  put sin(lAngle * (pi / 180)) into tSinAngle
  put cos(lAngle * (pi / 180)) into tCosAngle
  put (number of items of tPoints) div 2 into tNumItems
  repeat with i = 1 to tNumItems
    put (item (i + (i - 1)) of tPoints) into tCurrentH -- + item 1 of the center
    put (item (i + i) of tPoints) into tCurrentV -- + item 2 of the center
    put trunc((tCosAngle * tCurrentH) - (tSinAngle * tCurrentV)) into tTempH
    put trunc((tSinAngle * tCurrentH) + (tCosAngle * tCurrentV)) into tTempV
    put tTempH + (item 1 of tPoints) into tCurrentH
    put tTempV + (item 2 of tPoints) into tCurrentV
    put tCurrentH,tCurrentV & comma after tFinalPoints
  end repeat
  delete last char of tFinalPoints
  set the points of lControl to tFinalPoints
end revRotatePoly

function revPoints
  put the number of lines in the points of lControl into tNumPoints
  put empty into tResult
  put item 1 of loc of lControl into tStartlH
  put item 2 of loc of lControl into tStartV
  put the points of lControl into tPoints
  replace cr with comma in tPoints
  if last char of tPoints is comma then delete last char of tPoints
  repeat with i = 1 to tNumPoints
    put (item (i + (i - 1)) of tPoints) - tStartlH into tCurrentH
    put (item (i + i) of tPoints) - tStartV into tCurrentV
    put tCurrentH,tCurrentV & comma after tResult
  end repeat
  delete last char of tResult
  return tResult
end revPoints
