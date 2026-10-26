script "stack_Page_Setup_Dialog_card_id_1002"
-- Stack file: ide/Toolset/palettes/revpagesetupdialog.rev
-- Object: stack "Page Setup Dialog" > card (id 1002)
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
   
   local tPaperSize
   put the printPaperSize into tPaperSize
   
   local tName
   put paperSizeName(tPaperSize) into tName
   set the menuHistory of button "Paper Size" of me to lineOffset(tName, the text of button "Paper Size" of me)
   
   # Convert page width and height values to their default values for displaying in their respective fields
   local tPaperWidth
   local tPaperHeight
   put round(convertValueFromPoints(item 1 of tPaperSize, defaultUnit()),2) into tPaperWidth
   put round(convertValueFromPoints(item 2 of tPaperSize, defaultUnit()),2) into tPaperHeight
   
   put tPaperWidth && defaultUnit() into field "Paper Width" of me
   put tPaperHeight && defaultUnit() into field "Paper Height" of me
   
   if tName is "Custom" then
      set the enabled of field "Paper Width" of me to true
      set the enabled of field "Paper Height" of me to true
   else
      set the enabled of field "Paper Width" of me to false
      set the enabled of field "Paper Height" of me to false
   end if
   
   --set hilitedButtonName of group "Paper Orientation" of me to printPaperOrientation
   
   set the hilite of button "Portrait" of group "Paper orientation" to (word -1 of printPaperOrientation is "portrait")
   set the hilite of button "Landscape" of group "Paper orientation" to (word -1 of printPaperOrientation is "landscape")
   
   if the platform is "Win32" then
      set the enabled of button "Reverse" of group "Paper orientation" to false
   else
      set the enabled of button "Reverse" of group "Paper orientation" to true
      set the hilite of button "Reverse" of group "Paper orientation" to (word 1 of printPaperOrientation is "reverse")
   end if
   
   local tMargins
   put the printMargins into tMargins
   
   put round(convertValueFromPoints(item 1 of tMargins, defaultUnit()),2) && defaultUnit() into field "Left Margin" of group "Print Margins" of me
   put round(convertValueFromPoints(item 2 of tMargins, defaultUnit()),2) && defaultUnit() into field "Top Margin" of group "Print Margins" of me
   put round(convertValueFromPoints(item 3 of tMargins, defaultUnit()),2) && defaultUnit() into field "Right Margin" of group "Print Margins" of me
   put round(convertValueFromPoints(item 4 of tMargins, defaultUnit()),2) && defaultUnit() into field "Bottom Margin" of group "Print Margins" of me
   
   local tPercentageScaleDisplay
   put round(the printPaperScale * 100) into tPercentageScaleDisplay
   
   local tPercentageScaleValue
   put the printPaperScale * 100 into tPercentageScaleValue
   
   local tLineNumber
   put lineOffset(tPercentageScaleDisplay, the text of button "Scale" of me) into tLineNumber
   if tLineNumber is 0 then
      set the label of button "Scale" of me to tPercentageScaleDisplay
   else
      set the menuHistory of button "Scale" of me to tLineNumber
   end if
   
   set the cValue of button "Scale" of me to tPercentageScaleValue
   
   updatePreview
   
end preOpenCard

---------------------------------------------------------------------------------------------------------------------------

constant kCentimetresPerInch = "2.54"
constant kPointsPerInch = "72"

# Given a paper width and height, returns the name of the paper size these
# correspond to. If the width and height don't match with any known name, then
# the function returns "Custom". pSize is width,height- both in points.
function paperSizeName pSize
  switch pSize
  case "612,792"
    return "Letter"
    break
  case "612,1008"
    return "Legal"
    break
  case "522,756"
    return "Executive"
    break
  case "1224,792"
    return "Ledger"
    break
  case "595,842"
    return "A4"
    break
  case "595,1191"
    return "A3"
    break
  case "420,595"
    return "A5"
    break
  case "298,420"
    return "A6"
    break
  default
    return "Custom"
  end switch
end paperSizeName

