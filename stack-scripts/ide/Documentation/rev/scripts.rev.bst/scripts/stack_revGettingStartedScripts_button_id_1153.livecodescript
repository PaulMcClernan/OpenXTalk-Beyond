script "stack_revGettingStartedScripts_button_id_1153"
-- Stack file: ide/Documentation/rev/scripts.rev
-- Object: stack "revGettingStartedScripts" > card (id 1002) > group "Fitting a printout to the page Example" (id 1152) > button "Print Card" (id 1153)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  put round(field "Margin" * 72) into myMargin
  if myMargin is zero then put 72 into myMargin
  set the defaultStack to the topStack
  printThisCard empty,myMargin
end mouseUp

on printThisCard thePaperSize,theMargin
  if thePaperSize is empty then put 612,792 into thePaperSize
  if theMargin is empty then put 72 into theMargin
  -- get the page area
  set the printMargins to \
     theMargin,theMargin,theMargin,theMargin
  put theMargin,theMargin, \
    item 1 of thePaperSize - theMargin, \
    item 2 of thePaperSize - theMargin \
    into destinationRect
  -- print into that rectangle
  print this card into destinationRect
end printThisCard
