script "stack_revIcons_group_id_203779"
-- Stack file: ide/Toolset/palettes/revicons.rev
-- Object: stack "revIcons" > card (id 1002) > group "Script Editor" (id 203779)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseEnter
  set the tooltip of the target to the id of the target
end mouseEnter

on mouseLeave
  set the tooltip of the target to empty
end mouseLeave