function paperNameSize pName
  switch pName
  case "Letter"
    return "612,792"
    break
  case "Legal"
    return "612,1008"
    break
  case "Executive"
    return "522,756"
    break
  case "Ledger"
    return "1224,792"
    break
  case "A4"
    return "595,842"
  case "A3"
    return "842,1191"
    break
  case "A5"
    return "420,595"
    break
  case "A6"
    return "298,420"
    break
  case "Custom"
    return "72,72"
    break
  end switch
end paperNameSize

---------------------------------------------------------------------------------------------------------------------------

# pPaperSize will be one of "A4,A3,..."
command changePaperSize pPaperSize
  if pPaperSize is "Custom" then
    set the enabled of field "Paper Width" to true
    set the enabled of field "Paper Height" to true
  else
    set the enabled of field "Paper Width" to false
    set the enabled of field "Paper Height" to false
    local tPaperSizeInPoints
    put paperNameSize(pPaperSize) into tPaperSizeInPoints
    
    put round(convertValueFromPoints(item 1 of tPaperSizeInPoints, defaultUnit()),2) && defaultUnit() into field "Paper Width" of me
    put round(convertValueFromPoints(item 2 of tPaperSizeInPoints, defaultUnit()),2) && defaultUnit() into field "Paper Height" of me
  end if
end changePaperSize

---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------

command closeAccept
  
  # Check that all relevant values are valid before continuing
  pageCheckForErrors
  
  updatePreview
  
  local tPrintPaperWidth, tPrintPaperHeight
  put convertStringToPoints(the text of field "Paper Width" of group "Paper Size" of me) into tPrintPaperWidth
  put convertStringToPoints(the text of field "Paper Height" of group "Paper Size" of me) into tPrintPaperHeight
  set the printPaperSize to tPrintPaperWidth, tPrintPaperHeight
  
  local tPaperOrientation
  if the hilite of button "Reverse" of group "Paper Orientation" then
    put "reverse " into tPaperOrientation
  end if
  if the hilite of button "Portrait" then
    put "portrait" after tPaperOrientation
  else    
    put "landscape" after tPaperOrientation    
  end if
  set the printPaperOrientation to tPaperOrientation
   
  local tLeftMargin, tRightMargin, tTopMargin, tBottomMargin
  put convertStringToPoints(the text of field "Left Margin" of group "Print Margins" of me) into tLeftMargin
  put convertStringToPoints(the text of field "Right Margin" of group "Print Margins" of me) into tRightMargin
  put convertStringToPoints(the text of field "Top Margin" of group "Print Margins" of me) into tTopMargin
  put convertStringToPoints(the text of field "Bottom Margin" of group "Print Margins" of me) into tBottomMargin
  set the printMargins to tLeftMargin, tTopMargin, tRightMargin, tBottomMargin
   
  local tScaleFactor
  put the cValue of button "Scale" of group "Paper Scale" of me into tScaleFactor
  put round(tScaleFactor / 100) into tScaleFactor
   
  if not validScalePercentage(tScaleFactor) then
    error the long id of button "Scale" of group "Paper Scale" of me, "Invalid scale:" & tScaleFactor
  end if
   
  set the printPaperScale to tScaleFactor
   
   
  set the dialogData to empty
  close this stack
end closeAccept

---------------------------------------------------------------------------------------------------------------------------

command closeReject
  set the dialogData to "cancel"
  close this stack
end closeReject

---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------

function convertPointsToMillimetres pNumberOfPoints
  local tInches
  put pNumberOfPoints * kPointsPerInch into tInches
  
  local tCentimetres
  put tInches / kCentimetresPerInch into tCentimetres
  
  return (tCentimetres * 10)
end convertPointsToMillimetres


# If pString contains a minus number then tValue needs to end up with that minus number in it and
# pUnit needs to end up with the correct unit in it.
 
function lengthRegularExpression
  return "^([+-]?[0-9]+\.[0-9]+|[+-]?[0-9]+)\s*(in|cm|mm|pt|\" & quote & "|$)\s*$"
end lengthRegularExpression"

