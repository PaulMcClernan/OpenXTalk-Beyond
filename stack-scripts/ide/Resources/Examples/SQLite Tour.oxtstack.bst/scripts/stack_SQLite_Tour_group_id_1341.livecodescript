script "stack_SQLite_Tour_group_id_1341"
-- Stack file: ide/Resources/Examples/SQLite Tour.oxtstack
-- Object: stack "SQLite Tour" > (on no card) > group "altFldHeader" (id 1341)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

 
# ------------------------------------------------------------------------------------------------------------
# Control: altFldHeader
# by Chipp Walters, Altuit, inc.
# ------------------------------------------------------------------------------------------------------------

local l_altMoveNow,l_altMoveCol,l_altTracMode

on mouseDown
  if the owner of the target is not me then pass mouseDown
  if there is an image "moveColumn" and the cursor is (the id of img "moveColumn") then
    lock cursor 
    put "" into l_altMoveNow
    put the priv_altOrderNum of the target into x
    
    if mouseH() < item 1 of the loc of the target then #other button on left
      
      put line x-1 of the priv_altBtnIDList of me into line 1 of temp
      put line x of the priv_altBtnIDList of me into line 2 of temp
      
    else #other button on right
       
      put line x of the priv_altBtnIDList of me into line 1 of temp
      put line x + 1 of the priv_altBtnIDList of me into line 2 of temp
       
    end if
    

    put temp into l_altMoveNow
    put true into l_altMoveCol
    
  else
     
    if the target contains "button" then
      if the altEnableBtn of the target then set the hilite of the target to true
    end if
    
  end if
  pass mouseDown
end mouseDown

on mouseUp
  if the owner of the target is not me then pass mouseUp
  put false into l_altMoveCol
  put false into l_altTracMode
  unlock cursor 
  if the target contains "button" then
    hilite the target
    unhilite the target
  end if
  if the environment is "development" then
    if the shiftKey is down then
      checkForCursor
      buildColumnButtons
      InitAltFldHeader
    end if
    if the optionKey is down then
      checkForTargetField
      put the altDontResize of the target into tCanResize
      answer question "Lock the resize of this btn" with "Yes" or "No"
      if it is "Yes" then 
        set the altDontResize of the target to true
      else
        set the altDontResize of the target to false
      end if
      answer question "Enable this button for hiliting on mouseClick?" with "Yes" or "No"
      if it is "Yes" then
        set the altEnableBtn of the target to true
      else
        set the altEnableBtn of the target to false
      end if
      answer question "Set Minimum Width for this button?" with "This Width" or "Very Small Width" or "No Change"
      if it is "This Width" then set the altMinWidth of the target to the width of the target
      if it is "Very Small Width" then set the altMinWidth of the target to 10
      ask "New Name for this column button" with the short name of the target
      if it is not empty then set the name of the target to it
      InitAltFldHeader
    end if
    if the ctrlKey is down then
      checkForTargetField
      put the tabStops of fld the altTargetField of me into tTabStops
      put the number of items of tTabStops into tNumCols
      ask "Change the number of columns:" with tNumCols
      if it is "" then exit to top
      put it into tNewNumCols
      if tNewNumCols < tNumCols and tNewNumCols > 1 then
        repeat with x =1 to tNewNumCols
          put item x of tTabStops &"," after tNewTabStops
        end repeat
        delete last char of tNewTabStops
        set the tabStops of fld the altTargetField of me to tNewTabStops
        buildColumnButtons
        InitAltFldHeader
      end if
      
      if tNewNumCols > tNumCols then
        repeat until tNewNumCols = tNumCols
          put "," & the last item of tTabStops + 40 after tTabStops
          add 1 to tNumCols
        end repeat
        set the tabStops of fld the altTargetField of me to tTabStops
        buildColumnButtons
        InitAltFldHeader
      end if
    end if
  end if
  altFinishTracking
  pass mouseUp
end mouseUp

on mouseEnter x,y
  if the owner of the target is not me then pass mouseEnter
  if the target contains "button" and there is a fld the altTargetField of me then
    lock cursor
    put true into l_altTracMode
  else
    put false into l_altTracMode
  end if
  pass mouseEnter
end mouseEnter

on mouseLeave
  if the owner of the target is not me then pass mouseLeave
  unlock cursor
  put false into l_altTracMode
  pass mouseLeave
end mouseLeave

