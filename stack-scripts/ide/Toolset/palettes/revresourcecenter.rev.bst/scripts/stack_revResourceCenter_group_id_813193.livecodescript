script "stack_revResourceCenter_group_id_813193"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Textmenu:populatingwithcontent" (id 82654) > group (id 2127) > group "Tree" (id 1034) > group "eoton1tnb6y5yhu0hwy89n12s3snc4ep" (id 813193)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sExpanded
local sLeaf
local sFinal
local sInitial
local sHilite

getProp cExpanded
  return sExpanded
end cExpanded

constant kIconExpand = 205209
constant kIconContract = 205210

setProp cExpanded pValue
  if pValue is not among the items of "true,false" then
    error "Invalid expansion value, expected Boolean, got: " & pValue
  end if
  
  if the cLeaf of me then
    # Can't expand a leaf
    put pValue into sExpanded
    exit cExpanded
  end if
  
  if pValue then
    set the icon of button "Expander" of me to kIconContract
 else
    set the icon of button "Expander" of me to kIconExpand
  end if
  
  put pValue into sExpanded
end cExpanded

setProp cLeaf pValue
   if pValue is not among the items of "true,false" then
      error "Invalid leaf value, expected Boolean, got: " & pValue
   end if
   
   if pValue then
      set the icon of button "Expander" of me to 0
   else
      if the cExpanded of me then
          set the icon of button "Expander" of me to kIconContract
      else
          set the icon of button "Expander" of me to kIconExpand
      end if
   end if
   
   put pValue into sLeaf
end cLeaf

getProp cLeaf
  return sLeaf
end cLeaf

setProp cIcon pIcon
   if pIcon is not a number then
      error "Invalid icon value, expected a valid image id, got: " & pIcon
   end if
   
   if pIcon is not "0" then
      set the leftmargin of field 1 of me to (the width of button "icon" + 4)
   end if
   set the icon of button "Icon" of me to pIcon
end cIcon

getProp cIcon
  return the icon of button "Icon" of me
end cIcon

local sLabel

setProp cLabel pLabel
   put pLabel into sLabel
   set the cOriginalLabel of me to pLabel
   adjustLabel
end cLabel

getProp cLabel
  return sLabel
end cLabel

setProp cFinal pValue
  if pValue is not among the items of "true,false" then
    error "Invalid final value, expected Boolean, got: " & pValue
  end if
  
  --set the visible of graphic "Branch Line" of me to (not pValue)
  put pValue into sFinal
end cFinal

getProp cFinal
  return sFinal
end cFinal

setProp cInitial pValue
  if pValue is not among the items of "true,false" then
    error "Invalid initial value, expected Boolean, got: " & pValue
  end if
  
  --set the visible of graphic "Vertical Line" of me to (not pValue)
  put pValue into sInitial
end cInitial

getProp cInitial
  return sInitial
end cInitial

setProp cHilite pValue
   if pValue is not among the items of "true,false" then
      error "Invalid hilite value, expected Boolean, got: " & pValue
   end if
   
   if pValue then
      --set the opaque of field "Label" of me to true
      --set the backgroundColor of field "Label" of me to "150,150,255"
      --set the foregroundColor of field "Label" of me to "255,255,255"
   else
      set the opaque of field "Label" of me to false
      --set the backgroundColor of field "Label" of me to the backgroundColor of me
      --set the foregroundColor of field "Label" of me to the foregroundColor of me
   end if
   
   put pValue into sHilite
end cHilite

getProp cHilite
  return sHilite
end cHilite

getProp cAxis
   return 0
end cAxis


on mouseUp
   local tLabel
   put the cLabel of me into tLabel
   set the toolTip of me to tLabel
   replace space with "" in tLabel
   
   if the cInfo of me is empty and there is a card tLabel of this stack then
      lock cursor
      set the cursor to watch
      go to card tLabel
      unlock cursor
   end if
   pass mouseUp
end mouseUp


private command adjustLabel
   local tLeft
   put the left of field "Label" of me into tLeft
   set the width of field "Label" of me to (the right of me - the left of field "Label" of me)
   set the left of field "Label" of me to tLeft
   
   set the text of field "Label" of me to the cOriginalLabel of me
   
   
   # OK-2008-09-03 : Bug 7087 - As the resource centre now has an adjustable navigation bar width, 
   # the labels of the navigation items no longer need to be adjusted and truncated as the user can simply 
   # expand the bar to see more.
   exit adjustLabel
   
   
   local tAvailableWidth
   
   if the vScrollbar of me is "true" then
      put ((the width of field "Label") - the scrollbarWidth of group "Tree") into tAvailableWidth
   else
      put the width of field "Label" into tAvailableWidth
   end if
   
   if (the formattedWidth of field "Label" of me) + (the width of button "icon" of me) <= tAvailableWidth then
      --if the formattedWidth of field "Label" of me <= the width of field "Label" of me then   
      exit adjustLabel
   end if
   
   # We are going going to truncate the label to make it fit, initially we remove either the last word
   # or the last three chars to make room for the "..."
   local tLabel
   put the cOriginalLabel of me into tLabel
   
   if the number of words of tLabel > 1 then
      delete word -1 of tLabel
   else
      delete char -3 to -1 of tLabel
   end if
   
   set the text of field "Label" of me to tLabel & "..."
   
   repeat until (the formattedWidth of field "Label" of me <= the width of field "Label" of me) or (tLabel is empty)
      if the number of words of tLabel > 1 then
         delete word -1 of tLabel
      else
         delete char -1 of tLabel
      end if
      
      set the text of field "Label" of me to tLabel & "..."
   end repeat
end adjustLabel