function convertStringToPoints pString
  
  local tValue, tUnit
  
  local tExpression
  put lengthRegularExpression() into tExpression
  
  if not matchText(pString, tExpression, tValue, tUnit) then
    return "Invalid value or unit specified"
  end if
  
    # Use the default unit if none is given
  if tUnit is empty then
    put defaultUnit() into tUnit
  end if
   
  if not unitIsValid(tUnit) then
    return "Invalid unit specified: " & tUnit
  end if
  
  if tValue is empty then
    return "No value specified"
  end if
   
  local tPoints
  put convertValueToPoints(tValue, tUnit) into tPoints
  if tPoints is not a number then
    return tPoints
  end if
   
  return tPoints
end convertStringToPoints

function convertValueToPoints pValue, pUnit
  switch pUnit
  case "mm"
    return ((pValue / 10) / kCentimetresPerInch) * 72 
    break
  case "cm"
    return (pValue / kCentimetresPerInch) * 72
    break
  case "in"
    return pValue * 72
    break
  case "pt"
    return pValue
    break
  case quote
    return pValue * 72
    break
  default
    return "Invalid unit specified : " & pUnit
  end switch
end convertValueToPoints

# Converts a value in points to a value in the unit specified by pUnit
# Returns just the value (i.e. not the unit as well).
function convertValueFromPoints pValue, pUnit
  switch pUnit
  case "pt"
    return pValue
    break
  case "mm"
    return ((pValue / 72) * kCentimetresPerInch * 10)
    break
  case "cm"
    return ((pValue / 72) * kCentimetresPerInch)
    break
  case "in"
    return (pValue / 72)
    break
  case "quote"
    return (pValue / 72)
    break
  default
    return "Invalid unit specified : " & pUnit    
  end switch
  # After implementing this function we need to use it in the preOpenCard handler to display 
  # values in the correct units.
  
  # It also needs to be used in the changePaperSize command to put the values in the paper size
  # fields in the corect units.
  
end convertValueFromPoints


function unitIsValid pUnit
  return (pUnit is among the items of supportedUnits())
end unitIsValid

function supportedUnits
  return "mm,cm,in,pt" & comma & quote
end supportedUnits

function validScalePercentage pValue
  if pValue is not a number or pValue <= 0 then
    return false
  end if
  
  return true
end validScalePercentage

---------------------------------------------------------------------------------------------------------------
command updatePreview
   
  # Check that all relevant values are valid before continuing
  pageCheckForErrors
   
  lock screen
   
  # Clean any existing preview controls
  previewClean
  
  local tPage
  put previewCreatePage() into tPage
  if there is no tPage then
    unlock screen
    exit updatePreview
  end if
  
  local tGroup
  put previewCreateContentsGroup(tPage) into tGroup
   
  # Create a  field containing some sample text 
  # This field should be the actual dimensions of the page and should contain sample text of size 10.
  local tField
  put previewCreateField(tGroup) into tField
  if there is no tField then
    unlock screen
    exit updatePreview
  end if
  
  # Create a grey rectange for the page's shadow. This will be the same size but a few pixels down and right.
  previewCreatePageShadow tPage
  
  # Create a rectangle graphic that will form the field's dotted border. It should have the same rect as the field.
  
  previewCreatePageContentsBorder tField, tGroup
  
  unlock screen
end updatePreview


command updateUnits
  local tExpression
  put lengthRegularExpression() into tExpression
  
  local tValue, tUnit
  repeat for each item tFieldName in "Paper Width,Paper Height,Left Margin,Right Margin,Top Margin,Bottom Margin"
    if not matchText(the text of field tFieldName of me, tExpression, tValue, tUnit) then
      next repeat
    end if
    if tUnit is empty then
      put space & defaultUnit() after field tFieldName of me
    end if
  end repeat
end updateUnits






----------------------------------------------------------------------------------------------------------------