on mouseRelease
  unlock cursor
  put false into l_altMoveCol
  put false into l_altTracMode
  if the target contains "button" then set the hilite of the target to false
  altFinishTracking
  pass mouseRelease
end mouseRelease


on mouseMove x,y
  if the owner of the target is not me then pass mouseMove
  if l_altTracMode then
    
    if the target contains "button" and the altDontResize of the target is False then
      
      switch 
      case x < (the left of the target + 5) and the priv_altOrderNum of the target > 1 #other button on left
        
        # gets the btn id of the 'adjacent' button
        put (item 1 of line (max((the priv_altOrderNum of the target - 1),1)) of the priv_altBtnIDList of me) into tBtnID
        if the altDontResize of btn ID tBtnID  then 
          set the cursor to arrow
        else
          set the cursor to (the id of img "moveColumn")
        end if
        break
        
      case x > (the right of the target - 5) and the priv_altOrderNum of the target < the number of lines in the priv_altBtnIDList of me #other button on right
        
        # gets the btn id of the 'adjacent' button
        put (item 1 of line (min((the priv_altOrderNum of the target + 1),the number of lines in the priv_altBtnIDList of me)) of the priv_altBtnIDList of me) into tBtnID
        if the altDontResize of btn ID tBtnID  then 
          set cursor to arrow
        else
          set the cursor to (the id of img "moveColumn")
        end if
        break
        
      default
        set cursor to arrow
      end switch
      
    else
      set the cursor to arrow
      
    end if
  end if
  
  if  l_altMoveCol then
    put l_altMoveNow into tList
    set the width of btn id item 1 of tList to \
        min(max(x - the left of btn id item 1 of tList,item 3 of tList),(the right of btn id item 1 of line 2 of tList - the left of btn id item 1 of tList - item 3 of line 2 of tList))
    put the right of btn id item 1 of line 2 of tList into tRight
    get the rect of btn id item 1 of line 2 of tList
    set the rect of btn id item 1 of line 2 of tList to \
        the right of btn id item 1 of tList, \
        item 2 of it, \
        item 3 of it, \
        item 4 of it
    if the altRealTimeTrack of me then altFinishTracking
  end if
  pass mouseMove
end mouseMove


on buildColumnButtons
  
  --> CHECK FOR A TARGET FIELD
  if there is not a fld the altTargetField of me then
    ask "Please enter the name of the field you wish to associate me with:"
    if it is "" then exit to top
    if there is not a fld it then 
      beep
      answer "No field on this card by that name!"
      exit to top
    else
      set the altTargetField of me to it
    end if
  end if
  
  ask "Please enter the vertical space between the columnHeader and the field (in Pixels)"&cr&"Default is 0" with the altVertPad of me
  if not isNumber(it) then exit to top
  set the altVertPad of me to it
  
  answer question "Enable realtime column tracking? (default is Yes)" with "No" or "Yes"
  if it is "No" then
    set the altRealTimeTrack of me to false
  else
    set the altRealTimeTrack of me to true
  end if
  
  put the altTargetField of me into tFld
  put the tabStops of fld tFld into tTabs
  
  --> CHECK TARGET FIELD FOR TABSTOPS
  if the number of items in tTabs < 2 then
    answer question "There needs to be at least 2 columns in this field. Should I automatically add them?" with "No" or "Yes"
    if it is "No" then exit to top
    put "30,30" into tTabs
    set the tabStops of fld tFld to tTabs
  end if
  set the vGrid of fld tFld to true
  
  put the number of items in tTabs into tNumCols
  
  --> CHECK TO SEE IF WE SHOULD USE ALL COLUMNS
  set the priv_XtraTabs of me to ""
  if tNumCols > 3 then
    answer question "Do you wish to display all " &tNumCols& " columns?" with "No" or "Yes"
    if it is "No" then
      ask "How many of the " &tNumCols& " do you wish to display?" with tNumCols
      if it is not empty and isNumber(it) then
        if it > tNumCols then
          answer "Too many columns!"
          exit to top
        end if
        if it < 3 then
          answer "Too few columns"
          exit to top
        end if
        if it < tNumCols then
          put it into tCount
          repeat with y = tCount+1 to tNumCols
            put item y of tTabs - item (y-1) of tTabs & "," after tEndTabs
          end repeat
          delete last char of tEndTabs
          set the priv_XtraTabs of me to tEndTabs
          put tCount into tNumCols
        end if
      end if
    end if
  end if
  
  set the altNumCols of me to tNumCols
   
  --> CHECK FOR NUMBER OF BTNS IN ME
  put 0 into tNumMyBtns
   
  repeat with x = the number of btns on this cd down to 1
    put the id of me into tID
    if the long ID of btn x contains ("group ID " & tID) then
      add 1 to tNumMyBtns
      if tNumMyBtns > tNumCols then 
        delete btn x
      else
        put x into tGoodBtnToClone
      end if
    end if
  end repeat
   
  --> IF THE NUMBER OF BTNS IN ME IS LESS THAN THE COLUMNS IN THE FIELD
  if tNumMyBtns < tNumCols then
    repeat until tNumMyBtns = tNumCols
      clone btn tGoodBtnToClone
      add 1 to tNumMyBtns
    end repeat
  end if
