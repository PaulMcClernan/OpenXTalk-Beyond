script "stack_revOnlineCodeSnippetTemplate_button_id_1009"
-- Stack file: ide/Toolset/palettes/revonline.rev
-- Object: stack "revOnline" > substack "revOnlineCodeSnippetTemplate" > card (id 1002) > button "copy" (id 1009)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set the clipboarddata to the text of field "code" of the owner of me
end mouseUp