command pageCheckForErrors
   
  # First clear previous errors
  errorClearDo
   
  # Check width and height values
  local tPrintPaperWidth, tPrintPaperHeight
  put convertStringToPoints(the text of field "Paper Width" of group "Paper Size" of me) into tPrintPaperWidth
  put convertStringToPoints(the text of field "Paper Height" of group "Paper Size" of me) into tPrintPaperHeight
  if tPrintPaperWidth is not a number or tPrintPaperWidth <= 0 then
    error the long id of field "Paper Width" of group "Paper Size" of me, tPrintPaperWidth
  end if
  if tPrintPaperHeight is not a number or tPrintPaperHeight <= 0 then
    error the long id of field "Paper Height" of group "Paper Size" of me, tPrintPaperHeight
  end if
  
  # Check margin values
  local tLeftMargin, tRightMargin, tTopMargin, tBottomMargin
  put convertStringToPoints(the text of field "Left Margin" of group "Print Margins" of me) into tLeftMargin
  put convertStringToPoints(the text of field "Right Margin" of group "Print Margins" of me) into tRightMargin
  put convertStringToPoints(the text of field "Top Margin" of group "Print Margins" of me) into tTopMargin
  put convertStringToPoints(the text of field "Bottom Margin" of group "Print Margins" of me) into tBottomMargin
  if tLeftMargin is not a number or tLeftMargin < 0 then
    error the long id of field "Left Margin" of group "Print Margins" of me, tLeftMargin
  end if
  if tRightMargin is not a number or tRightMargin < 0 then
    error the long id of field "Right Margin" of group "Print Margins" of me, tRightMargin
  end if
  if tTopMargin is not a number or tTopMargin < 0 then
    error the long id of field "Top Margin" of group "Print Margins" of me, tTopMargin
  end if
  if tBottomMargin is not a number or tBottomMargin < 0 then
    error the long id of field "Bottom Margin" of group "Print Margins" of me, tBottomMargin
  end if
  
  # Check scale Factor
  local tScaleFactor
  
  # To avoid problems with the button's cValue not updating properly
  send "updateValue" to button "Scale" of group "Paper Scale" of me
  
  put the cValue of button "Scale" of group "Paper Scale" of me into tScaleFactor
  
  if not validScalePercentage(tScaleFactor) then
    error the long id of button "Scale" of group "Paper Scale" of me, "Invalid scale:" & tScaleFactor
  end if
  
  put round(tScaleFactor / 100) into tScaleFactor
  
  # Check that the margins do not overlap
  # Given that the margins are not negative (checked earlier), we know that if the sum of any two opposing margins is 
  # greater than the page width or height then this means the margins are overlapping each other, and no contents will be printed.  
  local tScaledLeftMargin, tScaledRightMargin
  put tScaleFactor * tLeftMargin into tScaledLeftMargin
  put tScaleFactor * tRightMargin into tScaledRightMargin
  
  if tScaledLeftMargin + tScaledRightMargin > tPrintPaperWidth then
    local tControl
    if max(tScaledLeftMargin, tScaledRightMargin) = tScaledLeftMargin then
      put the long id of field "Left Margin" of group "Print Margins" of me into tControl
    else
      put the long id of field "Right Margin" of group "Print Margins" of me into tControl
    end if
    
    error tControl, "The left and right margins are too large or overlapping"
  end if
  
  local tScaledTopMargin, tScaledBottomMargin
  put tScaleFactor * tTopMargin into tScaledTopMargin
  put tScaleFactor * tBottomMargin into tScaledBottomMargin
  
  if tScaledTopMargin + tScaledBottomMargin > tPrintPaperWidth then
    if max(tScaledTopMargin, tScaledBottomMargin) = tScaledTopMargin then
      put the long id of field "Top Margin" of group "Print Margins" of me into tControl
    else
      put the long id of field "Bottom Margin" of group "Print Margins" of me into tControl
    end if
    
    error tControl, "The top and bottom margins are too large or overlapping"
  end if
end pageCheckForErrors


---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------


