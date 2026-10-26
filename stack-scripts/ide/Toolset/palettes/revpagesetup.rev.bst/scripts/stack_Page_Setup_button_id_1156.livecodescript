script "stack_Page_Setup_button_id_1156"
-- Stack file: ide/Toolset/palettes/revpagesetup.rev
-- Object: stack "Page Setup" > card "Print Setup Card" (id 1001) > group "Output" (id 1151) > button "Printer..." (id 1156)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  if the platform is "Win32" or the platform is "MacOS"
  then answer printer
  else modeless "Printer Chooser"
end mouseUp
