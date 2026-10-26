script "stack_revGettingStartedScripts_button_id_1256"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Translating a color name to an RGB numeric triplet Example" (id 1255) > button "Color Name" (id 1256)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick theItem
  if theItem is empty or theItem is not a color then
    beep
    answer "Please choose a color first."
    put char 2 to -2 of word 3 of field "Color Result" into me
  else
    get RGBFromColorName(theItem)
    if char 1 to 5 of it is "Error" then answer it
    else put "The color" && quote & theItem & quote && "is" \
        && quote & RGBFromColorName(theItem) & quote & "." \
        into field "Color Result"
  end if
end menuPick

on enterInField
  menuPick the label of me
end enterInField

on returnInField
  enterInField
end returnInField

function RGBFromColorName theColor
  if theColor is not a color then return "Error: not a color"
  -- create a temporary object for the color transformation:
  create invisible button
  if the result is not empty then return "Error"
  set the backgroundColor of last button to theColor
  -- transform the color using the backgroundPixel trick:
  set the backgroundPixel of last button to \
      the backgroundPixel of last button
  -- the buttons backgroundColor is now RGB:
  get the backgroundColor of last button
  delete last button -- don't need the temp object any more
  -- the create command automatically chose the pointer
  -- tool, so change it back:
  send "choose browse tool" to me in 10 milliseconds
  return it
end RGBFromColorName
