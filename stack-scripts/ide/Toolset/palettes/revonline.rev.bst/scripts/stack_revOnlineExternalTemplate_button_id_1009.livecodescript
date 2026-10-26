script "stack_revOnlineExternalTemplate_button_id_1009"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > substack "revOnlineExternalTemplate" > card (id 1002) > button "Install" (id 1009)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   installFull
   disable me
end mouseUp

on mouseEnter
   infoShow "This will install the external to your LiveCode externals folder. It will be available in the IDE and you will be able to build standalones with it."
end mouseEnter

on mouseLeave
   infoShow empty
end mouseLeave
