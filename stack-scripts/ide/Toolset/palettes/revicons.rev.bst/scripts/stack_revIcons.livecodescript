script "stack_revIcons"
-- Stack file: ide/Toolset/palettes/revicons.rev
-- Object: stack "revIcons"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseEnter
   if word 1 of the target is "image" then set the toolTip of the target to the ID of the target
end mouseEnter