function previewCreatePage
  # Use the templateGraphic to set the properties that page graphic should have.
  # Set the color of the border to black and the file to white. The style should be set to "rectangle"
  # Set the rect of the graphic to the best fitting rect for the page size. Reset the templateGraphic before
  # making any changes to it. Then reset it again after creating the graphic. We need to take the orientation into
  # account here by swapping the width and height if one of the landscape orientations is in use.
  
  reset the templateGraphic
  set the style of the templateGraphic to "rectangle"
  set the backgroundColor of the templateGraphic to "white"
  set the opaque of the templateGraphic to true
  set the lockLocation of the templateGraphic to true
  
  # Create the graphic
  lock screen
  create graphic "whitePage"
  set the cPreviewControl of graphic "whitePage" to true
  reset the templateGraphic
  
  local tRect
  if the hilitedButtonName of group "Paper Orientation" of me is among the items of "Landscape,Reverse Landscape" then
    put 0 & comma & 0 & comma & convertStringToPoints(the text of field "Paper Height" of group "Paper Size" of me) & comma & convertStringToPoints(the text of field "Paper Width" of group "Paper Size" of me) into tRect
  else
    put 0 & comma & 0 & comma & convertStringToPoints(the text of field "Paper Width" of group "Paper Size" of me) & comma & convertStringToPoints(the text of field "Paper Height" of group "Paper Size" of me) into tRect
  end if
  
  if tRect is "0,0,0,0" then
    delete graphic "whitePage"
    return empty
  end if
  
  put line 1 centreRectInRect(tRect, the rect of group "Preview", 20) into tRect
  
  set the rect of graphic "whitePage" to tRect
  unlock screen
   
  # Return the long id of the graphic we created.
  return the long id of graphic "whitePage"
end previewCreatePage

---------------------------------------------------------------------------------------------------------------------------

function previewCreateContentsGroup pPage
  reset the templateGroup
  set the lockLocation of the templateGroup to true
  set the rect of the templateGroup to the rect of pPage
  create group "Page Contents Container"
  set the cPreviewControl of group "Page Contents Container" to true
  return the long id of group "Page Contents Container"
end previewCreateContentsGroup

---------------------------------------------------------------------------------------------------------------------------

command previewCreatePageShadow pPage
  # pPage is the long id of the graphic that represents the page.
  # Use the templateGraphic to set the properties of the shadow graphic.
  # Grey fill with grey border, style rectangle. Set the rect of the shadow graphic
  # the the rect of pPage, except move the shadow down by 5 pixels or so (eg by adding 5 to each item of the rect).
  
  reset the templateGraphic
  set the style of the templateGraphic to "rectangle"
  set the backgroundColor of the templateGraphic to "gray"
  set the foregroundColor of the templateGraphic to "gray"
  set the opaque of the templateGraphic to true
  set the lockLocation of the templateGraphic to true
  
  local tShadowOffset
  put 5 into tShadowOffset
  
  set the rect of the templateGraphic to (item 1 of the rect of pPage + tShadowOffset), (item 2 of the rect of pPage + tShadowOffset), (item 3 of the rect of pPage + tShadowOffset), (item 4 of the rect of pPage + tShadowOffset)
  create graphic "shadowPage"
  
  set the cPreviewControl of graphic "shadowPage" to true 
  set the layer of graphic "shadowPage" to the layer of pPage - 1
end previewCreatePageShadow

---------------------------------------------------------------------------------------------------------------------------

