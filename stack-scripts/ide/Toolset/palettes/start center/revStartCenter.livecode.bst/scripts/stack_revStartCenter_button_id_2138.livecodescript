script "stack_revStartCenter_button_id_2138"
-- Stack file: ide/Toolset/palettes/start center/revStartCenter.livecode
-- Object: stack "revStartCenter" > card "interface" (id 1002) > button "socialBehavior" (id 2138)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   startCenterAction the short name of me
end mouseUp

on mouseEnter
   socialMediaHilite the short name of me, true
end mouseEnter

on mouseLeave
   socialMediaHilite the short name of me, false
end mouseLeave
