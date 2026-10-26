script "stack_revErrorReport_button_id_1010"
-- Stack file: ide/Toolset/palettes/standalone settings/revstandalonesettings.8.rev
-- Object: stack "revStandaloneSettings" > substack "revErrorReport" > card (id 1002) > button "Save" (id 1010)
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on mouseUp
  ask file "Save error report:" 
  if it <> "" and the result <> "cancel" then
    put the cReport of this stack & cr &cr&"Comments: "&fld "comments" into url ("file:"&it)
  end if
end mouseUp