function previewCreateField pGroup
  # Create an invisible field of the exact paper size. (Here for now assume that pts = pixels). Use the 
  # text of the fields in the paper size group to get the current paper size. Use existing functions to 
  # convert the field text to a number of points. (Maybe use the templateField?). We need to adjust the 
  # width and height of the field to take the orientation into account (swap width and height if landscape).
   
  # If there is already a field with the name "textPage" then delete it first.
  if there is a field "textPage" then
    delete field "textPage"
  end if
   
  # Store the current page width and height in temporary local variables
  local tFieldWidth
  put convertPointsToPixels(convertStringToPoints( the text of field "Paper Width" of group "Paper Size" of me)) into tFieldWidth   
  local tFieldHeight
  put convertPointsToPixels(convertStringToPoints( the text of field "Paper Height" of group "Paper Size" of me)) into tFieldHeight
  
  if tFieldWidth is 0 or tFieldHeight is 0 then
    return empty
  end if
  
  # Use templateField to create copy of actual page using its dimesions
  reset the templateField
   
  local tRectAndScaleFactor
  # Alter size of templateField, if landscape treat width as height etc.
  if the hilitedButtonName of group "Paper Orientation" of me is among the items of "Landscape,Reverse Landscape" then
    put centreRectInRect(((0),(0),(tFieldHeight),(tFieldWidth)), (the rect of group "Preview" of me), 20) into tRectAndScaleFactor
  else
    put centreRectInRect(((0),(0),(tFieldWidth),(tFieldHeight)), (the rect of group "Preview" of me), 20) into tRectAndScaleFactor
  end if
  
  local tRect
  put line 1 of tRectAndScaleFactor into tRect
  
  local tScaleFactor
  put line 2 of tRectAndScaleFactor into tScaleFactor
  
  # Apply the scale factor to the paper margins, putting the resulting values into tLeft, tTop...
  local tLeft, tTop, tRight, tBottom
  put convertPointsToPixels(convertStringToPoints( the text of field "Left Margin" of group "Print Margins" of me)) into tLeft
  put convertPointsToPixels(convertStringToPoints( the text of field "Top Margin" of group "Print Margins" of me)) into tTop
  put convertPointsToPixels(convertStringToPoints( the text of field "Right Margin" of group "Print Margins" of me)) into tRight
  put convertPointsToPixels(convertStringToPoints( the text of field "Bottom Margin" of group "Print Margins" of me)) into tBottom
  
  put round(tLeft * tscaleFactor) into tLeft
  put round(tTop * tscaleFactor) into tTop
  put round(tRight * tscaleFactor) into tRight
  put round(tBottom * tscaleFactor) into tBottom
  
  # Now apply the percentage scale factor to the margin values aswell
  local tPageScaleFactor
  put the label of button "Scale" of group "Paper Scale" of me into tPageScaleFactor
  put tPageScaleFactor / 100 into tPageScaleFactor
  
  put round(tLeft * tPageScaleFactor) into tLeft
  put round(tTop * tPageScaleFactor) into tTop
  put round(tRight * tPageScaleFactor) into tRight
  put round(tBottom * tPageScaleFactor) into tBottom
   
  # Adjust the tRect to take these margins into account. Do this by reducing the area of tRect i.e. add each scaled margin to the 4 sides
  add tLeft to item 1 of tRect
  add tTop to item 2 of tRect
  subtract tRight from item 3 of tRect
  subtract tBottom from item 4 of tRect
  
  set the rect of the templateField to tRect
  
  ## Need to make font size very small can't seem to do it in custom properties
  local tFontSize
  put round((the label of button "Scale" of group "Paper Scale" of me / 100) * 4) into tFontSize
  if tFontSize < 4 then
    put 4 into tFontSize 
  end if
  
  if tFontSize > 20 then
    put 20 into tFontSize
  end if
  
  set the textSize of the templateField to tFontSize
  set the textFont of the templateField to "Arial"
  set the textColor of the templateField to "Gray40"
  
  set the lockText of the templateField to true
  set the traversalOn of the templateField to false
  set the opaque of the templatefield to false
  set the showBorder of the templateField to false
  
  set the script of the templateField to "on rawKeyDown" & return & "end rawKeyDown"
  
  set the margins of the templateField to 2,0,0,0
  
  set the text of the templateField to the cSampleText of me
  
  # Now create the copy of the templateField
  create field "textPage" in pGroup
  reset the templateField
  
  set the cPreviewControl of field "textPage" to true
   
  return the long id of field "textPage"
end previewCreateField

---------------------------------------------------------------------------------------------------------------------------

command previewCreatePageContentsBorder pPageContents, pGroup
  # pPageContents is the long id of the field containing the page contents. 
  # (Maybe using the templateGraphic again?) Create a graphic, set its style to "rectangle"
  # No fill (default), light grey border.
   reset the templateGraphic
   set style of templateGraphic to "rectangle"
   set the rect of the templateGraphic to the rect of pPageContents
   set the opaque of the templateGraphic to false
   set the foregroundcolor of the templateGraphic to "gray50"
   set the dashes of the templateGraphic to 3,3
   set the antiAliased of the templateGraphic to false
   create graphic "Page Border" in pGroup
   reset the templateGraphic

   set the cPreviewControl of graphic "Page Border" to true
end previewCreatePageContentsBorder

---------------------------------------------------------------------------------------------------------------------------

command previewClean
  lock screen
  repeat with x = the number of controls of me down to 1
    if the cPreviewControl of control x of me is true then
      delete control x of me
    end if
  end repeat
  unlock screen
end previewClean

