script "stack_revIDEProjectBrowser_button_id_930549"
-- Stack file: ide/Toolset/palettes/project browser/revideprojectbrowser.livecode
-- Object: stack "revIDEProjectBrowser" > card "templates" (id 5773) > button "pbDragIndicatorBehavior" (id 930549)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on resizeControl
   if the target is not me then pass resizeControl
   
   ResizeMe
end resizeControl

command PositionDropIndicator pBeingDroppedAfterRow
   ResizeMe pBeingDroppedAfterRow
end PositionDropIndicator

constant kIndicatorThickness = 2
on ResizeMe pBeingDroppedAfterRow
   local theViewRect, theRect, tRowRect, tMid
   local tExpanded, tAbsoluteRow, tRowType
   
   put the rect of me into theViewRect
   
   # resizeControl won't pass the param in
   if pBeingDroppedAfterRow is not empty then
      put the rect of the dvControlOfRow[pBeingDroppedAfterRow] of the dvControl of me into tRowRect
      put getAbsoluteRow(pBeingDroppedAfterRow) into tAbsoluteRow
      put getRowType(tAbsoluteRow) into tRowType
      put getRowExpanded(tAbsoluteRow) into tExpanded
      
      if tRowType is "group" and (tExpanded is not true) then
         // Could be on the group
         if (the mouseV > item 2 of tRowRect+8) and (the mouseV  <  item 4 of tRowRect-8) then
            put true into tMid
         end if
      end if
   else
      
   end if
   
   local tYLoc
   if tMid then
      put item 2 of tRowRect + 10 into tYLoc
   else
      put item 2 of the loc of graphic 1 of me into tYLoc
   end if
   
   put the rect of graphic 1 of me into theRect
   put item 1 of theViewRect into item 1 of theRect
   put (tYLoc - kIndicatorThickness / 2) into item 2 of theRect
   put item 3 of theViewRect + 1 into item 3 of theRect
   put (tYLoc + kIndicatorThickness / 2) into item 4 of theRect
   set the rect of graphic 1 of me to theRect
end ResizeMe
