script "stack_revStartCenter"
-- Stack file: ide/Toolset/palettes/start center/revStartCenter.livecode
-- Object: stack "revStartCenter"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
   revIDESubscribe "ideNewStack"
   revIDESubscribe "ideOpenStack"
   
   set the behavior of this stack to the long id of stack "revStartCenterBehavior"
end preOpenStack