---------------------------------------------------------------------------------------------------------------------------

# Scales pRectToScale so that it fits entirely pBoundingRect, whilst keeping the aspect ratio 
# of pRectToScale the same. The rect to scale will be scaled such that it is
# the largest possible size that will fit in pBoundingRect as either landscape or portrait.
function centreRectInRect pRectToScale, pBoundingRect, pMargin
  # Find the ratio between the biggest dimension of pRectToScale with the smallest dimension of pBoundingRect
  # Then scale pRectToScale down by that ratio.
  local tScaleRectWidth, tScaleRectHeight
  put item 3 of pRectToScale - item 1 of pRectToScale into tScaleRectWidth
  put item 4 of pRectToScale - item 2 of pRectToScale into tScaleRectHeight
  
  local tAdjustedBoundingRect
  put (item 1 of pBoundingRect + pMargin) & comma & (item 2 of pBoundingRect + pMargin) & comma & (item 3 of pBoundingRect - pMargin) & comma & (item 4 of pBoundingRect - pMargin) into tAdjustedBoundingRect
  
  local tBoundingRectWidth, tBoundingRectHeight
  put item 3 of tAdjustedBoundingRect - item 1 of tAdjustedBoundingRect into tBoundingRectWidth
  put item 4 of tAdjustedBoundingRect - item 2 of tAdjustedBoundingRect into tBoundingRectHeight
  
  local tRatio
  put min(tBoundingRectWidth, tBoundingRectHeight) / max(tScaleRectWidth, tScaleRectHeight) into tRatio
  
  # Scale pRectToScale by multiplying the right and bottom by the ratio
  local tNewScaleRect
  put item 1 of pRectToScale & comma & item 2 of pRectToScale & comma & round(tRatio * item 3 of pRectToScale) & comma & round(tRatio * item 4 of pRectToScale) into tNewScaleRect
  
  local tNewScaleRectWidth, tNewScaleRectHeight
  put item 3 of tNewScaleRect - item 1 of tNewScaleRect into tNewScaleRectWidth
  put item 4 of tNewScaleRect - item 2 of tNewScaleRect into tNewScaleRectHeight
  
  # Position pRectToScale in the centre of pBoundingRect  
  local tLeft
  put item 1 of tAdjustedBoundingRect + round(0.5 * tBoundingRectWidth) - round(0.5 * tNewScaleRectWidth) into tLeft
  
  local tTop
  put item 2 of tAdjustedBoundingRect + round(0.5 * tBoundingRectHeight) - round(0.5 * tNewScaleRectHeight) into tTop
  
  local tCentredScaleRect
  put tLeft & comma & tTop & comma & (tLeft + tNewScaleRectWidth) & comma & (tTop + tNewScaleRectHeight) into tCentredScaleRect
  
  # Return the rect to scale and the scale factor that we used.
  return tCentredScaleRect & return & tRatio
end centreRectInRect

---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------


function convertPointsToPixels pValueInPoints
  # For now we just assume that points = pixels
  return pValueInPoints
end convertPointsToPixels

function defaultUnit
  return "in"
end defaultUnit

on mouseUp
  updateUnits
  updatePreview
  errorClear the long id of the target
end mouseUp

on openField
  errorClear the long id of the target
end openField

on closeField
  updateUnits
  updatePreview
end closeField

on menuPick
  updateUnits
  updatePreview
end menuPick

constant kLetters = "abcdefghijklmnopqrstuvwxyz"

on keyDown pKey
  if pKey is not a number and pKey is not among the chars of kLetters and pKey is not "." and pKey is not quote and pKey is not space then
    -- block keyDown
  else
    pass keyDown
  end if
end keyDown



local sErrorControl

---------------------------------------------------------------------------------------------------------------------------

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

-- Block these two messages so that none of the fields in this card can have more than one line of text.
on returnInField
end returnInField

on enterInField
end enterInField

---------------------------------------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------------------------------------

command errorClearDo
  put empty into field "Error"
  if there is a graphic "Error Border" of me then
    delete graphic "Error Border" of me
  end if
  
  put empty into sErrorControl
end errorClearDo

---------------------------------------------------------------------------------------------------------------------------















