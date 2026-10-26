script "stack_Page_Setup_Dialog_button_id_1007"
-- Stack file: ide/Toolset/palettes/revpagesetupdialog.rev
-- Object: stack "Page Setup Dialog" > card (id 1002) > group "Paper Size" (id 1018) > button "Paper size" (id 1007)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick pItemName
  changePaperSize pItemName
  pass menuPick
end menuPick

