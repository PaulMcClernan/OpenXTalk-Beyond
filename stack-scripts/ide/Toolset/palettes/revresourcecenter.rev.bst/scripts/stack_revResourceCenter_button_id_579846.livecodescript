script "stack_revResourceCenter_button_id_579846"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "TextMenu:UpdatingCheckmarks" (id 100262) > group "mainContent" (id 100272) > group (id 584257) > group "Example" (id 577031) > button "Text" (id 579846)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseDown -- goes in the menu button’s script
  -- remove old checkmarks:
  replace "!c" with empty in button "Text"
  set the wholeMatches to true
  -- put a checkmark next to the current font:
  put lineOffset(tab & the effective textFont of \
     field "Example Text",button "Text") into currentFontLine
  if currentFontLine is not zero then
    put "!c" before line currentFontLine of button "Text"
  end if
  -- put a checkmark next to the current size:
  put lineOffset(tab & the effective textSize of \
     field "Example Text",button "Text") into currentSizeLine
  if currentSizeLine is not zero then
    put "!c" before line currentSizeLine of button "Text"
  end if
  -- put a checkmark next to the current color:
  put lineOffset(tab & the effective textColor of \
     field "Example Text",button "Text") into currentColorLine
  if currentColorLine is not zero then
    put "!c" before line currentColorLine of button "Text"
  end if
  -- put checkmarks next to current style(s):
  put the effective textStyle of field "Example Text" \
     into myStyleList
  if myStyleList is "plain"
  then put "!c" before line -4 of button "Text"
  -- (4th-from-last line in the menu)
  else -- may have more than one style checked:
    if "bold" is among the items of myStyleList then \
       put "!c" before line -3 of button "Text"
    if "italic" is among the items of myStyleList then \
       put "!c" before line -2 of button "Text"
    if "underline" is among the items of myStyleList then \
       put "!c" before line -1 of button "Text"
  end if
end mouseDown

on menuPick theMenuItem
  set the itemDelimiter to "|"
  switch item 1 of theMenuItem -- the submenu name
  case "Font"
    set the textFont of field "Example Text" \
        to item 2 of theMenuItem
    break
  case "Size"
    set the textSize of field "Example Text" \
        to item 2 of theMenuItem
    break 
  case "Color"
    set the textColor of field "Example Text" \
        to item 2 of theMenuItem
    break
  case "Plain"
    -- plain removes all styles
    set the textStyle of field "Example Text" \
        to empty
  default -- for Bold, Italic, Underline
    put the textStyle of field "Example Text" into currentStyle
    set the itemDelimiter to comma
    if theMenuItem is among the items of currentStyle then
      -- already has that style, so remove it
      delete item (itemOffset(theMenuItem,currentStyle)) \
         of currentStyle
    else
      -- add the style to any existing styles
      put comma & theMenuItem after currentStyle
    end if
    if char 1 of currentStyle is comma then delete char 1 of currentStyle
    set the textStyle of field "Example Text" to currentStyle
  end switch
end menuPick
