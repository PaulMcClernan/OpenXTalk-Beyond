script "stack_Page_Setup_button_id_1111"
-- Stack file: ide/Toolset/palettes/revpagesetup.rev
-- Object: stack "Page Setup" > card "Print Setup Card" (id 1001) > group "Packing" (id 1110) > button "Pack Horizontally" (id 1111)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
    put "Cards per row:" into field "Cards"
end mouseUp
