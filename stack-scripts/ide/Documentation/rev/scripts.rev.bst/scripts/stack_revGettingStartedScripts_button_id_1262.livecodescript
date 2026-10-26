script "stack_revGettingStartedScripts_button_id_1262"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Truncating text to a specific pixel width Example" (id 1259) > button "Truncate to fit in:" (id 1262)
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
