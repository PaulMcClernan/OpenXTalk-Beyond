script "stack_revIDEProjectBrowser_group_id_5765"
-- Stack file: ide/Toolset/palettes/project browser/revideprojectbrowser.livecode
-- Object: stack "revIDEProjectBrowser" > card "list" (id 1002) > group "content" (id 155594) > group "objectList" (id 5765)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on dragStart
   local theTargetRows, tType, tStyle, tAbsRow
   # me is the DataView group
   put the dvHilitedRows of me into theTargetRows
   
   put getAbsoluteRow(item 1 of theTargetRows) into tAbsRow
   
   put getRowStyle(tAbsRow) into tStyle
   put getRowType(tAbsRow) into tType

   if tStyle is not among the items of "control,group,container" then exit dragStart
   
   # Sets the image shown while dragging.
   set the dvDragImageRow of me to item 1 of theTargetRows
   
   # This will start tracking a drag reorder operation in the data grid.
   # There is a default group that has a group that will show the user where the drop will occur.
   # You can override the default graphic by setting the the viewProp["drop indicator template"] of the DataView to
   # the long id of a group. The group should handle the resizeControl message to control appearance. 
   # The group can handle the "PositionDropIndicator" message.  Param 1 is the row that the
   # drop will happen after. You only need to handle this message if you want to control appearance based on drop position.
   set the dvTrackDragReorder[theTargetRows] of me to true
   
   # LiveCode engine needs to be dragging some data  
   set the dragData["private"] to theTargetRows & return & tStyle & return & tType
end dragStart

# pTargetRows are the rows that were being dragged.
# pNewStartRow is the new starting row for pTargetRows (assuming your have a flat list of rows and not a tree).
# pDroppedAfterRow is the row that the dropp happened after. This is a number between 0 and the number of rows in the DataView.
command DragReorderRows pTargetRows, pNewStartingRow, pDroppedAfterRow
   reorderRows pTargetRows,pNewStartingRow,pDroppedAfterRow
end DragReorderRows
