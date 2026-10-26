script "stack_revResourceCenter_graphic_id_579800"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "SettinganRGBcolorchannelofanobject" (id 80392) > group "mainContent" (id 80407) > group (id 579804) > group "Example" (id 577022) > graphic "Color Swatch" (id 579800)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

setProp redChannel theValue
  -- make sure theValue is between zero and 255:
  put max(min(theValue,255),zero) into theValue
  get the backgroundColor of the target
  if the number of items of it is not 3 then
    -- use trick to convert to RGB triplet:
    set the backgroundPixel of the target \
      to the backgroundPixel of the target
    get the backgroundColor of the target
  end if
  -- change the first item - red - to new value:
  put theValue into item 1 of it
  set the backgroundColor of the target to it
end redChannel

setProp greenChannel theValue
  -- make sure theValue is between zero and 255:
  put max(min(theValue,255),zero) into theValue
  get the backgroundColor of the target
  if the number of items of it is not 3 then
    -- use trick to convert to RGB triplet:
    set the backgroundPixel of the target \
      to the backgroundPixel of the target
    get the backgroundColor of the target
  end if
  -- change the second item - green - to new value:
  put theValue into item 2 of it
  set the backgroundColor of the target to it
end greenChannel

setProp blueChannel theValue
  -- make sure theValue is between zero and 255:
  put max(min(theValue,255),zero) into theValue
  get the backgroundColor of the target
  if the number of items of it is not 3 then
    -- use trick to convert to RGB triplet:
    set the backgroundPixel of the target \
        to the backgroundPixel of the target
    get the backgroundColor of the target
  end if
  -- change the third item - blue - to new value:
  put theValue into item 3 of it
  set the backgroundColor of the target to it
end blueChannel
