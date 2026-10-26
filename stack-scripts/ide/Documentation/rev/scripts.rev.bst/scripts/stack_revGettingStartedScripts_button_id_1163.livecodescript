script "stack_revGettingStartedScripts_button_id_1163"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Text menu: handling choices Example" (id 1161) > button "Text" (id 1163)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

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
    -- plain removes all styles:
    set the textStyle of field "Example Text" to empty
  case "Bold"       -- all three remaining menu items
  case "Italic"     --   are handled with the same piece
  case "Underline"  --   of code:
    put the textStyle of field "Example Text" into currentStyle
    set the itemDelimiter to comma
    if theMenuItem is among the items of currentStyle then
      -- already has that style, so remove it
      delete item (itemOffset(theMenuItem,currentStyle)) \
         of currentStyle
    else
      -- add the style to any existing styles
      if currentStyle is "plain"
      then put theMenuItem into currentStyle
      else put comma & theMenuItem after currentStyle
    end if
    set the textStyle of field "Example Text" to currentStyle
  end switch
end menuPick

on mouseDown -- goes in the menu buttons script
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
