script "stack_revSETemplate_group_id_57956"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSETemplate" > card "Templates" (id 2609) > group "Variable Template" (id 57956)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

local sExpanded
local sLeaf
local sFinal
local sInitial
local sHilite = "false"

getProp cExpanded
  return sExpanded
end cExpanded

# OK-2008-06-12 : New disclosure icons
constant kIconExpand = 205210
constant kIconContract = 205209

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
      set the icon of button "Expander" of me to kIconExpand
   else
      set the icon of button "Expander" of me to kIconContract
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
          set the icon of button "Expander" of me to kIconExpand
      else
          set the icon of button "Expander" of me to kIconContract
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
  
  set the icon of button "Icon" of me to pIcon
end cIcon

getProp cIcon
  return the icon of button "Icon" of me
end cIcon

local sLabel

setProp cLabel pLabel
   put pLabel into sLabel
   set the text of field "Label" of me to pLabel
end cLabel

getProp cLabel
  return sLabel
end cLabel

local sValue

setProp cValue pValue
   set the text of field "Value" of me to line 1 of pValue
   put pValue into sValue
end cValue

getProp cValue
   return sValue
end cValue

setProp cFinal pValue
  if pValue is not among the items of "true,false" then
    error "Invalid final value, expected Boolean, got: " & pValue
  end if
  
  put pValue into sFinal
end cFinal

getProp cFinal
  return sFinal
end cFinal

setProp cInitial pValue
  if pValue is not among the items of "true,false" then
    error "Invalid initial value, expected Boolean, got: " & pValue
  end if
  
  put pValue into sInitial
end cInitial

getProp cInitial
  return sInitial
end cInitial

--setProp cHilite pValue
--   if pValue is not among the items of "true,false" then
--      error "Invalid hilite value, expected Boolean, got: " & pValue
--   end if
   
--   if pValue then
--      --set the loc of image "HighlightBranch" of me to the loc of me
--   else
--      set the right of image "HighlightBranch" of me to the left of me - 500
--   end if
   
--   put pValue into sHilite
--end cHilite

--getProp cHilite
--  return sHilite
--end cHilite

getProp cAxis
   return 0
end cAxis

constant kLeftMargin = 16

private function valueTooLarge
   if the cLeaf of me and ((the number of lines of the cValue of me > 1) or (the formattedWidth of field "Value" of me > the width of field "Value" of me)) then
      return true
   else
      return false
   end if
end valueTooLarge

constant kEvenColor = "255,255,255"
constant kOddColor = "241,245,250"

private command updateColors
   if the cHilite of me then
      # OK-2009-03-11 : Bug 7499 - Allow configurable hilite color. Note that we use the old default
      # grey if no hilite color can be determined, this should never happen.
      local tHiliteColor
      put sePrefGet("editor,hilitecolor") into tHiliteColor
      if tHiliteColor is empty then
         put the hiliteColor into tHiliteColor
      end if
      
      if tHiliteColor is empty then
         put "178,180,191" into tHiliteColor
      end if
      
      set the backgroundColor of graphic "Background" of me to tHiliteColor
      if seGetPlatform() is not "MacOS" then
         set the textColor of me to "255,255,255"
      end if
   else
      if (the cId of me mod 2) is 0 then
         set the backgroundColor of graphic "Background" of me to kEvenColor
      else
         set the backgroundColor of graphic "Background" of me to kOddColor
      end if
      set the textColor of me to empty
   end if
end updateColors

command resize
   local tSplit
   put getVerticalSplit() into tSplit
   
   local tRightSplit
   put the right of me - the width of button "Visualize" of me into tRightSplit
   
   set the rect of field "Label" of me to the left of me + kLeftMargin, the top of me, tSplit, the bottom of me
   
   if the cLeaf of me then
      set the rect of field "Value" of me to tSplit + 8, the top of me, tRightSplit, the bottom of me
   else
      set the right of field "Value" of me to the left of me - 500
   end if
   
   # Only show the visualize button if the branch is both a leaf and contains a bigger value than will fit in the field.
   if valueTooLarge() then
      set the rect of button "Visualize" of me to tRightSplit, the top of me, the right of me, the bottom of me
   else
      set the right of button "Visualize" of me to the left of me - 500
   end if
   
   set the left of button "Expander" of me to the left of me
   set the location of button "Expander" of me to (item 1 of the location of button "Expander" of me), (item 2 of the location of me)
   
   set the rect of graphic "Background" of me to the rect of me
   --   if (the cId of me mod 2) is 0 then
   --      set the backgroundColor of graphic "Background" of me to kEvenColor
   --   else
   --      set the backgroundColor of graphic "Background" of me to kOddColor
   --   end if
   updateColors
end resize

command setEditable pField, pValue
   if pValue then
      set the lockText of pField to false
      set the traversalOn of pField to true
      set the showBorder of pField to true
      set the borderWidth of pField to 2
      set the left of button "Apply" of me to the right of pField
      set the loc of button "Apply" of me to (item 1 of the loc of button "Apply" of me), (item 2 of the loc of pField)
      set the cEditField of me to the long id of pField
      set the cEditNode of the long owner of the long owner of me to the long id of me
      select after field (the short name of pField) of me
   else
      set the lockText of pField to true
      set the showBorder of pField to false
      set the borderWidth of pField to 0
      set the traversalOn of pField to false
      set the right of button "Apply" of me to the left of me - 500
      set the cEditField of me to empty
      set the cEditNode of the long owner of the long owner of me to empty
   end if
end setEditable

setProp cHilite pValue
   setHilite pValue
end cHilite

getProp cHilite
   return sHilite
end cHilite

private command setHilite pValue
   put pValue into sHilite
   updateColors
end setHilite

on mouseUp
   if the short name of the target is "Apply" then
      local tField
      put the cEditField of me into tField
      if there is no tField then
         exit mouseUp
      end if
      
      applyValue the text of tField
      setEditable tField, false
   else
      pass mouseUp
   end if
end mouseUp

command applyValue pValue
   nodeSetValue the cId of me, pValue
   
   # This must be sent in 0 milliseconds because the update command will attempt to delete
   # this group, so the group's script must not still be executing when this happens.
   send "update" to the long owner of the long owner of me in 0 milliseconds
end applyValue

on mouseDoubleUp
   if the short name of the target is "Value" and not valueTooLarge() then
      setEditable the long id of field "Value" of me, true
      exit mouseDoubleUp
   end if
   
   if the short name of the target is "Value" and valueTooLarge() then
      nodeVisualize the cId of me
      exit mouseDoubleUp
   end if
   
   pass mouseDoubleUp
end mouseDoubleUp

private command stopEditingValue
   if the short name of the target is "Value" and the cEditField of me is the long id of field "Value" of me then
      applyValue the text of field "Value" of me
      setEditable the long id of field "Value" of me, false
   end if
end stopEditingValue

on exitField
   stopEditingValue
end exitField

on closeField
   stopEditingValue
end closeField

on enterInField
   stopEditingValue
end enterInField









