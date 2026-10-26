script "stack_revOnlineExternalTemplate_button_id_1008"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > substack "revOnlineExternalTemplate" > card (id 1002) > button "Try" (id 1008)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   installTemporary
   disable me
   infoShow "The external has now been temporarily installed in the IDE and all its commands and functions have been inserted into the message path"
end mouseUp

on mouseEnter
   infoShow "This will temporarily install the external so you can try using it. It will be lost when you close LiveCode."
end mouseEnter

on mouseLeave
   infoShow empty
end mouseLeave
