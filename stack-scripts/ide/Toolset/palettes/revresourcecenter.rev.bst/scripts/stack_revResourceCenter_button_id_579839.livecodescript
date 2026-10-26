script "stack_revResourceCenter_button_id_579839"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > card "Textmenu:populatingwithcontent" (id 82654) > group "mainContent" (id 82665) > group (id 579841) > group "Example" (id 577029) > button "Text" (id 579839)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on menuPick theItem
  answer "You chose:" & return & tab & theItem
end menuPick
