script "stack_Printer_Chooser_card_id_1002"
-- Stack file: ide/Toolset/palettes/revprinterchooser.rev
-- Object: stack "Printer Chooser" > card (id 1002)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenCard
  set the hilite of button "Portrait" to not the printRotated
  set the hilite of button "Landscape" to the printRotated
  switch the printPaperSize
  case "612,1008"
    set hilitedButtonName of group "Paper Size:" to "Legal"
    break
  case "595,842"
    set hilitedButtonName of group "Paper Size:" to "A4"
    break
    default
    set hilitedButtonName of group "Paper Size:" to "Letter"
  end switch
  put the printCommand into field "Command"
end preOpenCard

on returnInField
  setprops
end returnInField

on returnKey
  setprops
end returnKey

on setprops
  set the printRotated to the hilite of button "Landscape"
  if the hilite of button "Letter" then set the printPaperSize to "612,792"
  if the hilite of button "Legal" then set the printPaperSize to "612,1008"
  if the hilite of button "A4" then set the printPaperSize to "595,842"
  if the printCommand is not field "Command" then
    set the printCommand to field "Command"
    if line 1 of the mainStacks is "Home" then
      set the preferences["printCommand"] of stack "Home" to field "Command"
      save stack "Home"
    end if
  end if
  close this stack
end setprops
