script "stack_revResourceCenter_button_id_579877"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "FittingaPrintouttothePage" (id 77973) > group "mainContent" (id 77984) > group (id 579880) > group "Example" (id 577042) > button "Print Card" (id 579877)
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