end buildColumnButtons

on checkForTargetField
  if there is not a field the altTargetField of me then
    answer warning "Please first target a field for this control. Shift-Click on this control to do so."
    exit to top
  end if
end checkForTargetField






on checkForCursor
  if there is not an img "moveColumn" then
    answer warning "Please add the img 'moveColumn' to this card!"
    exit to top
  end if
end checkForCursor

on resizeStack pNewWidth
  
  put pNewWidth into tRight
  put the left of me into tL
  
  put the priv_altBtnIDList of me into tBtnIDs
  
  set the width of me to max(the priv_altMinWidth of me,tRight-the priv_altRight of me-tL)
  
  put the width of me into tWidth 
  
  --> priv_altBtnIDList FOR THIS GROUP
  --> ITEM 1 IS THE BTN ID
  --> ITEM 2 IS THE % WIDTH OF GROUP (.10 = 10%)
  --> ITEM 3 IS THE MINWIDTH
  
  repeat for each line L in tBtnIDs
    set the left of btn id (item 1 of L) to tL
    if the altDontResize of btn id (item 1 of L) is False then
      set the width of btn id (item 1 of L) to max(round(tWidth * item 2 of L),the altMinWidth of btn id (item 1 of L))
    end if
    put the right of btn id (item 1 of L) into tL
  end repeat
  set the width of btn id item 1 of last line of the priv_altBtnIDList of me to \
      the right of me \
      - the left of btn id item 1 of last line of the priv_altBtnIDList of me 
   
  put 0 into tW
  set the lockLoc of fld the altTargetField of me to true
  if the vscrollbar of fld the altTargetField of me then
    put the scrollbarwidth of fld the altTargetField of me into tW
  end if
  set the width of fld the altTargetField of me to \
      the width of me + tW
  
  altFinishTracking
  pass resizeStack
  
end resizeStack

on altFinishTracking
  
  if there is not a fld the altTargetField of me then exit to top
  
  --> SET THE TABS FOR THE ASSOCIATED FIELD

  --> WE HAVE HIDDEN COLUMNS, SO LET'S CAPTURE
  put the priv_altBtnIDList of me into t
  put the left of btn id item 1 of the priv_altBtnIDList of me +3 into tLeft
  repeat for each line L in the priv_altBtnIDList of me
    put the right of btn id item 1 of L - tLeft & "," after tTabs
  end repeat
  delete last char of tTabs
  --> ADD ANY HIDDEN TABS
  put the priv_XtraTabs of me into tXtabs
  repeat for each item I in tXtabs
    put "," & the last item of tTabs + I after tTabs
  end repeat 
  
  set the tabStops of fld the altTargetField of me to tTabs
  
  #set the new button percentages
  put the priv_altBtnIDList of me into tList
  
  put the width of me into tWidth
  
  put 0 into tLength
  
  repeat with x = 1 to the number of lines in tList
    put round(100*the width of btn id item 1 of line x of tList/tWidth)/100 into \
        item 2 of line x of tList
    if x is not the number of lines in tList then
      put item 2 of line x of tList + tLength into tLength
    else
      put 1 - tLength into item 2 of line x of tList
    end if
    
  end repeat  
  set the priv_altBtnIDList of me to tList 
end altFinishTracking

