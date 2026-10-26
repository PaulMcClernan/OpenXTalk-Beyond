script "stack_revResourceCenter_button_id_579843"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Textmenu:handlingchoices" (id 100349) > group "mainContent" (id 100360) > group (id 579844) > group "Example" (id 577030) > button "Text" (id 579843)
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
            if currentStyle is "plain" then 
               put theMenuItem into currentStyle
            else 
               put comma & theMenuItem after currentStyle
            end if
         end if
         
         set the textStyle of field "Example Text" to currentStyle
   end switch
end menuPick
  

on mouseDown -- goes in the menu button’s script
   local tButtonText
   
   local tFonts, tCurrentFont
   set the wholeMatches to true
   
   -- Get a list of all the fonts available on this system.
   put the fontNames into tFonts
   -- Get the name of the font currently being used in the example
   -- field.
   put the effective textFont of field "Example Text" into tCurrentFont
   
   put "Font" & return into tButtonText
   -- Repeat through each of the fonts, checking if they are the current 
   -- font being used.
   repeat for each line tFont in tFonts
      if tFont is tCurrentFont then
         -- Adds a checkmark to the current font.
         put "!c" & tab & tFont & return after tButtonText
      else
         put tab & tFont & return after tButtonText
      end if
   end repeat
   
   
   local tCurrentSize
   local tSizes = "9,10,12,14,18,20,24,36"
   -- Gets the current text size.
   put the effective textSize of field "Example Text" into tCurrentSize
   put "Size" & return after tButtonText
   
   set the itemdelimiter to comma
   repeat for each item tSize in tSizes
      if tSize is tCurrentSize then
         -- Puts a checkmark before the textsize being used.
         put "!c" & tab & tSize & return after tButtonText
      else
         put tab & tSize & return after tButtonText
      end if
   end repeat
   
   local tCurrentColor
   local tAvailableColors = "Black,Yellow,Red,Blue,Green"
   -- Gets the text color currently in use.
   put the effective textColor of field "Example Text" into tCurrentColor
   put "Color" & return after tButtonText
   
   set the itemdelimiter to comma
   repeat for each item tColor in tAvailableColors
      if tColor is tCurrentColor then
         -- Adds a checkmark before the menu item representing the
         -- current color.
         put "!c" & tab & tColor & return after tButtonText
      else
         put tab & tColor & return after tButtonText
      end if
   end repeat
   
  
   local tCurrentTextStyle
   put the effective textStyle of field "Example Text" into tCurrentTextStyle
   
   local tAvailableTextStyles
   put "Plain,Bold,Italic,Underline" into tAvailableTextStyles
   
   set the itemdelimiter to comma
   repeat for each item tStyle in tAvailableTextStyles
      -- As you can have multiple text styles, we check if
      -- the current style is among the styles being used.
      if tStyle is among the items of tCurrentTextStyle then
         -- Adds a checkmark to the menu item if it is.
         put "!c" & tStyle & return after tButtonText
      else
         put tStyle & return after tButtonText
      end if
   end repeat
   
   -- We know the last character will be a return so delete it from
   -- the list.
   delete the last char of tButtonText
   put tButtonText into button "Text"
end mouseDown
        
        
        
