script "stack_Print_Dialog_button_id_1060"
-- Stack file: ide/Toolset/palettes/revprintdialog.rev
-- Object: stack "Print Dialog" > card (id 1002) > group "Additional Options" (id 6589) > button "Duplex" (id 1060)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if the hilite of me is true then
    enable group "Duplex settings"
  else
    disable group "Duplex settings"
  end if
  updateDuplexImage
  pass mouseup
end mouseUp