on InitAltFldHeader
  # should call this when 'setting up' the original group for the first time
  # not necessary to call this ever again
  # builds a sorted left to right list of all the IDs of the buttons in this group and sets the priv_altBtnIDList property to it 
  
  if not exists(fld the altTargetField of me) then
    answer warning "No designated fld found. Please set the altTargetField property!"
    exit InitAltFldHeader
  end if
  
  set the lockLoc of me to true
   
  --> GET THE TAB WIDTHS
  put the tabStops of fld the altTargetField of me into tTabStops
  put the altNumCols of me into tNumCols
  put the left of fld the altTargetField of me into tL
  set the left of me to tL
  
  --> CALCULATE IF THERE IS ROOM FOR ALL OF THE TABSTOPS IN THIS FIELD
  put item tNumCols of tTabStops into tFldWidth
  put the width of fld the altTargetField of me into tWidth
  if the vscrollbar of fld the altTargetField of me then
    subtract the scrollbarwidth of fld the altTargetField of me from tWidth
  end if
  
  if tFldWidth > tWidth then
    
    --> THE FIELD IS NOT WIDE ENOUGH TO HANDLE ALL THE BUTTONS
    --> NEED TO RESET THE TABSTOPS
    repeat with x =1 to the number of items in tTabStops
      put item x of tTabStops into tempW
      put round(tempW/tFldWidth * tWidth) into tempW
      put tempW & "," after tNewTabStops
    end repeat
    delete last char of tNewTabStops
    put tNewTabStops into tTabStops
    
  end if
  
  --> SET THE BUTTON WIDTHS
  put 1 into tColCounter
  put 0 into tOldWidth
  put 0 into tMaxHeight
  put 0 into tBtnCounter
   
  
  put 1 into tOrder
  
  repeat with x = 1 to the number of btns on this cd
    put the id of me into tID
    if the long ID of btn x contains ("group ID " & tID) then
      put item tColCounter of tTabStops - tOldWidth into tColumnWidth
      
      if tBtnCounter = 0 then 
        put 3 into tIncrement
      else
        put 0 into tIncrement
      end if
      
      if tBtnCounter + 1 = tNumCols then
        --> ON LAST BTN
        put tWidth - tOldWidth into tColumnWidth
        put item tColCounter of tTabStops - tOldWidth into tLastColWidth
        put -3 into tIncrement
      end if
       
      set the width of btn x to tColumnWidth + tIncrement
      if tBtnCounter = 0 then
        if there is an image "moveColumn" of me then
          set the loc of image "moveColumn" to the loc of btn x
          hide image "moveColumn"
        end if
      end if
      set the lockloc of btn x to true
      set the priv_altOrderNum of btn x to tOrder
      add 1 to tOrder
      set the left of btn x to tL
      put the right of btn x into tL
      put max(the height of btn x, tMaxHeight) into tMaxHeight
      add 1 to tBtnCounter
      put item tColCounter of tTabStops into tOldWidth
      add 1 to tColCounter
    end if
  end repeat
   
  --> SET THE BUTTON HEIGHTS
  repeat with x = 1 to the number of btns on this cd
    put the id of me into tID
    if the long ID of btn x contains ("group ID " & tID) then
      set the height of btn x to tMaxHeight
      set the top of btn x to the top of me
    end if
  end repeat
   
  --> CALCULATE RELATIVE COLUMN WIDTHS
  --> priv_altBtnIDList FOR THIS GROUP
  --> ITEM 1 IS THE BTN ID
  --> ITEM 2 IS THE % WIDTH OF GROUP (.10 = 10%)
  --> ITEM 3 IS THE MINWIDTH
  
  put 0 into tMinWidth
  
  repeat with x = 1 to the number of btns on this cd
    put the id of me into tID
    if the long ID of btn x contains ("group ID " & tID) then
      put the id of btn x & "," after tBtnIdList
      
      --> CALCULATE % WIDTH
      put round(100*the width of btn x/tWidth)/100 into tPercentWidth
      put tPercentWidth & "," after tBtnIdList
      put the altMinWidth of btn x & "," & cr after tBtnIdList
      add the altMinWidth of btn x to tMinWidth
    end if
  end repeat
  
  delete last char of tBtnIdList
  set the priv_altBtnIDList of me to tBtnIdList
  
  
  
  --> STORE THE MINIMUM WIDTH
  set the priv_altMinWidth of me to tMinWidth
  
  set the height of me to the formattedHeight of me
  set the top of me to the top of fld the altTargetField of me - tMaxHeight - the altVertPad of me
  set the width of me to the formattedWidth of me
  set the left of me to the left of fld the altTargetField of me
  set the priv_altRight of me to the width of this cd - the right of me
  
  altFinishTracking
   
end InitAltFldHeader
