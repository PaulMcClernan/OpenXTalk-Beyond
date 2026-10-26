script "stack_Page_Setup_Dialog_button_id_1060"
-- Stack file: ide/Toolset/palettes/revpagesetupdialog.rev
-- Object: stack "Page Setup Dialog" > card (id 1002) > group "Paper Scale" (id 1063) > button "Scale" (id 1060)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pText
  set the cValue of me to pText
  pass menuPick
end menuPick

--on keyDown
--  set the cValue of me to the label of me
--  pass keyDown
--end keyDown

command updateValue
  set the cValue of me to the label of me
end updateValue



