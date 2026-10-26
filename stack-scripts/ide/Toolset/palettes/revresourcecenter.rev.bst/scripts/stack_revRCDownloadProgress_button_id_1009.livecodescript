script "stack_revRCDownloadProgress_button_id_1009"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > substack "revRCDownloadProgress" > card (id 1002) > button "Cancel" (id 1009)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   resourceDownloadCancel
   close this stack
end mouseUp
