script "stack_Print_Dialog_card_id_1002"
-- Stack file: ide/Toolset/palettes/revprintdialog.rev
-- Object: stack "Print Dialog" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
   local tStackLoc
   local tScreenRect
   put line (the screen of this stack) of the screenRects into tScreenRect
   
   local tScreenWidth
   put item 3 of tScreenRect - item 1 of tScreenRect into tScreenWidth
   
   local tScreenHeight
   put item 4 of tScreenRect - item 2 of tScreenRect into tScreenHeight
   
   put item 1 of tScreenRect + (tScreenWidth div 2),item 2 of tScreenRect + (tScreenHeight div 2) into tStackLoc
   set the location of the owner of me to tStackLoc
   set the text of field "Filename" to empty
   storeCurrentPrinterSettings
   updateControls  
end preOpenCard

--------------------------------------------------------------------------------------------------

# Variables local to card that store the printer settings upon startup
local sSettingsString
local sPrinterOutput
local sPrintCopies
local sPrintCollate
local sPrintDuplex
local sPrintColors

# Used for storing the number of pages to be printed
local sPrintRange

--------------------------------------------------------------------------------------------------

command storeCurrentPrinterSettings
  put the printerSettings into sSettingsString
  put the printerOutput into sPrinterOutput
  put the printCopies into sPrintCopies
  put the printCollate into sPrintCollate
  put the printDuplex into sPrintDuplex
  put the printColors into sPrintColors
  put printRangesGet() into sPrintRange  
end storeCurrentPrinterSettings

command restorePreviousPrinterSettings
  set the printerSettings to sSettingsString
  set the printerOutput to sPrinterOutput
  set the printCopies to sPrintCopies
  set the printCollate to sPrintCollate
  set the printDuplex to sPrintDuplex
  set the printColors to sPrintColors
  printRangesSet sPrintRange
end restorePreviousPrinterSettings

# Update the controls on screen in response to the systems current settings
command updateControls
   
   local tAvailablePrinters
   put the availablePrinters into tAvailablePrinters
   
   # Check system default printer stored in printerName is a valid installed printer
   if the printerName is not among the lines of tAvailablePrinters or the printerName is empty then
      set the printerName to line 1 of the availablePrinters
   end if
   
   send "update tAvailablePrinters, the printerName" to group "Printer List"
   
   set the itemdelimiter to ":"
   if item 1 of the printerOutput is "file" then
      set the hilite of the button "Print to file" to true
      set the text of field "Filename" to item 2 to -1 of the printerOutput
   else 
      set the hilite of the button "Print to file" to false
   end if
   set the itemdelimiter to ","
   updatePrintToFileGroup
   
   set the hilite of button "Collate" to printCollate
   updateCollateImage
   
   if the printDuplex is not "none" then
      set the hilite of button "Duplex" to true
   else
      set the hilite of button "Duplex" to false
   end if
   updateDuplexGroup
   updateDuplexImage
   
   set the hilite of button "Black and white" to not the printColors
   set the text of field "No of copies" to the printCopies
   
   local tPrintRanges
   put printRangesGet() into tPrintRanges
   set the text of field "Pages" to empty
   if tPrintRanges is "all" then
      set the hilite of button "All" to true
   else if tPrintRanges is "selection" then
      set the hilite of button "selection" to true
   else if tPrintRanges is "current" then
      set the hilite of button "current" to true
   else
      set the hilite of button "Page range select" to true
      set the text of field "Pages" to tPrintRanges
   end if
   
   local tFeatures
   put printFeaturesGet(the printerName) into tFeatures
   
   set the enabled of button "Black and White" of me to ("colors" is among the items of tFeatures)
   set the enabled of field "No of Copies" of me to ("copies" is among the items of tFeatures)
   set the enabled of button "Collate" of me to ("collate" is among the items of tFeatures)
   set the enabled of button "Duplex" of me to ("duplex" is among the items of tFeatures)
end updateControls


# Apply the settings on screen to the internal values e.g. on apply or ok
command applySettings
   errorCheck
   
   if the hilite of button "Print to file" then
      set the printerOutput to "file:" & the text of field "Filename"
   else
      set the printerOutput to "device"
   end if
   
   set the printCollate to the hilite of button "Collate"
   updateCollateImage
   
   if not the hilite of button "Duplex" then
      set the printDuplex to "none"
   else
      set the printDuplex to the hilitedButtonName of group "Duplex Settings"
   end if    
   updateDuplexImage
   
   set the printColors to not the hilite of button "Black and white"
   
   set the printCopies to the text of field "No of copies"
   
   if the hilite of button "All" then
      printRangesSet "all"
   else if the hilite of button "Selection" then
      printRangesSet "selection"
   else if the hilite of button "Current" then
      printRangesSet "current"
   else
      printRangesSet the text of field "Pages"
   end if
end applySettings

command printRangesSet pValue
  set the printRanges to pValue
end printRangesSet

function printRangesGet
   return the printRanges
end printRangesGet

function printFeaturesGet pPrinter
  return the printerFeatures
end printFeaturesGet

function fieldHiliteColor
  return "49,106,197"
end fieldHiliteColor

