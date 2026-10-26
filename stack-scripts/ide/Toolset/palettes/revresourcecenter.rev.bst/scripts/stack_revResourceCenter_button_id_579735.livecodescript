script "stack_revResourceCenter_button_id_579735"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Truncatingtexttoaspecificpixelwidth" (id 80422) > group "mainContent" (id 80435) > group (id 584248) > group "Example" (id 577016) > button "Truncate to fit in:" (id 579735)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if field "Text" is empty or field "Width" is empty or field "Width" is not an integer then
    beep
    exit mouseUp
  end if
  put truncatedToFit(field "Text",field "Width") into field "Text"
end mouseUp

function truncatedToFit theString,thePixelWidth
  create invisible field
  set the width of last field to thePixelWidth
  put theString into last field
  put line 1 of the formattedText of last field into myLine
  delete last field
  send "choose browse tool" to me in 1 millisecond
  return myLine
end truncatedToFit
