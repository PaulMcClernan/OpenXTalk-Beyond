script "stack_revErrorReport_button_id_1009"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > substack "revErrorReport" > card (id 1002) > button "Email" (id 1009)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.


on mouseUp
  revMail the cEmail of this stack,,"Error Report",replaceText(the cReport of this stack & cr &cr&"Comments: "&fld "comments",quote,"'")
end mouseUp
