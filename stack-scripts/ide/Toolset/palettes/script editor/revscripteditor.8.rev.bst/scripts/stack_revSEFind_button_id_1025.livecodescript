script "stack_revSEFind_button_id_1025"
-- Stack file: ide/Toolset/palettes/script editor/revscripteditor.8.rev
-- Object: stack "revNewScriptEditor" > substack "revSEFind" > card "Main" (id 1002) > button "Toggle Options" (id 1025)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

constant kUpIcon = "205223"
constant kDownIcon = "205222"

on mouseUp
   if the label of me is "+" then
      optionsShow
      set the label of me to "-"
      set the icon of me to kUpIcon
   else
      optionsHide
      set the label of me to "+"
      set the icon of me to kDownIcon
   end if
end mouseUp

command resetIcon
   set the label of me to "+"
   set the icon of me to kDownIcon
end resetIcon
