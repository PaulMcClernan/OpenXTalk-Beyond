script "stack_revIDEProjectBrowser_button_id_978932"
-- Stack file: ide/Toolset/palettes/project browser/revideprojectbrowser.livecode
-- Object: stack "revIDEProjectBrowser" > card "list" (id 1002) > button "Refresh" (id 978932)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
   set cursor to busy
   lock screen
   refreshProjectView
   unlock screen
end mouseUp
