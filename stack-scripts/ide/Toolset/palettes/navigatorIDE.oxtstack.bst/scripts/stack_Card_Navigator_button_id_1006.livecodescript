script "stack_Card_Navigator_button_id_1006"
-- Stack file: ide/Toolset/palettes/navigatorIDE.oxtstack
-- Object: stack "Card Navigator" > card (id 1002) > group "navbtns" (id 1016) > button "Prev" (id 1006)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mousedown
   put cd fld "stackName" into tStack
   try
      go to prev card of stack tStack
   catch e
   end try
end mousedown
