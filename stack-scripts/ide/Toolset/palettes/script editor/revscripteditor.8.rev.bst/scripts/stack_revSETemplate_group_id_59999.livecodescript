script "stack_revSETemplate_group_id_59999"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSETemplate" > card "Main" (id 1002) > group "Panes" (id 1050) > group "Errors" (id 1069) > group "List" (id 59999)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

###############################################################################################
# List Control
#
# How to use:
# 1. Copy this group to your card.
# 2. Create a template control to use as the list items. This is any control that handles the itemInit message
#     Set the cItemTemplate of this group to the long id of the template control to use.
# 3. Set the cData and cPrefs (optional) of the group to appropriate values (*)
# 4. Send the "update" message to the group
#

# * The cData is a return delimited list. Each line represents one item in the list, and the line
#   is sent as the parameter to itemInit to the template control, so basically you can put whatever
#   you want in it.
#   The cPrefs is a return delimited list of tag=value pairs. Please see the comment for setProp cPrefs for a few examples.
###############################################################################################

# Stores the data for the nodes, an array with numeric keys that
# determine the order nodes appear in. The value of the array items
# is a string that is passed to the each item as parameters to the itemInit
# handler to allow each item to initialisze itself
local sData

# An array of preferences. Each preference has a tag which is the key.
# Examples are sPrefs["marginLeft"], sPrefs["marginTop", sPrefs["justification"] and sPrefs["spacing"]
local sPrefs

# An array whose keys are the same as those of sData, that stores the ids of each item
local sItems

# Format
#   A returned delimited list. Each line represents a list item to display,
#   and the contents of the line is passed to each item so that it can initialize itself
#   appropriately
setProp cData pData
  split pData with return
  put pData into sData
end cData

getProp cData
  local tData
  put sData into tData
  combine tData with return
  return tData
end cData

# Format
#   A return delimited list of tag=value
setProp cPrefs pPrefs
  split pPrefs with return and "="
  put pPrefs into sPrefs
end cPrefs

getProp cPrefs
  local tPrefs
  put sPrefs into tPrefs
  combine tPrefs with return and "="
  return tPrefs
end cPrefs
 
# The main update function, call this to initialise and refresh the list.
on update
   local tItemInfo, tNewItem, tTop, tLeft
   local tScroll
   put the vScroll of me into tScroll
   
   lock screen
   
   set the vScrollbar of me to false
   set the vScroll of me to 0
   
   itemPurgeAll
   
   put the top of me + sPrefs["marginTop"] into tTop
   
   put leftCalculate() into tLeft
   
   # Repeat for each key is faster but we need to preserve the 
   # correct ordering of the items.
   local tKeys
   put the keys of sData into tKeys
   sort tKeys numeric
   
   repeat for each line tKey in tKeys
      put sData[tKey] into tItemInfo
      put itemCreate(tItemInfo, tLeft, tTop) into tNewItem
      add the height of tNewItem to tTop
      add sPrefs["spacing"] to tTop
   end repeat
   
   set the vScroll of me to tScroll
   updateScrollbar
   unlock screen
end update

# Because of bug 4210, this group won't work correctly if it has a scrollbar. Until this 
# bug is fixed we have to make the vScrollbar false and have an external one
on updateScrollbar
  --set the vScrollbar of me to (the formattedHeight of me > the height of me)
  set the vScrollbar of me to false
end updateScrollbar

# Creates a new item from the template item, setting its info
# to pInfo and its topLeft to pLeft, pTop
function itemCreate pInfo, pLeft, pTop
   local tTemplate, tItem
   put the long id of (the cItemTemplate of me) into tTemplate
   
   # Its essential to lock messages here. The reason is that this function is called when the mouse is moved
   # (when dragging the panes resizer). When the control is created by the copy command, if the mouse is within
   # the rect of the new control, the engine immediately sends another mouseMove message. This causes the 
   # updateDo to be called again and itemPurge to be called, which then attempts to delete the control when its
   # script is executing. The result of this is an infinite loop (because of traceError).
   lock messages
   copy tTemplate to me
   put the long id of it into tItem
   unlock messages
   
   set the name of tItem to empty
   if the vScrollbar of me then
      set the width of tItem to the width of me - the scrollbarWidth of me
   else
      set the width of tItem to the width of me
   end if
   set the topLeft of tItem to (pLeft, pTop)
   set the cListItem of tItem to true
   
   send "itemInit pInfo" to tItem
   
   return tItem
end itemCreate

# Removes all the items from the list
on itemPurgeAll
  repeat with x = the number of controls of me down to 1
    if the cListItem of control x of me then delete control x of me
  end repeat
end itemPurgeAll

# Returns the left of the items, depending on preferences.
function leftCalculate
  local tJustification, tRight, tTemplate, tLeft
  
  put sPrefs["justification"] into tJustification
  put the long id of (the cItemTemplate of me) into tTemplate
  
  if tJustification is empty then put "centre" into tJustification
  
  if tJustification is "left" then
    put the left of me + sPrefs["marginLeft"] into tLeft
  end if
  
  if tJustification is "right" then
    put the right of me - sPrefs["rightMargin"] into tRight
    put tRight - the width of tTemplate into tLeft
  end if
  
  if tJustification is "centre" then
    put round((the width of me - the width of tTemplate) / 2) into tLeft
    add the left of me to tLeft
  end if
  
  -- ensure that the left margin is preserved. If the items are too big then at least
  -- the behavior is predictable, ie the items will always be clipped at their right edge.
  if tLeft < the left of me + sPrefs["marginLeft"] then put the left of me + sPrefs["marginLeft"] into tLeft
  
  return tLeft
end leftCalculate