command updateCollateImage
  # This command changes the collate image
  lock screen
  if the hilite of button "Collate" then    
    set the visible of image "collateTrue.PNG" to true
    set the visible of image "collateFalse.PNG" to false
  else
    set the visible of image "collateTrue.PNG" to false
    set the visible of image "collateFalse.PNG" to true
  end if
  unlock screen
end updateCollateImage

command updateDuplexImage
  lock screen
  
  local tPaperOrientation
  put the printPaperOrientation into tPaperOrientation
  
  if the hilite of button "Duplex" then
    set the visible of graphic "Duplex overlay" to false
     
    if the hilite of button "Long edge" and tPaperOrientation is "landscape" then
      set the visible of image "long edge landscape.PNG" to true
      set the visible of image "long edge portrait.PNG" to false
      set the visible of image "short edge landscape.PNG" to false
      set the visible of image "short edge portrait.PNG" to false
    else if the hilite of button "Long edge" and tPaperOrientation is "portrait" then
      set the visible of image "long edge landscape.PNG" to false
      set the visible of image "long edge portrait.PNG" to true
      set the visible of image "short edge landscape.PNG" to false
      set the visible of image "short edge portrait.PNG" to false
    else if the hilite of button "Short edge" and tPaperOrientation is "landscape" then
      set the visible of image "long edge landscape.PNG" to false
      set the visible of image "long edge portrait.PNG" to false
      set the visible of image "short edge landscape.PNG" to true
      set the visible of image "short edge portrait.PNG" to false
    else
      set the visible of image "long edge landscape.PNG" to false
      set the visible of image "long edge portrait.PNG" to false
      set the visible of image "short edge landscape.PNG" to false
      set the visible of image "short edge portrait.PNG" to true
    end if
    
  else
    set the visible of graphic "Duplex overlay" to true
  end if
   
  unlock screen
end updateDuplexImage

command updateDuplexGroup
  if the hilite of button "Duplex" then
    set the enabled of group "Duplex Settings" to true
  else
    set the enabled of group "Duplex Settings" to false
  end if
end updateDuplexGroup

command updatePrintToFileGroup
  set the enabled of field "Filename" to the hilite of button "Print to file" of me
  set the enabled of button "Browse" to the hilite of button "Print to file" of me
end updatePrintToFileGroup

# Here block keys that will produce invalid characters
on keyDown pKey
  if pKey is not a number and pKey is not "," and pKey is not "-" and pKey is not space then
    -- block keyDown
  else
    pass keyDown
  end if
end keyDown

on mouseUp
  tidyPrintRange
end mouseUp



# Here block return and enter messages so the fields in this card can only have one line of text
on returnInField
end returnInField
on enterInField
end enterInField

# Need to perform error checking to make sure the fields do not contain 0s -ve values etc
local sErrorControl

command errorCheck
  errorClearDo
  if field "No of copies" is empty or text of field "No of copies" < 1 then
    error the long id of field "No of copies" of me, "Invalid number specified, must be integer value greater than 1"
  end if    
  
  local tPrintRangeError
  # Is this the right thing to do???
  if hilite of button "Page range select" then
    put checkPrintRangeString() into tPrintRangeError
    if tPrintRangeError is not empty then
      error the long id of field "Pages" of me, tPrintRangeError
    end if
  end if
  
end errorCheck

command error pControl, pMessage
  put pMessage into field "Error" of me
  if there is a graphic "Error Border" of me then
    delete graphic "Error Border" of me
  end if
  reset the templateGraphic
  set the style of the templateGraphic to "rectangle"
  set the foregroundColor of the templateGraphic to "red"
  set the rect of the templateGraphic to the rect of pControl
  create graphic "Error Border"
  reset the templateGraphic
  put pControl into sErrorControl
  exit to top
end error

command errorClear pControl
  if sErrorControl is empty then
    exit errorClear
  end if
  -- If pControl is not the control that the last error applied to, then we just ignore this.
  if (pControl is not empty) and (the long id of pControl is not the long id of of sErrorControl) then
    exit errorClear
  end if
  errorClearDo
end errorClear

command errorClearDo
  put empty into field "Error"
  if there is a graphic "Error Border" of me then
    delete graphic "Error Border" of me
  end if
  put empty into sErrorControl
end errorClearDo

constant kLetters = "abcdefghijklmnopqrstuvwxyz"

constant kPrintRangeExpression = "^[0-9]+$|^[0-9]+\-[0-9]+$"

# This function checks the format of the print range string
function checkPrintRangeString
  # Remove all spaces (but not other whitespace chars, as we want to error an error if these are present)
  tidyPrintRange
  
  local tRanges
  put the text of field "Pages" of me into tRanges
  
  # Check that there is at least one range
  if the number of items of tRanges is 0 then
    return "No page ranges specified"
  end if
  
  # Check that each range is valid
  repeat for each item tRange in tRanges
    if not matchText(tRange, kPrintRangeExpression) then
      return "Invalid range specified: " & tRange
    end if
  end repeat
  
  return empty
end checkPrintRangeString

command tidyPrintRange
  local tRanges
  put the text of field "Pages" of me into tRanges
  replace space with empty in tRanges
  put tRanges into field "Pages" of me
end tidyPrintRange











